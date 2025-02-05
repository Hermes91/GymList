import 'package:flutter/material.dart';
import 'package:gymlist_flutter/models/user_status.dart';

String capitalize(String text) {
  return text.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

Color getStatusColor(UserStatus status) {
  switch (status) {
    case UserStatus.habilitado:
      return Color(0xFF80C2AF);
    case UserStatus.vencido:
      return Colors.red;
    case UserStatus.suspendido:
      return Colors.grey;
  }
}

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
}
