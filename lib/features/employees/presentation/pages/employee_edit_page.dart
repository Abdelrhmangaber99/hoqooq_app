import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/finance_permission_groups.dart';
import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/auth/permission_labels.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/error_messages.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/select_all_tile.dart';
import '../../../../di/injection.dart';

class EmployeeEditPage extends StatefulWidget {
  const EmployeeEditPage({super.key, required this.employeeId});

  final String employeeId;

  @override
  State<EmployeeEditPage> createState() => _EmployeeEditPageState();
}

class _EmployeeEditPageState extends State<EmployeeEditPage> {
  static const _positions = [
    'MANAGING_PARTNER',
    'PARTNER',
    'SENIOR_ASSOCIATE',
    'ASSOCIATE',
    'JUNIOR_LAWYER',
    'PARALEGAL',
    'LEGAL_ASSISTANT',
    'LEGAL_RESEARCHER',
    'SECRETARY',
    'ACCOUNTANT',
    'HR_MANAGER',
    'IT_SUPPORT',
    'GENERAL_MANAGER',
  ];
  static const _departments = [
    'LITIGATION',
    'CORPORATE',
    'REAL_ESTATE',
    'INTELLECTUAL_PROPERTY',
    'FAMILY_LAW',
    'CRIMINAL_LAW',
    'FINANCE',
    'HR',
    'ADMINISTRATION',
    'GENERAL',
  ];

  late Future<_EmployeeEditData> _data;
  bool _isGeneralSpecialization = true;
  String? _selectedSpecializationId;
  final Set<String> _permissions = {};
  String? _position;
  String? _department;
  DateTime _hireDate = DateTime.now();
  bool _initialized = false;
  bool _saving = false;

