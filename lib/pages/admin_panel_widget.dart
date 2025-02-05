import 'package:flutter/material.dart';
import 'package:gymlist_flutter/helpers/helpers.dart';
import 'package:gymlist_flutter/modals/edit_status_modal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/user_status.dart';
import '../services/user_service.dart';
import '../widgets/confirm_membership_modal.dart';

class AdminPanelWidget extends StatefulWidget {
  const AdminPanelWidget({super.key});

  @override
  State<AdminPanelWidget> createState() => _AdminPanelWidgetState();
}

class _AdminPanelWidgetState extends State<AdminPanelWidget> {
  final Box<User> userBox = Hive.box<User>('users');
  final UserService userService = UserService();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  User? selectedUser;
  UserStatus? selectedFilter;
  String searchQuery = '';

  void _showConfirmPaymentModal(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmPaymentModal(
          user: user,
          onConfirm: () {
            setState(() {
              user.paidMembership = true;
              user.setStatus();
            });
          },
        );
      },
    );
  }

  void _showEditModal(User user) {
    UserStatus? newStatus = user.status;
    showDialog(
      context: context,
      builder: (context) {
        return EditStatusModal(
          user: user,
          initialStatus: newStatus,
          onStatusChanged: (status) => newStatus = status,
          onSave: () {
            if (newStatus != null) {
              setState(() {
                userService.updateUserStatus(user, newStatus!);
              });
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers =
        userService.getFilteredUsers(searchQuery, selectedFilter);

    return Scaffold(
      backgroundColor: Color(0xFF2A2D34),
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style:
              TextStyle(color: Color(0xFF80C2AF), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2A2D34),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Search Field and Filter Dropdown
              Row(
                children: [
                  Flexible(
                    flex: 7,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar por nombre, apellido o DNI',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Filter Dropdown
                  Flexible(
                    flex: 3,
                    child: DropdownButton<UserStatus?>(
                      value: selectedFilter,
                      hint: const Text('Filtrar por estado'),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurple,
                      ),
                      items: [
                        DropdownMenuItem<UserStatus?>(
                          value: null,
                          child: const Text('Todos'), // Option to reset filter
                        ),
                        ...UserStatus.values.map((status) {
                          return DropdownMenuItem<UserStatus?>(
                            value: status,
                            child: Text(status.displayName),
                          );
                        }),
                      ],
                      onChanged: (newStatus) {
                        setState(() {
                          selectedFilter = newStatus; // Update the filter
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true, // Always show scrollbar thumb
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    scrollDirection:
                        Axis.vertical, // Vertical scrolling for long lists
                    child: Scrollbar(
                      controller: _horizontalController,
                      thumbVisibility: true, // Always show scrollbar
                      child: SingleChildScrollView(
                        controller: _horizontalController,
                        scrollDirection:
                            Axis.horizontal, // Horizontal scrolling
                        child: SizedBox(
                          width: 1200.0,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Nombre y Apellido')),
                              DataColumn(label: Text('DNI')),
                              DataColumn(label: Text('Estado')),
                              DataColumn(label: Text('Fecha de Alta')),
                              DataColumn(label: Text('Acciones')),
                            ],
                            rows: filteredUsers.map((user) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(
                                      '${capitalize(user.name)} ${capitalize(user.surname)}')),
                                  DataCell(Text(user.dni)),
                                  DataCell(Text(
                                    user.status.displayName,
                                    style: TextStyle(
                                        color: getStatusColor(user.status),
                                        fontWeight: FontWeight.bold),
                                  )),
                                  DataCell(Text(formatDate(user.creationDate))),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blueGrey),
                                          onPressed: () => _showEditModal(user),
                                        ),
                                        IconButton(
                                          icon: Opacity(
                                            opacity: user.status ==
                                                        UserStatus.suspendido ||
                                                    user.paidMembership
                                                ? 0.5
                                                : 1.0,
                                            child: Icon(
                                              Icons.check,
                                              color: user.status ==
                                                          UserStatus
                                                              .suspendido ||
                                                      user.paidMembership
                                                  ? Colors.grey
                                                  : Color(0xFF80C2AF),
                                            ),
                                          ),
                                          onPressed: user.status ==
                                                      UserStatus.suspendido ||
                                                  user.paidMembership
                                              ? null
                                              : () => _showConfirmPaymentModal(
                                                  user),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
