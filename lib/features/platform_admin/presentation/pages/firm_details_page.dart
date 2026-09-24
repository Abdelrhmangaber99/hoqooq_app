import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../di/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/auth/permission_labels.dart';
import '../../../subscriptions/presentation/bloc/subscription_cubit.dart';
import '../../../subscriptions/presentation/bloc/subscription_state.dart';
import '../../domain/firm_admin_permissions.dart';
import '../../domain/platform_admin_contract.dart';

class FirmDetailsPage extends StatefulWidget {
  const FirmDetailsPage({super.key, required this.firmId});
  final String firmId;
  @override
  State<FirmDetailsPage> createState() => _FirmDetailsPageState();
}

class _FirmDetailsPageState extends State<FirmDetailsPage> {
  late Future<_FirmWorkspace> _workspace;
  @override
  void initState() {
    super.initState();
    _workspace = _load();
  }

  Future<_FirmWorkspace> _load() async {
    // The overview is the authoritative payload: firm status, employees,
    // and the current subscription. If it fails, the whole load fails.
    final overview = (await getIt<Dio>().get('/tenants/${widget.firmId}')).data;

    // The other three only enrich the page (account list, permission
    // catalog, plan catalog) and are caught individually. Bundling all four
    // into one atomic `Future.wait` meant a single rejected call failed the
    // entire reload — the page fell back to its error state, and a
    // *successful* mutation reported "could not be reloaded" even though
    // the data it had just fetched was correct.
    Future<Response<dynamic>> tolerant(String path) => getIt<Dio>()
        .get(path)
        .catchError(
          (_) => Response<dynamic>(
            requestOptions: RequestOptions(path: path),
            data: const <dynamic>[],
          ),
        );

    final aux = await Future.wait<Response<dynamic>>([
      tolerant('/users'),
      tolerant('/permissions'),
      tolerant('/subscriptions/plans'),
    ]);

    final accounts = ((aux[0].data as List?) ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .where((user) => (user['tenant'] as Map?)?['id'] == widget.firmId)
        .toList();
    return _FirmWorkspace(
      firm: PlatformAdminContract.overviewFirm(overview),
      users: PlatformAdminContract.overviewEmployees(overview),
      accounts: accounts,
      subscription: PlatformAdminContract.overviewSubscription(overview),
      plans: ((aux[2].data as List?) ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList(),
      permissionKeys: PlatformAdminContract.permissionCodes(
        aux[1].data,
      ).where(isFirmAdminGrantablePermission).toList(),
    );
  }

  Future<void> _editFirmAdminPermissions(_FirmWorkspace workspace) async {
    final admin = workspace.firmAdmin;
    if (admin == null) {
      _showMessage(context.tr('firm_admin_not_found'));
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _FirmAdminPermissionDialog(
        firmId: widget.firmId,
        permissionKeys: workspace.permissionKeys,
        selectedPermissionKeys: Set<String>.from(
          (admin['permissions'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>(),
        ),
      ),
    );
    if (saved != true || !mounted) return;
    // Same reload path as every other mutation here: the refreshed account
    // list carries the server's newly saved permission set, so reopening
    // the dialog shows the selection that was actually persisted instead
    // of the previous one.
    final refreshed = await _reloadWorkspace();
    if (mounted && refreshed) {
      _showMessage(context.tr('firm_admin_permissions_updated'));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// True while a platform mutation and its follow-up reload is in flight.
  /// Every action button is disabled while it is set, so a slow request is
  /// visibly being handled and cannot be submitted twice.
  bool _mutating = false;

  /// Runs [mutation], then re-reads the firm workspace so the subscription,
  /// firm and account controls show the server's new state immediately —
  /// no manual refresh, no navigating away and back.
  Future<void> _runAndReload(
    Future<void> Function() mutation, {
    required String successMessage,
    required String failureMessage,
  }) async {
    if (_mutating) return;
    setState(() => _mutating = true);
    try {
      await mutation();
      final refreshed = await _reloadWorkspace();
      if (refreshed) _showMessage(successMessage);
    } on DioException catch (error) {
      _showMessage(_errorMessage(error, failureMessage));
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  /// Re-reads the workspace after a successful mutation. On failure the
  /// currently displayed workspace stays on screen with a message instead
  /// of being replaced by the whole-page error state: the mutation itself
  /// succeeded, and blanking the view makes it look like nothing happened.
  /// Returns whether the reload actually happened, so callers report the
  /// right outcome.
  Future<bool> _reloadWorkspace() async {
    try {
      final next = await _load();
      if (mounted) setState(() => _workspace = Future.value(next));
      return true;
    } catch (_) {
      if (mounted) _showMessage(context.tr('refresh_after_action_failed'));
      return false;
    }
  }

  Future<void> _changeFirmStatus(String currentStatus) async {
    final nextStatus = currentStatus == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('$nextStatus this firm?'),
        content: const Text(
          'Firm status is separate from subscription status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(nextStatus),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _runAndReload(
      () => getIt<Dio>().patch(
        '/tenants/${widget.firmId}/status',
        data: {'status': nextStatus},
      ),
      successMessage: 'Firm status changed to $nextStatus.',
      failureMessage: 'Could not change firm status.',
    );
  }

  Future<void> _changeUserStatus(Map<String, dynamic> user) async {
    final current = user['status']?.toString() ?? 'ACTIVE';
    final next = current == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    await _runAndReload(
      () => getIt<Dio>().patch(
        '/users/${user['id']}/status',
        data: {'status': next},
      ),
      successMessage: 'Account status changed to $next.',
      failureMessage: 'Could not change account status.',
    );
  }

  Future<void> _setSubscriptionActive(bool activate) async {
    await _runAndReload(
      () async {
        await getIt<Dio>().post(
          '/subscriptions/${widget.firmId}/${activate ? 'activate' : 'deactivate'}',
        );
        // Keep the shared firm/subscription state (settings page,
        // subscription page) in sync with this platform-side mutation —
        // it refreshes /tenants/my-firm when the mutated firm IS the
        // signed-in user's own firm.
        _syncSharedSubscriptionState();
      },
      successMessage: activate
          ? 'Subscription activated.'
          : 'Subscription cancelled.',
      failureMessage: 'Could not change subscription status.',
    );
  }

  /// After a successful platform-side subscription mutation, refresh the
  /// shared SubscriptionCubit when it holds THIS firm — dependent widgets
  /// (settings, subscription page, sidebar) rebuild immediately instead of
  /// showing stale status. `refreshQuietly` reloads without blanking the
  /// already-rendered data, and falls back to a full fetch when the cubit
  /// has not loaded yet.
  void _syncSharedSubscriptionState() {
    final cubit = getIt<SubscriptionCubit>();
    final state = cubit.state;
    // Only the account's own firm is mirrored in shared state. When the
    // platform admin administers a different firm there is nothing to
    // sync, and a failed/empty shared state is left alone rather than
    // re-requesting data this account does not have.
    final holdsThisFirm =
        state is SubscriptionLoaded && state.firm['id'] == widget.firmId;
    if (holdsThisFirm || state is SubscriptionInitial) {
      cubit.refreshQuietly();
    }
  }

  Future<void> _changePlan(_FirmWorkspace workspace) async {
    final result = await showDialog<({String planId, String billingCycle})>(
      context: context,
      builder: (_) => _SubscriptionPlanDialog(
        plans: workspace.plans,
        subscription: workspace.subscription,
      ),
    );
    if (result == null) return;
    await _runAndReload(
      () async {
        await getIt<Dio>().patch(
          '/subscriptions/${widget.firmId}',
          data: {'planId': result.planId, 'billingCycle': result.billingCycle},
        );
        _syncSharedSubscriptionState();
      },
      successMessage: 'Subscription plan updated.',
      failureMessage: 'Could not update the plan.',
    );
  }

  String _errorMessage(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: Text(context.tr('firm_details'))),
    body: FutureBuilder<_FirmWorkspace>(
      future: _workspace,
      builder: (_, snap) {
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.tr('could_not_load_firm')),
                const SizedBox(height: AppSpacing.m),
                FilledButton(
                  onPressed: () => setState(() => _workspace = _load()),
                  child: Text(context.tr('try_again')),
                ),
              ],
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final workspace = snap.data!;
        final f = workspace.firm;
        final s = workspace.subscription;
        final firmStatus = f['status']?.toString() ?? 'INACTIVE';
        final subscriptionStatus = s?['status']?.toString();
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f['name']?.toString() ?? 'Firm',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text('Status: ${f['status'] ?? '—'}'),
                    Text('Email: ${f['contactEmail'] ?? '—'}'),
                    Text('Owner: ${f['ownerUserId'] ?? '—'}'),
                    const Divider(),
                    Text('Plan: ${(s?['plan'] as Map?)?['name'] ?? '—'}'),
                    Text('Subscription: ${s?['status'] ?? '—'}'),
                    Text('Renews: ${s?['currentPeriodEnd'] ?? '—'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            if (_mutating) ...[
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: AppSpacing.m),
            ],
            FilledButton.icon(
              onPressed: _mutating || workspace.firmAdmin == null
                  ? null
                  : () => _editFirmAdminPermissions(workspace),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: Text(context.tr('manage_firm_admin_permissions')),
            ),
            const SizedBox(height: AppSpacing.s),
            OutlinedButton.icon(
              onPressed: _mutating ? null : () => _changeFirmStatus(firmStatus),
              icon: Icon(
                firmStatus == 'ACTIVE'
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
              ),
              label: Text(
                firmStatus == 'ACTIVE' ? 'Deactivate firm' : 'Activate firm',
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Subscription administration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _mutating || subscriptionStatus == 'ACTIVE'
                      ? null
                      : () => _setSubscriptionActive(true),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Activate subscription'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _mutating || subscriptionStatus == 'CANCELLED'
                      ? null
                      : () => _setSubscriptionActive(false),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel subscription'),
                ),
                OutlinedButton.icon(
                  onPressed: _mutating || workspace.plans.isEmpty
                      ? null
                      : () => _changePlan(workspace),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Change plan or cycle'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('firm_employees'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (workspace.users.isEmpty)
              Text(context.tr('no_employees_found'))
            else
              ...workspace.users.map(
                (user) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(
                      user['fullName']?.toString() ??
                          context.tr('unnamed_employee'),
                    ),
                    subtitle: Text(
                      [
                            user['email'] ?? '',
                            user['jobClassification'] ?? '',
                            user['status'] ?? '',
                          ]
                          .where((value) => value.toString().isNotEmpty)
                          .join(' · '),
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: user['status'] == 'ACTIVE'
                          ? 'Deactivate account'
                          : 'Activate account',
                      onPressed: _mutating
                          ? null
                          : () => _changeUserStatus(user),
                      icon: Icon(
                        user['status'] == 'ACTIVE'
                            ? Icons.person_off_outlined
                            : Icons.person_add_alt_outlined,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

class _FirmWorkspace {
  const _FirmWorkspace({
    required this.firm,
    required this.users,
    required this.accounts,
    required this.subscription,
    required this.plans,
    required this.permissionKeys,
  });

  final Map<String, dynamic> firm;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> accounts;
  final Map<String, dynamic>? subscription;
  final List<Map<String, dynamic>> plans;
  final List<String> permissionKeys;

  Map<String, dynamic>? get firmAdmin {
    for (final user in accounts) {
      if (user['accountType'] == 'FIRM_ADMIN') return user;
    }
    return null;
  }
}

class _SubscriptionPlanDialog extends StatefulWidget {
  const _SubscriptionPlanDialog({
    required this.plans,
    required this.subscription,
  });

  final List<Map<String, dynamic>> plans;
  final Map<String, dynamic>? subscription;

  @override
  State<_SubscriptionPlanDialog> createState() =>
      _SubscriptionPlanDialogState();
}

class _SubscriptionPlanDialogState extends State<_SubscriptionPlanDialog> {
  late String _planId = _initialPlanId();
  late String _billingCycle =
      widget.subscription?['billingCycle']?.toString() ?? 'MONTHLY';

  String _initialPlanId() {
    final current = widget.subscription?['planId']?.toString();
    if (widget.plans.any((plan) => plan['id']?.toString() == current)) {
      return current!;
    }
    return widget.plans.first['id'].toString();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Change subscription'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _planId,
          decoration: const InputDecoration(labelText: 'Plan'),
          items: widget.plans
              .map(
                (plan) => DropdownMenuItem(
                  value: plan['id'].toString(),
                  child: Text(plan['name']?.toString() ?? 'Plan'),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _planId = value!),
        ),
        const SizedBox(height: AppSpacing.m),
        DropdownButtonFormField<String>(
          initialValue: _billingCycle,
          decoration: const InputDecoration(labelText: 'Billing cycle'),
          items: const [
            DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
            DropdownMenuItem(value: 'YEARLY', child: Text('Yearly')),
          ],
          onChanged: (value) => setState(() => _billingCycle = value!),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, (
          planId: _planId,
          billingCycle: _billingCycle,
        )),
        child: const Text('Save'),
      ),
    ],
  );
}

class _FirmAdminPermissionDialog extends StatefulWidget {
  const _FirmAdminPermissionDialog({
    required this.firmId,
    required this.permissionKeys,
    required this.selectedPermissionKeys,
  });

  final String firmId;
  final List<String> permissionKeys;
  final Set<String> selectedPermissionKeys;

  @override
  State<_FirmAdminPermissionDialog> createState() =>
      _FirmAdminPermissionDialogState();
}

class _FirmAdminPermissionDialogState
    extends State<_FirmAdminPermissionDialog> {
  late final Set<String> _selected = {...widget.selectedPermissionKeys};
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await getIt<Dio>().patch(
        '/tenants/${widget.firmId}/firm-admin/permissions',
        data: {'permissionKeys': _selected.toList()..sort()},
      );
      if (mounted) Navigator.pop(context, true);
    } on DioException catch (error) {
      if (!mounted) return;
      final data = error.response?.data;
      setState(() {
        _saving = false;
        _error = data is Map<String, dynamic>
            ? data['message']?.toString()
            : context.tr('could_not_update_permissions');
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.tr('firm_admin_permissions')),
    content: SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('firm_admin_permissions_explanation'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.s),
          Text('${_selected.length} ${context.tr('permissions_selected')}'),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: AppSpacing.s),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.permissionKeys.length,
              itemBuilder: (_, index) {
                final permission = widget.permissionKeys[index];
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(permissionLabel(context, permission)),
                  value: _selected.contains(permission),
                  onChanged: _saving
                      ? null
                      : (checked) => setState(() {
                          if (checked ?? false) {
                            _selected.add(permission);
                          } else {
                            _selected.remove(permission);
                          }
                        }),
                );
              },
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context, false),
        child: Text(context.tr('cancel')),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(context.tr('save_changes')),
      ),
    ],
  );
}
