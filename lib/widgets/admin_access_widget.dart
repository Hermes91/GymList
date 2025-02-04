import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AdminAccessWidget extends StatefulWidget {
  const AdminAccessWidget({super.key});

  @override
  AdminAccessWidgetState createState() => AdminAccessWidgetState();
}

class AdminAccessWidgetState extends State<AdminAccessWidget> {
  bool _showPasswordField = false;
  bool _showChangePasswordButton = false;
  final TextEditingController _passwordController = TextEditingController();

  void togglePasswordField(bool show) {
    setState(() {
      _showPasswordField = show;
      _showChangePasswordButton = show;
    });
  }

  String? getPassword() {
    return _passwordController.text;
  }

  void _showChangePasswordModal() {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close modal
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (newPassword.isEmpty || confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, complete todos los campos'),
                    ),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Las contraseñas no coinciden'),
                    ),
                  );
                  return;
                }

                // Save the new password
                final settingsBox = Hive.box('settings');
                settingsBox.put('adminPassword', newPassword);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contraseña actualizada correctamente'),
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showPasswordField)
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        const SizedBox(height: 8),
        if (_showChangePasswordButton)
          ElevatedButton(
            onPressed: _showChangePasswordModal,
            child: const Text('Cambiar Contraseña'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
