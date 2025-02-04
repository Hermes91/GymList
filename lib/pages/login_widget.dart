import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymlist_flutter/config.dart';
import 'package:gymlist_flutter/helpers/helpers.dart';
import 'package:gymlist_flutter/models/user.dart';
import 'package:gymlist_flutter/models/user_status.dart';
import 'package:gymlist_flutter/pages/admin_panel_widget.dart';
import 'package:gymlist_flutter/widgets/admin_access_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../modals/custom_modal.dart';

class LoginWidget extends StatefulWidget {
  final bool showSuccessModal;
  const LoginWidget({super.key, this.showSuccessModal = false});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dniController = TextEditingController();
  final GlobalKey<AdminAccessWidgetState> _adminAccessKey =
      GlobalKey<AdminAccessWidgetState>();

  late Box<User> _userBox;

  bool _isValidDni = false;
  final String adminDni = AppConfig.adminDni;

  void _validateDni(String value) {
    setState(() {
      _isValidDni = RegExp(r'^\d{7,8}$').hasMatch(value);
    });

    if (value == adminDni) {
      _adminAccessKey.currentState?.togglePasswordField(true);
    } else {
      _adminAccessKey.currentState?.togglePasswordField(false);
    }
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final dni = _dniController.text;

      if (dni == adminDni) {
        // Admin login workflow
        final password = _adminAccessKey.currentState?.getPassword();
        final settingsBox = Hive.box('settings');
        final savedPassword = settingsBox.get('adminPassword',
            defaultValue: AppConfig.defaultAdminPassword);

        if (password == savedPassword) {
          CustomModal.show(
            context: context,
            title: 'Acceso de administrador',
            message: 'Bienvenido/a al panel de administración.',
            isSuccess: true,
          ).then((_) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminPanelWidget()),
              );
            }
          });
        } else {
          CustomModal.show(
            context: context,
            title: 'Error',
            message: 'Contraseña de administrador incorrecta.',
            isSuccess: false,
          );
        }
      } else {
        User? user;

        try {
          user = _userBox.values.firstWhere(
            (user) => user.dni == dni,
          );
        } catch (e) {
          // Handle the case when the user is not found (i.e., no match)
          user = null;
        }

        if (user != null) {
          // User found: show welcome modal
          String message;

          if (user.status == UserStatus.habilitado) {
            message = 'Tu membresía está activa. 💪 ¡Sigue así!';
          } else {
            message =
                'Tu cuota está vencida ⚠️️. Por favor, regulariza tu situación para seguir entrenando.';
          }

          CustomModal.show(
            context: context,
            title: '¡Hola ${capitalize(user.name)}!',
            message: message,
            isSuccess: user.status == UserStatus.habilitado,
          );
          _dniController.clear();
          setState(() {
            _isValidDni = false;
          });
        } else {
          CustomModal.show(
            context: context,
            title: 'Error',
            message: 'No hay socios registrados con este DNI.',
            isSuccess: false,
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _userBox = Hive.box<User>('users');
    if (widget.showSuccessModal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomModal.show(
          context: context,
          title: 'Registro exitoso',
          message: 'El usuario ha sido registrado correctamente.',
          isSuccess: true,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Ingrese su DNI',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 100),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _dniController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'DNI:',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _validateDni,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El DNI no puede estar vacío';
                      }
                      if (!RegExp(r'^\d{7,8}$').hasMatch(value)) {
                        return 'Ingrese un DNI válido (7-8 dígitos numéricos)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AdminAccessWidget(key: _adminAccessKey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _isValidDni ? _login : null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: const Text('Ingresar'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dniController.dispose();
    super.dispose();
  }
}
