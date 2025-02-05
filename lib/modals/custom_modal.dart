import 'package:flutter/material.dart';

class CustomModal {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    bool isSuccess = true,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: isSuccess ? Color(0xFF80C2AF) : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
