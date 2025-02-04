import 'package:flutter/material.dart';
import 'package:gymlist_flutter/helpers/helpers.dart';
import '../models/user.dart';
import '../models/user_status.dart';

class EditStatusModal extends StatelessWidget {
  final User user;
  final UserStatus? initialStatus;
  final ValueChanged<UserStatus?> onStatusChanged;
  final VoidCallback onSave;

  const EditStatusModal({
    super.key,
    required this.user,
    required this.initialStatus,
    required this.onStatusChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modificar Estado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              '${capitalize(user.name)} ${capitalize(user.surname)} (${user.dni})'),
          const SizedBox(height: 16),
          DropdownButtonFormField<UserStatus>(
            value: initialStatus,
            decoration: const InputDecoration(
              labelText: 'Modificar estado',
              border: OutlineInputBorder(),
            ),
            items: UserStatus.values.where((status) {
              if (user.status == UserStatus.suspendido &&
                  status == UserStatus.vencido) {
                return false;
              }
              return true;
            }).map((status) {
              return DropdownMenuItem<UserStatus>(
                value: status,
                child: Text(status.displayName),
              );
            }).toList(),
            onChanged: onStatusChanged,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            onSave();
            Navigator.of(context).pop();
          },
          child: const Text('Actualizar'),
        ),
      ],
    );
  }
}
