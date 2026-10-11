import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../di/injection.dart';

/// Super Admin view of a firm's Firm Admin account.
///
/// The account's details come from the deployed platform registry
/// (`GET /tenants` / `GET /tenants/:id` return `{firm, firmAdmin,
/// currentSubscription}` — verified live against the deployed API on
/// 2026-10-11), because that is the only place a Super Admin can read them:
/// the deployed backend has no `GET /users` at all, and answers
/// `GET /employees` with `403 "Platform accounts cannot access firm legal
/// resources"`.
///
/// Status changes use the platform account-status route
/// (`PATCH /users/:id/status`) where it exists. The deployed backend does not
/// expose any per-account status route, so deactivation there is not possible
/// from here and the page says so plainly rather than reporting a raw 404.
class FirmAdminDetailsPage extends StatefulWidget {
  const FirmAdminDetailsPage({
    super.key,
    required this.firm,
    required this.admin,
  });

  final Map<String, dynamic> firm;
  final Map<String, dynamic> admin;

  String _value(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '—' : text;
  }

  @override
  State<FirmAdminDetailsPage> createState() => _FirmAdminDetailsPageState();
}

class _FirmAdminDetailsPageState extends State<FirmAdminDetailsPage> {
  bool _saving = false;

  /// The account's **User** id. A Firm Admin appears either as a registry
  /// `firmAdmin` (`{id, email, fullName, status, phone}`) or as an employee
  /// record (`{id, userId, user}`); in the second shape `id` is the *Employee*
  /// id, so `userId`/`user.id` must win.
  String? _userId() {
    final admin = widget.admin;
    final nested = admin['user'] is Map ? admin['user'] as Map : null;
    final id = admin['userId'] ?? nested?['id'] ?? admin['id'];
    final text = id?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  /// Account status normalized the same way the firm list normalizes it:
  /// missing/unknown values are treated as `ACTIVE` rather than shown as a
  /// dash, so the action label matches the account's likely state.
  String get _status {
    final admin = widget.admin;
    final nested = admin['user'] is Map ? admin['user'] as Map : null;
    final raw = (nested?['status'] ?? admin['status'])?.toString().trim();
    return raw == null || raw.isEmpty ? 'ACTIVE' : raw.toUpperCase();
  }

  Future<void> _toggleStatus() async {
    final userId = _userId();
    if (userId == null) return;
    final next = _status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    setState(() => _saving = true);
    String message;
    try {
      await getIt<Dio>().patch('/users/$userId/status', data: {'status': next});
      message = 'Account status changed to $next.';
    } on DioException catch (error) {
      message = error.response?.statusCode == 404
          ? 'This backend has no endpoint to change a Firm Admin account, so '
                'it cannot be deactivated here. Deactivate the firm workspace '
                'instead.'
          : mapDioError(error).message;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final firm = widget.firm;
    final admin = widget.admin;
    final nested = admin['user'] is Map ? admin['user'] as Map : null;
    final name = nested?['fullName'] ?? admin['fullName'];
    final email = nested?['email'] ?? admin['email'];
    final status = _status;
    final classification =
        admin['jobClassification'] ??
        nested?['jobClassification'] ??
        admin['position'];

    final id = _userId();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Firm Admin Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    child: Icon(Icons.admin_panel_settings_outlined, size: 34),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    widget._value(name),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget._value(email),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Card(
            child: Column(
              children: [
                _DetailRow(label: 'Firm', value: widget._value(firm['name'])),
                const Divider(height: 1),
                _DetailRow(label: 'Account status', value: status),
                const Divider(height: 1),
                _DetailRow(
                  label: 'Classification',
                  value: widget._value(classification),
                ),
                const Divider(height: 1),
                _DetailRow(label: 'Account ID', value: widget._value(id)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          if (id != null)
            FilledButton.icon(
              onPressed: _saving ? null : _toggleStatus,
              icon: Icon(
                status == 'ACTIVE'
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
              ),
              label: Text(
                status == 'ACTIVE' ? 'Deactivate account' : 'Activate account',
              ),
            ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'This controls the Firm Admin account. Firm workspace status is '
            'managed separately.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) =>
      ListTile(title: Text(label), subtitle: Text(value));
}
