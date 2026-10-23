import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/auth/permission_labels.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/error_messages.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/router/app_route_observer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../data/employee_status_api.dart';
import '../../data/models/employee_summary.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> with RouteAware {
  late Future<List<EmployeeSummary>> _employees;

  bool get _canCreate =>
      currentUserHasPerm(PermissionCodes.employeeCreate) &&
      currentUserHasPerm(PermissionCodes.employeePermissionManage);
  bool get _canRead => currentUserHasPerm(PermissionCodes.employeeRead);
  bool get _canUpdate =>
      currentUserHasPerm(PermissionCodes.employeeEdit) ||
      currentUserHasPerm(PermissionCodes.employeePermissionManage);
  bool get _canManageStatus =>
      _isFirmAdmin || currentUserHasPerm(PermissionCodes.employeeStatusManage);
  bool get _isFirmAdmin {
    final session = getIt<SessionCubit>().state;
    return session is SessionAuthenticated && session.user.isFirmAdmin;
  }

  @override
  void initState() {
    super.initState();
    _employees = _canRead ? _loadEmployees() : Future.value(const []);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscribeToAppRouteObserver(context, this);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// The employee list was covered by the create/edit screen and is visible
  /// again: re-read it, whichever way that screen was left.
  @override
  void didPopNext() {
    if (mounted && _canRead) _reload();
  }

  Future<List<EmployeeSummary>> _loadEmployees() async {
    final response = await getIt<Dio>().get('/employees');
    final rows = response.data as List<dynamic>;
    return rows
        .map((row) => EmployeeSummary.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  void _reload() => setState(() => _employees = _loadEmployees());

  /// Deactivates the employee through `DELETE /employees/:id`, the only
  /// lifecycle route the deployed backend exposes (it has no
  /// `PATCH /employees/:id/status`, and no reactivation endpoint either — see
  /// `employee_status_api.dart`). Kept behind a confirmation because, without
  /// a reactivation route, this cannot be undone from the app.
  Future<void> _deactivateEmployee(EmployeeSummary employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('delete_employee')),
        content: Text(context.tr('delete_employee_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await deactivateEmployee(getIt<Dio>(), employee.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('employee_deactivated_successfully')),
        ),
      );
      // The archived employee no longer belongs in the list: re-read the
      // server list instead of only flipping a local status flag.
      _reload();
    } on DioException catch (error) {
      if (mounted) {
        context.showErrorSnackBar(_deactivationErrorMessage(error));
      }
    }
  }

  /// The backend refuses to deactivate an employee who still owns open work:
  ///
  /// `Forbidden — Cannot deactivate user with open assignments: 3 primary
  /// Case(s), 5 Task(s), 2 Hearing(s)`
  ///
  /// The reference desktop app parses that sentence and rewrites it as
  /// "reassign their workload first" with the counts, because the raw string
  /// reads like a permissions problem. Same treatment here, falling back to the
  /// plain mapped message when the shape ever changes.
  String _deactivationErrorMessage(DioException error) {
    final mapped = mapDioError(error);
    final match = RegExp(
      r'open assignments: (\d+) primary Case\(s\), (\d+) Task\(s\)',
    ).firstMatch(mapped.message);
    if (match == null) return localizedErrorMessage(context, mapped.message);
    return context
        .tr('employee_has_open_assignments')
        .replaceAll('{cases}', match.group(1)!)
        .replaceAll('{tasks}', match.group(2)!);
  }

  /// `POST /employees/:id/credentials` — replaces the employee's password and
  /// signs them out everywhere. Firm-Admin-only, exactly like the desktop app,
  /// which reveals this action only for `accountType === 'FIRM_ADMIN'`.
  Future<void> _setNewPassword(EmployeeSummary employee) async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      final submitted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.tr('set_new_password')),
          content: Form(
            key: formKey,
            child: AppTextField(
              label: context.tr('new_password'),
              controller: passwordController,
              obscureText: true,
              validator: (value) {
                final text = value ?? '';
                if (text.isEmpty) return context.tr('field_required');
                final strong = text.length >= 8 &&
                    RegExp(r'[A-Z]').hasMatch(text) &&
                    RegExp(r'[a-z]').hasMatch(text) &&
                    RegExp(r'[0-9]').hasMatch(text) &&
                    RegExp(r'[^A-Za-z0-9]').hasMatch(text);
                return strong ? null : context.tr('password_min_8');
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.pop(dialogContext, true);
              },
              child: Text(context.tr('confirm')),
            ),
          ],
        ),
      );
      if (submitted != true) return;
      await setEmployeeCredentials(
        getIt<Dio>(),
        employee.id,
        passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('set_password_success'))),
      );
    } on DioException catch (error) {
      if (mounted) {
        context.showErrorSnackBar(mapDioError(error).message);
      }
    } finally {
      passwordController.dispose();
    }
  }

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
    if (!mounted) return;
    // Re-read on return regardless of the popped result: the create screen can
    // be left in ways that carry no result, and a stale list is worse than one
    // extra request.
    _reload();
    if (created == true) {
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
                        Text(
                          localizedErrorMessage(context, message),
                          textAlign: TextAlign.center,
                        ),
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
                        leading: AppAvatar(
                          name: employee.name,
                          imageUrl: employee.avatarUrl,
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
                            '${context.tr('status')}: ${employee.isActive ? context.tr('active') : context.tr('inactive')}',
                          ].where((value) => value.isNotEmpty).join('\n'),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Firm-Admin-only on both clients — the desktop's
                            // row action is gated on `isFirmAdmin`, never on a
                            // permission code, and matches the backend route.
                            if (_isFirmAdmin)
                              IconButton(
                                icon: const Icon(Icons.key_outlined),
                                tooltip: context.tr('set_new_password'),
                                onPressed: () => _setNewPassword(employee),
                              ),
                            if (_canManageStatus)
                              IconButton(
                                icon: const Icon(
                                  Icons.person_off_outlined,
                                  color: AppColors.error,
                                ),
                                tooltip: context.tr('delete_employee'),
                                onPressed: () => _deactivateEmployee(employee),
                              ),
                            if (_canUpdate)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: context.tr('edit_employee'),
                                onPressed: () async {
                                  await context.push<bool>(
                                    AppRouter.editEmployee(employee.id),
                                  );
                                  if (mounted) _reload();
                                },
                              ),
                          ],
                        ),
                        onTap: _canUpdate
                            ? () async {
                                await context.push<bool>(
                                  AppRouter.editEmployee(employee.id),
                                );
                                if (mounted) _reload();
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
