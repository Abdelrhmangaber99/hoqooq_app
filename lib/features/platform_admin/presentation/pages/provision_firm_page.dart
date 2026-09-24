import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/auth/permission_labels.dart';
import '../../../../di/injection.dart';
import '../../domain/firm_admin_permissions.dart';
import '../../domain/platform_admin_contract.dart';

class ProvisionFirmPage extends StatefulWidget {
  const ProvisionFirmPage({super.key});
  @override
  State<ProvisionFirmPage> createState() => _ProvisionFirmPageState();
}

class _ProvisionFirmPageState extends State<ProvisionFirmPage> {
  final _key = GlobalKey<FormState>();
  final _firm = TextEditingController();
  final _contact = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _planId;
  String _cycle = 'MONTHLY';
  // A Firm Admin is an account type, not necessarily a lawyer. Sending
  // `LAWYER` makes the API require lawyer specializations, which this
  // provisioning endpoint does not accept. `OTHER` avoids that unrelated
  // professional-profile validation while still supplying the required DTO
  // classification.
  static const String _classification = 'OTHER';
  bool _saving = false;
  late final Future<_ProvisioningData> _provisioningDataFuture;
  // Permissions start empty. The Super Admin explicitly selects every
  // capability granted to a Firm Admin; no hidden full-access template.
  final _permissions = <String>{};
  @override
  void initState() {
    super.initState();
    _provisioningDataFuture = _loadProvisioningData();
  }

  @override
  void dispose() {
    for (final c in [_firm, _contact, _name, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<_ProvisioningData> _loadProvisioningData() async {
    final responses = await Future.wait([
      getIt<Dio>().get('/subscriptions/plans'),
      getIt<Dio>().get('/permissions'),
    ]);
    final plans = responses[0].data as List<dynamic>;
    if (plans.isNotEmpty) {
      _planId ??= (plans.first as Map<String, dynamic>)['id'] as String;
    }
    final permissionKeys =
        PlatformAdminContract.permissionCodes(responses[1].data)
            // Platform-management permissions cannot be delegated to a Firm
            // Admin. More importantly, never manufacture a code the backend
            // catalog did not return: its provisioning validation rejects it.
            .where(isFirmAdminGrantablePermission)
            .toList()
          ..sort();
    return _ProvisioningData(plans: plans, permissionKeys: permissionKeys);
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate() || _planId == null) {
      return;
    }
    if (_permissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('select_at_least_one_firm_admin_permission'),
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await getIt<Dio>().post(
        '/tenants/provision',
        data: {
          'firmName': _firm.text.trim(),
          'firmContactEmail': _contact.text.trim(),
          'adminFullName': _name.text.trim(),
          'adminEmail': _email.text.trim(),
          if (_password.text.isNotEmpty) 'adminPassword': _password.text,
          'adminJobClassification': _classification,
          'permissionKeys': _permissions.toList(),
          'planId': _planId,
          'billingCycle': _cycle,
        },
      );
      if (mounted) {
        context.pop(true);
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.data?['message']?.toString() ??
                  'Could not provision this firm.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: Text(context.tr('provision_firm'))),
    body: FutureBuilder<_ProvisioningData>(
      future: _provisioningDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final plans = data.plans;
        if (plans.isEmpty) {
          return Center(child: Text(context.tr('no_subscription_plans')));
        }
        return SafeArea(
          child: Form(
            key: _key,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                Text(context.tr('firm_details')),
                const SizedBox(height: AppSpacing.m),
                AppTextField(
                  label: context.tr('firm_name'),
                  controller: _firm,
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.m),
                AppTextField(
                  label: context.tr('firm_contact_email'),
                  controller: _contact,
                  keyboardType: TextInputType.emailAddress,
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.l),
                Text(context.tr('initial_firm_admin')),
                const SizedBox(height: AppSpacing.m),
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
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.m),
                AppTextField(
                  label: '${context.tr('temporary_password')} (optional)',
                  controller: _password,
                  isPassword: true,
                  validator: (v) => v != null && v.isNotEmpty && v.length < 8
                      ? 'Use at least 8 characters or leave it empty'
                      : null,
                ),
                const SizedBox(height: AppSpacing.l),
                AppDropdownField<String>(
                  label: context.tr('subscription_plan'),
                  value: _planId!,
                  items: plans.map(
                    (p) => (p as Map<String, dynamic>)['id'] as String,
                  ),
                  labelOf: (id) {
                    final p = plans.cast<Map<String, dynamic>>().firstWhere(
                      (p) => p['id'] == id,
                    );
                    return p['name'] as String? ?? id;
                  },
                  onChanged: (v) => setState(() => _planId = v),
                ),
                const SizedBox(height: AppSpacing.m),
                ExpansionTile(
                  title: Text(context.tr('firm_admin_permissions')),
                  subtitle: Text(
                    '${_permissions.length} ${context.tr('permissions_selected')}',
                  ),
                  children: data.permissionKeys
                      .map(
                        (permission) => CheckboxListTile(
                          title: Text(permissionLabel(context, permission)),
                          value: _permissions.contains(permission),
                          onChanged: (selected) => setState(() {
                            if (selected ?? false) {
                              _permissions.add(permission);
                            } else {
                              _permissions.remove(permission);
                            }
                          }),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.m),
                AppDropdownField<String>(
                  label: context.tr('billing_cycle'),
                  value: _cycle,
                  items: const ['MONTHLY', 'YEARLY'],
                  labelOf: (v) => v[0] + v.substring(1).toLowerCase(),
                  onChanged: (v) => setState(() => _cycle = v!),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: context.tr('create_firm_and_admin'),
                  isLoading: _saving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
}

class _ProvisioningData {
  const _ProvisioningData({required this.plans, required this.permissionKeys});

  final List<dynamic> plans;
  final List<String> permissionKeys;
}
