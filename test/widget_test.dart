import 'package:flutter_test/flutter_test.dart';
import 'package:gymlist_flutter/models/user.dart';
import 'package:gymlist_flutter/models/user_status.dart';
import 'package:gymlist_flutter/services/user_service.dart';
import 'package:hive/hive.dart';

void main() async {
  // Ensure Flutter binding is initialized for testing
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register the User adapter
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(UserStatusAdapter());

  // Initialize Hive with the mocked path
  Hive.init('test/temp'); // Provide a mock directory for storing boxes

  group('User paidMembership reset logic', () {
    test('Should reset paidMembership to false on the first of the month',
        () async {
      // Arrange
      final fakeDateTimeWrapper = FakeDateTimeWrapper(DateTime(2023, 11, 1));

      var box = await Hive.openBox<User>('testUsersBox');

      // Create the User and add it to the box
      final user = User(
        id: '55123',
        name: 'Anne',
        surname: 'Boonchuy',
        dni: '12115658',
        creationDate: DateTime(2023, 10, 7),
        status: UserStatus.habilitado,
        paidMembership: true,
        dateTimeWrapper: fakeDateTimeWrapper,
      );

      await box.put(user.id, user); // Add user to the box

      // Act
      user.updateMonthlyStatus();

      // Assert
      expect(user.paidMembership, false);

      // Clean up
      await box.close();
    });

    test('Should not reset paidMembership if the status is suspendido',
        () async {
      // Arrange
      final fakeDateTimeWrapper = FakeDateTimeWrapper(DateTime(2023, 11, 1));

      var box = await Hive.openBox<User>('testUsersBox');

      // Create the User with 'suspendido' status and add it to the box
      final user = User(
        id: '55123',
        name: 'Anne',
        surname: 'Boonchuy',
        dni: '12115658',
        creationDate: DateTime(2023, 10, 7),
        status: UserStatus.suspendido, // Status is suspendido
        paidMembership: true,
        dateTimeWrapper: fakeDateTimeWrapper,
      );

      await box.put(user.id, user); // Add user to the box

      // Act
      user.updateMonthlyStatus();

      // Assert
      expect(user.paidMembership,
          true); // Should remain true even if it's the first of the month

      // Clean up
      await box.close();
    });

    test('Should not reset paidMembership if it is not the first of the month',
        () async {
      // Arrange
      final fakeDateTimeWrapper = FakeDateTimeWrapper(
          DateTime(2023, 11, 2)); // Not the first of the month

      var box = await Hive.openBox<User>('testUsersBox');

      // Create the User and add it to the box
      final user = User(
        id: '55123',
        name: 'Anne',
        surname: 'Boonchuy',
        dni: '12115658',
        creationDate: DateTime(2023, 10, 7),
        status: UserStatus.habilitado,
        paidMembership: true,
        dateTimeWrapper: fakeDateTimeWrapper,
      );

      await box.put(user.id, user); // Add user to the box

      // Act
      user.updateMonthlyStatus();

      // Assert
      expect(user.paidMembership,
          true); // Should remain true since it's not the 1st of the month

      // Clean up
      await box.close();
    });
  });

  group('User status update logic', () {
    test(
        'Should change status to vencido if today is creationDate and paidMembership is false',
        () async {
      // Arrange
      final creationDate = DateTime(2023, 5, 7);
      final fakeDateTimeWrapper = FakeDateTimeWrapper(
          DateTime(2024, 11, 7)); // Same day, different year

      var box = await Hive.openBox<User>('testUsersBox');

      // Create the User and add it to the box
      final user = User(
        id: '55123',
        name: 'Anne',
        surname: 'Boonchuy',
        dni: '12115658',
        creationDate: creationDate,
        status: UserStatus.habilitado,
        paidMembership: false, // Paid membership is false
        dateTimeWrapper: fakeDateTimeWrapper,
      );

      await box.put(user.id, user); // Add user to the box

      // Act
      user.setStatus();

      // Assert
      expect(user.status, UserStatus.vencido);

      // Clean up
      await box.close();
    });
  });
}

class FakeDateTimeWrapper extends DateTimeWrapper {
  final DateTime fixedNow;
  FakeDateTimeWrapper(this.fixedNow);

  @override
  DateTime now() => fixedNow;
}