  bool get _canEdit => currentUserHasPerm(PermissionCodes.employeeEdit);
  bool get _canManagePermissions =>
      currentUserHasPerm(PermissionCodes.employeePermissionManage);

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_EmployeeEditData> _load() async {
    final employeeResponse = await getIt<Dio>().get(
      '/employees/${widget.employeeId}',
    );
    final employee = Map<String, dynamic>.from(employeeResponse.data as Map);
    var caseTypes = <_CaseType>[];
    if (_canEdit) {
      final response = await getIt<Dio>().get('/reference/case-types');
      caseTypes = (response.data as List)
          .map(
            (row) => _CaseType.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .toList();
    }
    var permissionCatalog = <String>[];
    var grantedPermissions = <String>[];
    if (_canManagePermissions) {
      final responses = await Future.wait([
        getIt<Dio>().get('/permissions'),
        getIt<Dio>().get('/employees/${widget.employeeId}/permissions'),
      ]);
      // The server already limits this to the codes the calling Firm Admin
      // holds; the extra filter drops the codes the desktop app's own editor
      // withholds (dashboard/calendar/notification/reference/firm-profile/
      // platform/system, plus `report.view`/`audit.view`/
      // `employee.status.manage`) so both clients offer the same checkbox set.
      permissionCatalog = normalizePermissionCodes(
        ((responses[0].data as Map)['codes'] as List? ?? const [])
            .whereType<String>()
            .where(isEmployeeGrantablePermission),
      );
      grantedPermissions = List<String>.from(
        (responses[1].data as Map)['grantedPermissions'] as List? ?? const [],
      );
    }
    return _EmployeeEditData(
      employee: employee,
      caseTypes: caseTypes,
      permissionCatalog: permissionCatalog,
      grantedPermissions: grantedPermissions,
    );
  }

  void _initialize(_EmployeeEditData data) {
    if (_initialized) return;
    _initialized = true;
    _position = data.employee['position']?.toString();
    _department = data.employee['department']?.toString();
    _hireDate =
        DateTime.tryParse(data.employee['hireDate']?.toString() ?? '') ??
        DateTime.now();
    final isGeneral = data.employee['isGeneralSpecialization'] == true;
    final specId = data.employee['specializationId']?.toString();
    if (isGeneral) {
      _isGeneralSpecialization = true;
      _selectedSpecializationId = null;
    } else if (specId != null && specId.isNotEmpty) {
      _isGeneralSpecialization = false;
      _selectedSpecializationId = specId;
    } else {
      _isGeneralSpecialization = true;
      _selectedSpecializationId = null;
    }
    _permissions.addAll(data.grantedPermissions);
  }

  /// Saves the profile fields and, separately, the permission grants.
  ///
  /// They are two independent `PATCH` calls to two different routes, so a
  /// profile rejection (an unsupported `specializationId`, a validation error
  /// on `hireDate`) must not silently discard the permission set the admin
  /// just ticked — one shared `try` block meant the permissions call was never
  /// reached, and the employee kept signing in with no access at all while the
  /// screen flashed one unrelated error. Each half now reports its own
  /// outcome; the screen stays open if either failed.
  Future<void> _save() async {
    setState(() => _saving = true);
    // Raw per-call failures, localized only after both requests have settled —
    // reading `BuildContext` inside a `catch` that follows an `await` is both
    // a lint violation and a real hazard if the page was popped meanwhile.
    final failures = <(String prefix, String message)>[];
    // Every label is resolved before the first `await`.
    final profilePrefix = context.tr('employee_profile_save_failed');
    final permissionsPrefix = context.tr('employee_permissions_save_failed');
    try {
      if (_canEdit) {
        final patchData = <String, dynamic>{
          if (_position != null) 'position': _position,
          if (_department != null) 'department': _department,
          'hireDate': _dateValue(_hireDate),
        };
        if (_isGeneralSpecialization) {
          patchData['generalSpecialization'] = true;
        } else if (_selectedSpecializationId != null) {
          patchData['specializationId'] = _selectedSpecializationId;
          patchData['generalSpecialization'] = false;
        }
        try {
          await getIt<Dio>().patch(
            '/employees/${widget.employeeId}',
            data: patchData,
          );
        } on DioException catch (error) {
          failures.add((profilePrefix, mapDioError(error).message));
        }
      }
      if (_canManagePermissions) {
        try {
          await getIt<Dio>().patch(
            '/employees/${widget.employeeId}/permissions',
            data: {'permissionKeys': _permissions.toList()..sort()},
          );
        } on DioException catch (error) {
          failures.add((permissionsPrefix, mapDioError(error).message));
        }
      }
      if (!mounted) return;
      if (failures.isEmpty) {
        Navigator.pop(context, true);
        return;
      }
      context.showErrorSnackBar(
        failures
            .map(
              (failure) =>
                  '${failure.$1}: ${localizedErrorMessage(context, failure.$2)}',
            )
            .join('\n'),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _hireDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _hireDate = date);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: Text(context.tr('edit_employee'))),
    body: FutureBuilder<_EmployeeEditData>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final message = snapshot.error is DioException
              ? mapDioError(snapshot.error as DioException).message
              : context.tr('could_not_load_employee');
          return Center(
            child: Text(
              localizedErrorMessage(context, message),
              textAlign: TextAlign.center,
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        _initialize(data);
        final user = data.employee['user'] as Map?;
        final isLawyerClassification =
            user?['jobClassification'] == 'LAWYER' ||
            data.employee['jobClassification'] == 'LAWYER';
        final hasLawyerSpecializations =
            isLawyerClassification ||
            data.employee['isGeneralSpecialization'] == true ||
            data.employee['specializationId'] != null ||
            (data.employee['specializations'] as List?)?.isNotEmpty == true;
        final hasLawyerPosition = const {
          'MANAGING_PARTNER',
          'PARTNER',
          'SENIOR_ASSOCIATE',
          'ASSOCIATE',
          'JUNIOR_LAWYER',
        }.contains(_position);
        final basePermissions = _permissionCodes(data, excludeFinance: true);
        final caseFinancePermissions = _permissionCodes(
          data,
          caseFinanceOnly: true,
        );
        final firmFinancePermissions = _permissionCodes(
          data,
          firmFinanceOnly: true,
        );
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            Text(
              user?['fullName']?.toString() ?? context.tr('unnamed_employee'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(user?['email']?.toString() ?? ''),
            if (_canEdit) ...[
              const SizedBox(height: AppSpacing.l),
              _dropdown(
                context.tr('employee_position'),
                _position,
                _positions,
                (value) => setState(() => _position = value),
              ),
              const SizedBox(height: AppSpacing.m),
              _dropdown(
                context.tr('department_optional'),
                _department,
                _departments,
                (value) => setState(() => _department = value),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('hire_date')),
                subtitle: Text(_dateValue(_hireDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickDate,
              ),
              if (hasLawyerSpecializations) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  context.tr('lawyer_specializations'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  children: [
                    ChoiceChip(
                      label: Text(context.tr('specialization_general')),
                      selected: _isGeneralSpecialization,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _isGeneralSpecialization = true;
                            _selectedSpecializationId = null;
                          });
                        }
                      },
                    ),
                    ...data.caseTypes.map((item) {
                      final isSelected =
                          !_isGeneralSpecialization &&
                          _selectedSpecializationId == item.id;
                      return ChoiceChip(
                        label: Text(
                          item.labelFor(
                            Localizations.localeOf(context).languageCode,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _isGeneralSpecialization = false;
                              _selectedSpecializationId = item.id;
                            } else {
                              _isGeneralSpecialization = true;
                              _selectedSpecializationId = null;
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ] else if (hasLawyerPosition) ...[
                const SizedBox(height: AppSpacing.m),
                Card(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Text(
                      context.tr('lawyer_position_not_classification'),
                    ),
                  ),
                ),
              ],
            ],
            if (_canManagePermissions) ...[
              const SizedBox(height: AppSpacing.l),
              // Word-for-word the explanation the desktop app shows above this
              // same editor. Without it, a Firm Admin grants every permission
              // and still finds an employee with an empty Cases/Tasks/Hearings
              // board — because those codes only grant *capabilities*, while
              // the records themselves are scoped per case by the backend and
              // require the employee to be added to the case first.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brass50,
                  border: Border.all(color: AppColors.brass200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.tr('employee_permissions_scope_note'),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.ink700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                context.tr('base_permissions'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SelectAllTile(
                keys: basePermissions,
                selected: _permissions,
                onChanged: (all) => _togglePermissions(basePermissions, all),
              ),
              ...basePermissions.map(
                (code) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(permissionLabel(context, code)),
                  value: _permissions.contains(code),
                  onChanged: (selected) => setState(() {
                    selected == true
                        ? _permissions.add(code)
                        : _permissions.remove(code);
                  }),
                ),
              ),
              if (caseFinancePermissions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  context.tr('case_finance_permissions'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SelectAllTile(
                  keys: caseFinancePermissions,
                  selected: _permissions,
                  onChanged: (all) =>
                      _togglePermissions(caseFinancePermissions, all),
                ),
                ...caseFinancePermissions.map(
                  (code) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(permissionLabel(context, code)),
                    value: _permissions.contains(code),
                    onChanged: (selected) => setState(() {
                      selected == true
                          ? _permissions.add(code)
                          : _permissions.remove(code);
                    }),
                  ),
                ),
              ],
              if (firmFinancePermissions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  context.tr('firm_finance_permission'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SelectAllTile(
                  keys: firmFinancePermissions,
                  selected: _permissions,
                  onChanged: (all) =>
                      _togglePermissions(firmFinancePermissions, all),
                ),
                ...firmFinancePermissions.map(
                  (code) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(permissionLabel(context, code)),
                    value: _permissions.contains(code),
                    onChanged: (selected) => setState(() {
                      selected == true
                          ? _permissions.add(code)
                          : _permissions.remove(code);
                    }),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s),
                child: Text(
                  context.tr('finance_permission_classification_note'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.l),
            AppButton(
              text: context.tr('save_employee'),
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        );
      },
    ),
  );

  Widget _dropdown(
    String label,
    String? value,
    List<String> values,
    ValueChanged<String?> onChanged,
  ) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: values
        .map(
          (item) =>
              DropdownMenuItem(value: item, child: Text(_optionLabel(item))),
        )
        .toList(),
    onChanged: onChanged,
  );

  void _togglePermissions(Iterable<String> codes, bool select) => setState(() {
    if (select) {
      _permissions.addAll(codes);
    } else {
      _permissions.removeAll(codes);
    }
  });

  static List<String> _permissionCodes(
    _EmployeeEditData data, {
    bool excludeFinance = false,
    bool caseFinanceOnly = false,
    bool firmFinanceOnly = false,
  }) {
    final catalog = data.permissionCatalog;
    if (caseFinanceOnly) return FinancePermissionGroups.caseFinanceOf(catalog);
    if (firmFinanceOnly) return FinancePermissionGroups.firmFinanceOf(catalog);
    if (excludeFinance) {
      return FinancePermissionGroups.excludingFinance(catalog);
    }
    return catalog;
  }

  static String _humanize(String value) => value
      .split('_')
      .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
      .join(' ');

  String _optionLabel(String value) {
    final key = 'employee_option_${value.toLowerCase()}';
    final translated = context.tr(key);
    return translated == key ? _humanize(value) : translated;
  }

  static String _dateValue(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class _EmployeeEditData {
  const _EmployeeEditData({
    required this.employee,
    required this.caseTypes,
    required this.permissionCatalog,
    required this.grantedPermissions,
  });

  final Map<String, dynamic> employee;
  final List<_CaseType> caseTypes;
  final List<String> permissionCatalog;
  final List<String> grantedPermissions;
}

class _CaseType {
  const _CaseType({required this.id, required this.en, required this.ar});
  final String id;
  final String en;
  final String ar;

  factory _CaseType.fromJson(Map<String, dynamic> json) => _CaseType(
    id: json['id'] as String,
    en: json['labelEn']?.toString() ?? '',
    ar: json['labelAr']?.toString() ?? '',
  );

  String labelFor(String languageCode) => languageCode == 'ar' ? ar : en;
}
