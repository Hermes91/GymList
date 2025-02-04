import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/user_status.dart';

class UserService {
  final Box<User> userBox = Hive.box<User>('users');

  List<User> getFilteredUsers(String searchQuery, UserStatus? selectedFilter) {
    final query = searchQuery.toLowerCase();
    return userBox.values.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(query) ||
          user.surname.toLowerCase().contains(query) ||
          user.dni.contains(query);

      final matchesFilter =
          selectedFilter == null || user.status == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void updateUserStatus(User user, UserStatus newStatus) {
    if (user.status == UserStatus.suspendido &&
        newStatus == UserStatus.habilitado) {
      user.creationDate = DateTime.now();
    }
    if (newStatus == UserStatus.vencido) {
      user.paidMembership = false;
    }
    user.status = newStatus;
    user.save();
  }
}

class DateTimeWrapper {
  DateTime now() => DateTime.now();
}
