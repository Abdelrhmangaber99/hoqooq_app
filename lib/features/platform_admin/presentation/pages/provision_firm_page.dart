import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/auth/permission_labels.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/error_messages.dart';
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
  List<String> _firmAdminPermissions = const [];
  @override
  void initState() {
    super.initState();
    _provisioningDataFuture = _loadProvisioningData();
  }

  @override
  void dispose() {
    for (final c in [_firm, _contact, _name, _email]) {
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
        normalizePermissionCodes(
              PlatformAdminContract.permissionCodes(responses[1].data),
            )
            // Platform-management permissions cannot be delegated to a Firm
            // Admin. More importantly, never manufacture a code the backend
            // catalog did not return: its provisioning validation rejects it.
            .where(isFirmAdminGrantablePermission)
            .toList()
          ..sort();
    _firmAdminPermissions = permissionKeys;
    return _ProvisioningData(plans: plans);
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate() || _planId == null) {
      return;
    }
    if (_firmAdminPermissions.isEmpty) {
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
    final dio = getIt<Dio>();
    try {
      // Exactly the fields `ProvisionTenantDto` declares — no more. The
      // backend validates with `forbidNonWhitelisted`, so a single undeclared
      // key rejects the entire request ("property X should not exist",
      // surfaced here as the localized "unsupported field" message).
      // `adminPassword` and `permissionKeys` used to be sent here and made
      // provisioning impossible: the invited admin sets their own password
      // through the activation link, and the permission set is replaced below
      // through the endpoint that actually owns it.
      final response = await dio.post(
        '/tenants/provision',
        data: {
          'firmName': _firm.text.trim(),
          'firmContactEmail': _contact.text.trim(),
          'adminFullName': _name.text.trim(),
          'adminEmail': _email.text.trim(),
          'adminJobClassification': _classification,
          'planId': _planId,
          'billingCycle': _cycle,
        },
      );

      // The firm and its admin exist from here on, so a failure in the
      // permission step below must not be reported as a failed provision.
      final firmId = await _resolveProvisionedFirmId(dio, response.data);
      var permissionsApplied = false;
      if (firmId != null) {
        try {
          // `SetFirmAdminPermissionsDto` replaces the Firm Admin's whole
          // non-platform set with the codes the catalog actually returned
          // (platform/system codes are filtered out — the backend forbids
          // granting them to a tenant).
          await dio.patch(
            '/tenants/$firmId/firm-admin/permissions',
            data: {'permissionKeys': _firmAdminPermissions},
          );
          permissionsApplied = true;
        } on DioException {
          permissionsApplied = false;
        }
      }
      if (!permissionsApplied && mounted) {
        context.showErrorSnackBar(
          context.tr('firm_admin_permissions_not_applied'),
        );
      }
      if (mounted) {
        context.pop(true);
      }
    } on DioException catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          e.response?.data?['message']?.toString() ??
              context.tr('could_not_provision_firm'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  /// `POST /tenants/provision` is documented with a bare `201` and no response
  /// body schema, so the new firm's id is taken from whatever the server
  /// actually returned when that carries one, and otherwise looked up in the
  /// firm registry by the exact name and contact email just submitted (the
  /// same list the Firms screen renders). An ambiguous match is refused rather
  /// than guessed — a replaced permission set on the wrong firm would be worse
  /// than one left at the backend's default.
  Future<String?> _resolveProvisionedFirmId(Dio dio, Object? body) async {
    final fromBody =
        _idIn(body) ??
        _idIn(body is Map ? body['firm'] : null) ??
        _idIn(body is Map ? body['tenant'] : null);
    if (fromBody != null) return fromBody;

    final response = await dio.get('/tenants');
    final name = _firm.text.trim();
    final contact = _contact.text.trim();
    final matches = (response.data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .where((firm) => firm['name']?.toString().trim() == name)
        .where(
          (firm) =>
              contact.isEmpty ||
              firm['contactEmail']?.toString().trim() == contact,
        )
        .toList();
    return matches.length == 1 ? _idIn(matches.single) : null;
  }

  static String? _idIn(Object? value) {
    if (value is! Map) return null;
    final id = value['id'];
    return id is String && id.isNotEmpty ? id : null;
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.tr('firm_admin_invitation_note'),
                  style: Theme.of(context).textTheme.bodySmall,
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
  String? _required(String? value) => value == null || value.trim().isEmpty
      ? context.tr('field_required')
      : null;
}

class _ProvisioningData {
  const _ProvisioningData({required this.plans});

  final List<dynamic> plans;
}
