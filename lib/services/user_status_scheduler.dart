import 'dart:async';
import 'package:gymlist_flutter/models/user.dart';
import 'package:gymlist_flutter/models/user_status.dart';
import 'package:hive/hive.dart';

class UserStatusScheduler {
  static final UserStatusScheduler _instance = UserStatusScheduler._internal();
  late Timer _timer;

  UserStatusScheduler._internal();

  factory UserStatusScheduler() => _instance;

  void start() {
    _timer = Timer.periodic(Duration(days: 1), (timer) {
      updateUserStatuses();
    });
  }

  void stop() {
    _timer.cancel();
  }

  void updateUserStatuses() {
    final userBox = Hive.box<User>('users');
    final currentDate = DateTime.now();

    for (var user in userBox.values) {
      final nextDueDate = DateTime(
        user.creationDate.year,
        user.creationDate.month +
            (currentDate.month - user.creationDate.month) +
            1,
        user.creationDate.day,
      );

      // If the user's "due date" has passed, update their status
      if (currentDate.isAfter(nextDueDate) && !user.paidMembership) {
        user.status = UserStatus.vencido;
        user.save();
      }
    }
  }
}
