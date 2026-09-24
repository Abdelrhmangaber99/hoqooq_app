import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/finance_permission_groups.dart';
import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/auth/permission_labels.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
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
  final Set<String> _specializations = {};
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
      permissionCatalog = List<String>.from(
        (responses[0].data as Map)['codes'] as List? ?? const [],
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
    _specializations.addAll(
      List<String>.from(data.employee['specializations'] as List? ?? const []),
    );
    _permissions.addAll(data.grantedPermissions);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (_canEdit) {
        await getIt<Dio>().patch(
          '/employees/${widget.employeeId}',
          data: {
            'position': _position,
            'department': _department,
            'hireDate': _dateValue(_hireDate),
            'specializations': _specializations.toList(),
          },
        );
      }
      if (_canManagePermissions) {
        await getIt<Dio>().patch(
          '/employees/${widget.employeeId}/permissions',
          data: {'permissionKeys': _permissions.toList()..sort()},
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on DioException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mapDioError(error).message)));
      }
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
          return Center(child: Text(message, textAlign: TextAlign.center));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        _initialize(data);
        final user = data.employee['user'] as Map?;
        final hasLawyerSpecializations =
            (data.employee['specializations'] as List?)?.isNotEmpty == true;
        final hasLawyerPosition = const {
          'MANAGING_PARTNER',
          'PARTNER',
          'SENIOR_ASSOCIATE',
          'ASSOCIATE',
          'JUNIOR_LAWYER',
        }.contains(_position);
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
                  children: data.caseTypes.map((item) {
                    final selected = _specializations.contains(item.id);
                    return FilterChip(
                      label: Text(
                        item.labelFor(
                          Localizations.localeOf(context).languageCode,
                        ),
                      ),
                      selected: selected,
                      onSelected: (value) => setState(() {
                        value
                            ? _specializations.add(item.id)
                            : _specializations.remove(item.id);
                      }),
                    );
                  }).toList(),
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
              Text(
                context.tr('base_permissions'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ..._permissionCodes(data, excludeFinance: true).map(
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
              // Case-level finance permissions, selectable independently of
              // every other group (PRD v2.0 BR-028): an employee can hold
              // finance.case.view + finance.payment.record with no
              // document.view, and vice versa.
              if (_permissionCodes(data, caseFinanceOnly: true).isNotEmpty) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  context.tr('case_finance_permissions'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ..._permissionCodes(data, caseFinanceOnly: true).map(
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
              // Firm-wide finance is a single explicit grant — distinct from
              // the case-level group above.
              if (_permissionCodes(data, firmFinanceOnly: true).isNotEmpty) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  context.tr('firm_finance_permission'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ..._permissionCodes(data, firmFinanceOnly: true).map(
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

  /// Filters the server-provided permission catalog for the permission
  /// sections. The catalog itself is authoritative (server decides what this
  /// admin may manage); this only slices it into groups for display.
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
