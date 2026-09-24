import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/auth/permission_labels.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../di/injection.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../data/models/employee_summary.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  late Future<List<EmployeeSummary>> _employees;

  bool get _canCreate =>
      currentUserHasPerm(PermissionCodes.employeeCreate) &&
      currentUserHasPerm(PermissionCodes.employeePermissionManage);
  bool get _canRead => currentUserHasPerm(PermissionCodes.employeeRead);
  bool get _canUpdate =>
      currentUserHasPerm(PermissionCodes.employeeEdit) ||
      currentUserHasPerm(PermissionCodes.employeePermissionManage);
  bool get _isFirmAdmin {
    final session = getIt<SessionCubit>().state;
    return session is SessionAuthenticated && session.user.isFirmAdmin;
  }

  @override
  void initState() {
    super.initState();
    _employees = _canRead ? _loadEmployees() : Future.value(const []);
  }

  Future<List<EmployeeSummary>> _loadEmployees() async {
    final response = await getIt<Dio>().get('/employees');
    final rows = response.data as List<dynamic>;
    return rows
        .map((row) => EmployeeSummary.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  void _reload() => setState(() => _employees = _loadEmployees());

  Future<void> _createEmployee() async {
    if (!_canCreate) {
      final missing = <String>[
        if (!currentUserHasPerm(PermissionCodes.employeeCreate))
          PermissionCodes.employeeCreate,
        if (!currentUserHasPerm(PermissionCodes.employeePermissionManage))
          PermissionCodes.employeePermissionManage,
      ];
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.tr('employee_create_permission_title')),
          content: Text(
            '${context.tr('employee_create_permission_message')}\n\n'
            '${missing.map((code) => permissionLabel(context, code)).join('\n')}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr('confirm')),
            ),
          ],
        ),
      );
      return;
    }
    final created = await context.push<bool>(AppRouter.createEmployee);
    if (created == true && mounted) {
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('employee_invitation_pending'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: Text(context.tr('employees'))),
    floatingActionButton: _isFirmAdmin
        ? FloatingActionButton.extended(
            onPressed: _createEmployee,
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(context.tr('create_employee')),
          )
        : null,
    body: !_canRead
        ? _MissingEmployeePermissions(canCreate: _canCreate)
        : FutureBuilder<List<EmployeeSummary>>(
            future: _employees,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                final message = snapshot.error is DioException
                    ? mapDioError(snapshot.error as DioException).message
                    : context.tr('could_not_load_employees');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(height: AppSpacing.m),
                        Text(message, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.m),
                        AppButton(
                          text: context.tr('try_again'),
                          onPressed: _reload,
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final employees = snapshot.data!;
              if (employees.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.groups_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(context.tr('no_employees_found')),
                        if (_isFirmAdmin) ...[
                          const SizedBox(height: AppSpacing.l),
                          AppButton(
                            text: context.tr('create_employee'),
                            icon: Icons.person_add_alt_1,
                            onPressed: _createEmployee,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.m,
                    AppSpacing.m,
                    AppSpacing.m,
                    96,
                  ),
                  itemCount: employees.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.s),
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            employee.name.isEmpty
                                ? '?'
                                : employee.name.characters.first.toUpperCase(),
                          ),
                        ),
                        title: Text(
                          employee.name.isEmpty
                              ? context.tr('unnamed_employee')
                              : employee.name,
                        ),
                        subtitle: Text(
                          <String>[
                            employee.email,
                            employee.positionLabel,
                          ].where((value) => value.isNotEmpty).join('\n'),
                        ),
                        isThreeLine: employee.email.isNotEmpty,
                        trailing: _canUpdate
                            ? const Icon(Icons.edit_outlined)
                            : null,
                        onTap: _canUpdate
                            ? () async {
                                final updated = await context.push<bool>(
                                  AppRouter.editEmployee(employee.id),
                                );
                                if (updated == true && mounted) _reload();
                              }
                            : null,
                      ),
                    );
                  },
                ),
              );
            },
          ),
  );
}

class _MissingEmployeePermissions extends StatelessWidget {
  const _MissingEmployeePermissions({required this.canCreate});

  final bool canCreate;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 64, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.m),
          Text(
            context.tr('employee_read_permission_required'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          const Text(
            'employee.read',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (!canCreate) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              context.tr('employee_create_permissions_required'),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );
}
