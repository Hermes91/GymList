import 'package:flutter/material.dart';
import '../models/user.dart';
import '../helpers/helpers.dart';

class ConfirmPaymentModal extends StatelessWidget {
  final User user;
  final VoidCallback onConfirm;

  const ConfirmPaymentModal({
    super.key,
    required this.user,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;
    final monthName = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ][currentMonth - 1];

    return AlertDialog(
      title: const Text('Confirmar Pago'),
      content: Text(
        '¿Estás seguro de que deseas marcar como pagada la membresía de ${capitalize(user.name)} para el mes de $monthName?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Close modal
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
