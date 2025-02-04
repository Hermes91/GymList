import 'package:flutter/material.dart';
import 'package:gymlist_flutter/services/user_status_scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/user.dart';
import 'pages/home.dart';
import 'models/user_status.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');

  final settingsBox = Hive.box('settings');
  if (!settingsBox.containsKey('adminPassword')) {
    settingsBox.put('adminPassword', 'admin123');
  }

  //await resetDatabase();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(UserStatusAdapter());
  final userBox = await Hive.openBox<User>('users');

  _updateUsersOnStartup(userBox);
  UserStatusScheduler().start();

  runApp(const MyApp());
}

void _updateUsersOnStartup(Box<User> userBox) {
  for (final user in userBox.values) {
    user.updateMonthlyStatus();
    user.save();
  }
}

Future<void> resetDatabase() async {
  await Hive.deleteBoxFromDisk('users'); // Deletes the entire database
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: HomePage());
  }
}
