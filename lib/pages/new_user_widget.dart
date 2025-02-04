import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../modals/custom_modal.dart';
import 'package:uuid/uuid.dart';

class NewUserWidget extends StatefulWidget {
  final VoidCallback onSuccess; // Nueva propiedad para el callback

  const NewUserWidget({super.key, required this.onSuccess});

  @override
  State<NewUserWidget> createState() => _NewUserWidgetState();
}

class _NewUserWidgetState extends State<NewUserWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();

  final Box<User> _userBox = Hive.box<User>('users');

  bool _isValidDni(String value) {
    return RegExp(r'^\d{7,8}$').hasMatch(value);
  }

  void _registerUser() {
    if (_formKey.currentState!.validate()) {
      bool dniExists = _userBox.values
          .cast<User>()
          .any((user) => user.dni == _dniController.text);

      if (dniExists) {
        CustomModal.show(
          context: context,
          title: 'Hubo un problema al registrarse',
          message: 'DNI ya registrado',
          isSuccess: false,
        );
        return;
      }

      final uuid = Uuid();
      final newUser = User(
        id: uuid.v4(),
        name: _nameController.text,
        surname: _surnameController.text,
        dni: _dniController.text,
        creationDate: DateTime.now(),
      );

      _userBox.add(newUser);

      // Llamar al callback antes de mostrar el modal
      widget.onSuccess();

      CustomModal.show(
        context: context,
        title: 'Registro exitoso',
        message: 'El usuario ha sido registrado correctamente.',
        isSuccess: true,
      );

      _formKey.currentState?.reset();
      _nameController.clear();
      _surnameController.clear();
      _dniController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Te damos la bienvenida',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 100),
          Form(
            key: _formKey,
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre:',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Debes ingresar tu nombre' : null,
                  ),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: TextFormField(
                    controller: _surnameController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido:',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Debes ingresar tu apellido' : null,
                  ),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: TextFormField(
                    controller: _dniController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'DNI:',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debes ingresar tu DNI';
                      }
                      if (!_isValidDni(value)) {
                        return 'Ingrese un DNI válido (7-8 dígitos numéricos)';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: _formKey.currentState?.validate() == true
                  ? _registerUser
                  : null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: const Text('Registrar'),
            ),
          ),
        ],
      ),
    );
  }
}
