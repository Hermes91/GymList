import 'package:hive/hive.dart';

part 'user_status.g.dart';

@HiveType(typeId: 1) // Asegúrate de que typeId sea único
enum UserStatus {
  @HiveField(0)
  habilitado,

  @HiveField(1)
  vencido,

  @HiveField(2)
  suspendido,
}

extension UserStatusExtension on UserStatus {
  String get displayName {
    switch (this) {
      case UserStatus.habilitado:
        return 'Habilitado';
      case UserStatus.vencido:
        return 'Vencido';
      case UserStatus.suspendido:
        return 'Suspendido';
    }
  }

  static UserStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'habilitado':
        return UserStatus.habilitado;
      case 'vencido':
        return UserStatus.vencido;
      case 'suspendido':
        return UserStatus.suspendido;
      default:
        throw ArgumentError('Invalid UserStatus: $status');
    }
  }
}
