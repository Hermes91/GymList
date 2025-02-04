import 'package:gymlist_flutter/models/user_status.dart';
import 'package:gymlist_flutter/services/user_service.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String surname;

  @HiveField(3)
  late String dni;

  @HiveField(4)
  late DateTime creationDate;

  @HiveField(5)
  late UserStatus status;

  @HiveField(6)
  late bool paidMembership;

  final DateTimeWrapper _dateTimeWrapper;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.dni,
    required this.creationDate,
    this.status = UserStatus.habilitado,
    this.paidMembership = true,
    DateTimeWrapper? dateTimeWrapper,
  }) : _dateTimeWrapper = dateTimeWrapper ?? DateTimeWrapper();

  /// Updates the user's status based on the current state of `paidMembership` and the date.
  void setStatus() {
    final now = _dateTimeWrapper.now();

    // If paidMembership is true, set status to habilitado unless suspended
    if (paidMembership) {
      if (status != UserStatus.suspendido) {
        status = UserStatus.habilitado;
      }
    } else {
      // If paidMembership is false, status depends on the day of creationDate
      if (now.day == creationDate.day && status != UserStatus.suspendido) {
        status = UserStatus.vencido;
      }
    }

    save(); // Save changes to Hive
  }

  /// Handles automatic status updates for monthly resets
  void updateMonthlyStatus() {
    final now = _dateTimeWrapper.now();

    // Reset `paidMembership` to false on the 1st of the month unless suspended
    if (now.day == 1 && status != UserStatus.suspendido) {
      paidMembership = false;
      save();
    }

    // Update the status immediately after resetting paidMembership
    setStatus();
  }
}
