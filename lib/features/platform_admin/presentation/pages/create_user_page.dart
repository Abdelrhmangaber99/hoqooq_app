import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/auth/permission_labels.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';

/// Firm-scoped employee onboarding. The backend sends an activation
/// invitation, so this form deliberately does not collect a password.
class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  static const _classifications = [
    'LAWYER',
    'SECRETARY',
    'ACCOUNTANT',
    'ASSISTANT',
    'OTHER',
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
  static const _lawyerPositions = [
    'MANAGING_PARTNER',
    'PARTNER',
    'SENIOR_ASSOCIATE',
    'ASSOCIATE',
    'JUNIOR_LAWYER',
    'PARALEGAL',
    'LEGAL_ASSISTANT',
    'LEGAL_RESEARCHER',
  ];

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final Set<String> _selectedPermissions = {};
  final Set<String> _selectedSpecializations = {};
  late Future<_ReferenceData> _referenceData;
  String? _classification;
  String _lawyerPosition = 'ASSOCIATE';
  String? _department;
  DateTime _hireDate = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _referenceData = _loadReferenceData();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<_ReferenceData> _loadReferenceData() async {
    final responses = await Future.wait([
      getIt<Dio>().get('/permissions'),
      getIt<Dio>().get('/reference/case-types'),
    ]);
    final permissionData = responses[0].data as Map<String, dynamic>;
    final permissionCodes = List<String>.from(
      permissionData['codes'] as List? ?? const [],
    );
    final caseTypes = (responses[1].data as List<dynamic>)
        .map((row) => _CaseType.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
    return _ReferenceData(
      permissionCodes: permissionCodes,
      caseTypes: caseTypes,
    );
  }

  Future<void> _pickHireDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _hireDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (selected != null) setState(() => _hireDate = selected);
  }

  Future<void> _submit() async {
    final isLawyer = _classification == 'LAWYER';
    if (!_formKey.currentState!.validate() ||
        _classification == null ||
        _selectedPermissions.isEmpty ||
        (isLawyer && _selectedSpecializations.isEmpty)) {
      _showMessage(context.tr('complete_all_employee_fields'));
      return;
    }
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'fullName': _name.text.trim(),
        'email': _email.text.trim(),
        'jobClassification': _classification,
        'hireDate': _dateValue(_hireDate),
        'permissionKeys': _selectedPermissions.toList()..sort(),
      };
      final phone = _phone.text.trim();
      if (phone.isNotEmpty) data['phone'] = phone;
      if (_department != null) data['department'] = _department;
      if (isLawyer) {
        data['specializations'] = _selectedSpecializations.toList();
      }
      final response = await getIt<Dio>().post(
        '/employees/onboard',
        data: data,
      );
      if (isLawyer &&
          _lawyerPosition != 'ASSOCIATE' &&
          currentUserHasPerm(PermissionCodes.employeeEdit)) {
        final employee = response.data as Map?;
        final employeeId = employee?['id']?.toString();
        if (employeeId != null) {
          await getIt<Dio>().patch(
            '/employees/$employeeId',
            data: {'position': _lawyerPosition},
          );
        }
      }
      if (mounted) Navigator.pop(context, true);
    } on DioException catch (error) {
      if (mounted) _showMessage(mapDioError(error).message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: Text(context.tr('create_employee'))),
    body: FutureBuilder<_ReferenceData>(
      future: _referenceData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final message = snapshot.error is DioException
              ? mapDioError(snapshot.error as DioException).message
              : context.tr('could_not_load_employee_setup');
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
                    onPressed: () =>
                        setState(() => _referenceData = _loadReferenceData()),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildForm(snapshot.data!);
      },
    ),
  );

  Widget _buildForm(_ReferenceData data) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            AppTextField(
              label: context.tr('full_name'),
              controller: _name,
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: context.tr('email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: context.tr('phone'),
              controller: _phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.m),
            _dropdown(
              label: context.tr('job_classification'),
              value: _classification,
              values: _classifications,
              onChanged: (value) => setState(() {
                _classification = value;
                if (value != 'LAWYER') _selectedSpecializations.clear();
              }),
            ),
            const SizedBox(height: AppSpacing.m),
            _dropdown(
              label: context.tr('department_optional'),
              value: _department,
              values: _departments,
              onChanged: (value) => setState(() => _department = value),
              optional: true,
            ),
            const SizedBox(height: AppSpacing.m),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('hire_date')),
              subtitle: Text(_dateValue(_hireDate)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickHireDate,
            ),
            if (_classification == 'LAWYER') ...[
              const SizedBox(height: AppSpacing.m),
              if (currentUserHasPerm(PermissionCodes.employeeEdit)) ...[
                _dropdown(
                  label: context.tr('employee_position'),
                  value: _lawyerPosition,
                  values: _lawyerPositions,
                  onChanged: (value) =>
                      setState(() => _lawyerPosition = value ?? 'ASSOCIATE'),
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              Text(
                context.tr('lawyer_specializations'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: data.caseTypes.map((caseType) {
                  final selected = _selectedSpecializations.contains(
                    caseType.id,
                  );
                  return FilterChip(
                    label: Text(caseType.labelFor(languageCode)),
                    selected: selected,
                    onSelected: (value) => setState(() {
                      value
                          ? _selectedSpecializations.add(caseType.id)
                          : _selectedSpecializations.remove(caseType.id);
                    }),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.l),
            Text(
              context.tr('base_permissions'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(context.tr('employee_permissions_explanation')),
            const SizedBox(height: AppSpacing.s),
            ...data.permissionCodes.map(
              (code) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(permissionLabel(context, code)),
                value: _selectedPermissions.contains(code),
                onChanged: (selected) => setState(() {
                  selected == true
                      ? _selectedPermissions.add(code)
                      : _selectedPermissions.remove(code);
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              text: context.tr('create_employee'),
              isLoading: _saving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
    bool optional = false,
  }) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: values
        .map(
          (item) =>
              DropdownMenuItem(value: item, child: Text(_optionLabel(item))),
        )
        .toList(),
    onChanged: onChanged,
    validator: optional
        ? null
        : (value) => value == null ? context.tr('field_required') : null,
  );

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? context.tr('field_required')
      : null;

  String? _emailValidator(String? value) =>
      _required(value) ??
      (!(value?.contains('@') ?? false) ? context.tr('invalid_email') : null);

  static String _dateValue(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static String _humanize(String value) => value
      .split('_')
      .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
      .join(' ');

  String _optionLabel(String value) {
    final key = 'employee_option_${value.toLowerCase()}';
    final translated = context.tr(key);
    return translated == key ? _humanize(value) : translated;
  }
}

class _ReferenceData {
  const _ReferenceData({
    required this.permissionCodes,
    required this.caseTypes,
  });

  final List<String> permissionCodes;
  final List<_CaseType> caseTypes;
}

class _CaseType {
  const _CaseType({
    required this.id,
    required this.labelEn,
    required this.labelAr,
  });

  final String id;
  final String labelEn;
  final String labelAr;

  factory _CaseType.fromJson(Map<String, dynamic> json) => _CaseType(
    id: json['id'] as String,
    labelEn: json['labelEn']?.toString() ?? json['label']?.toString() ?? '',
    labelAr: json['labelAr']?.toString() ?? json['label']?.toString() ?? '',
  );

  String labelFor(String languageCode) =>
      languageCode == 'ar' ? labelAr : labelEn;
}
