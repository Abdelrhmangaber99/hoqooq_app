import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../di/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/error_messages.dart';
import '../../../subscriptions/presentation/bloc/subscription_cubit.dart';
import '../../../subscriptions/presentation/bloc/subscription_state.dart';
import '../../domain/platform_admin_contract.dart';

class FirmDetailsPage extends StatefulWidget {
  const FirmDetailsPage({super.key, required this.firmId, this.initialFirm});
  final String firmId;
  final Map<String, dynamic>? initialFirm;
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
    final dio = getIt<Dio>();
    Object? overview;
    Object? overviewError;
    try {
      overview = (await dio.get('/tenants/${widget.firmId}')).data;
    } catch (error) {
      overviewError = error;
    }

    // The plan catalog only enriches the page and is caught individually.
    // Bundling it into one atomic `Future.wait` with the overview meant a
    // single rejected call failed the entire reload — the page fell back to
    // its error state, and a *successful* mutation reported "could not be
    // reloaded" even though the data it had just fetched was correct.
    Future<Response<dynamic>> tolerant(String path) async {
      try {
        return await dio.get(path);
      } catch (_) {
        return Response<dynamic>(
          requestOptions: RequestOptions(path: path),
          data: const <dynamic>[],
        );
      }
    }

    final plansResponse = await tolerant('/subscriptions/plans');
    Object? platformUsersData;
    try {
      final usersResponse = await dio.get('/users');
      platformUsersData = usersResponse.data;
    } catch (_) {
      // Older deployments may not expose the platform roster route.
    }
    var firm = PlatformAdminContract.overviewFirm(overview);
    if (firm.isEmpty && widget.initialFirm != null) {
      firm = PlatformAdminContract.normalizeTenant(widget.initialFirm);
    }
    if (firm.isEmpty) {
      final tenants = await tolerant('/tenants');
      firm = PlatformAdminContract.collection(tenants.data).firstWhere(
        (tenant) => tenant['id']?.toString() == widget.firmId,
        orElse: () => const <String, dynamic>{},
      );
    }
    if (firm.isEmpty) {
      if (overviewError != null) throw overviewError;
      throw StateError('Firm ${widget.firmId} was not found');
    }
    var overviewUsers = [
      ...PlatformAdminContract.overviewEmployees(overview),
      if (PlatformAdminContract.overviewAdmin(overview) case final admin?)
        admin,
    ];
    // The deployed registry carries the Firm Admin on the firm itself; use it
    // when the overview is unavailable (it is also the only readable source,
    // since a Super Admin has no `GET /users` and is refused `GET /employees`).
    if (overviewUsers.isEmpty && firm['firmAdmin'] is Map) {
      overviewUsers = [Map<String, dynamic>.from(firm['firmAdmin'] as Map)];
    }
    if (overviewUsers.isEmpty) {
      overviewUsers = PlatformAdminContract.usersForFirm(
        platformUsersData,
        widget.firmId,
      );
    }
    if (overviewUsers.isEmpty) {
      try {
        final employees = await dio.get(
          '/employees',
          queryParameters: {'tenantId': widget.firmId},
        );
        overviewUsers = PlatformAdminContract.overviewEmployees({
          'employees': employees.data is List ? employees.data : const [],
        });
      } catch (_) {
        // Keep the firm overview visible when the fallback is unavailable.
      }
    }
    final initialUsers = widget.initialFirm?['_employees'] is List
        ? (widget.initialFirm!['_employees'] as List)
              .whereType<Map<String, dynamic>>()
              .toList()
        : const <Map<String, dynamic>>[];
    final usersById = <String, Map<String, dynamic>>{};
    for (final user in [...overviewUsers, ...initialUsers]) {
      final nested = user['user'] is Map ? user['user'] as Map : null;
      final id = (user['userId'] ?? nested?['id'] ?? user['id'])?.toString();
      usersById[id ?? 'row-${usersById.length}'] = user;
    }
    return _FirmWorkspace(
      firm: firm,
      users: usersById.values.toList(),
      subscription:
          PlatformAdminContract.overviewSubscription(overview) ??
          PlatformAdminContract.currentSubscription(firm),
      plans: PlatformAdminContract.collection(plansResponse.data),
    );
  }

  /// Success and failure copy both pass through here, so the message is run
  /// through [localizedErrorMessage] — it translates this app's own English
  /// failure defaults and leaves already-localized text untouched.
  void _showMessage(String message) {
    if (!mounted) return;
    context.showErrorSnackBar(message);
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
        final firmStatus = (f['status']?.toString() ?? 'INACTIVE')
            .toUpperCase();
        final subscriptionStatus = s?['status']?.toString();
        // Employee account status is managed by the firm itself. A Super Admin
        // keeps only the Firm Admin's own account control (and the firm's
        // status above), never the status of the firm's rank-and-file staff.
        // The overview identifies the Firm Admin by the firm's `ownerUserId`,
        // which is the Firm Admin's user id set at provisioning.
        final registryAdminId = f['firmAdmin'] is Map
            ? (f['firmAdmin'] as Map)['id']?.toString()
            : null;
        final firmAdminUserId = f['ownerUserId']?.toString() ?? registryAdminId;
        bool isFirmAdminAccount(Map<String, dynamic> user) {
          final nested = user['user'] is Map ? user['user'] as Map : null;
          final accountType = (user['accountType'] ?? nested?['accountType'])
              ?.toString();
          if (accountType == 'FIRM_ADMIN') return true;
          if (firmAdminUserId == null || firmAdminUserId.isEmpty) return false;
          final userId = user['userId']?.toString();
          final nestedId = nested?['id']?.toString();
          final employeeId = user['id']?.toString();
          return userId == firmAdminUserId ||
              nestedId == firmAdminUserId ||
              employeeId == firmAdminUserId;
        }

        var firmAdminUser = workspace.users
            .cast<Map<String, dynamic>?>()
            .firstWhere(
              (u) => u != null && isFirmAdminAccount(u),
              orElse: () => null,
            );
        firmAdminUser ??= workspace.users.isEmpty
            ? null
            : workspace.users.first;
        final firmAdminNested = firmAdminUser?['user'] is Map
            ? firmAdminUser!['user'] as Map
            : null;
        final firmAdminName =
            (firmAdminNested?['fullName'] ?? firmAdminUser?['fullName'])
                ?.toString();
        final ownerId = f['ownerUserId']?.toString() ?? registryAdminId;
        final ownerDisplay = firmAdminName != null && firmAdminName.isNotEmpty
            ? '$firmAdminName (${ownerId ?? '—'})'
            : (ownerId ?? '—');

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
                    Text('Owner: $ownerDisplay'),
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
              ...workspace.users.map((user) {
                final nested = user['user'] is Map ? user['user'] as Map : null;
                final fullName = (nested?['fullName'] ?? user['fullName'])
                    ?.toString();
                final email =
                    (nested?['email'] ?? user['email'])?.toString() ?? '';
                final rawJob =
                    (user['jobClassification'] ??
                            nested?['jobClassification'] ??
                            user['position'])
                        ?.toString() ??
                    '';
                final jobClassification = rawJob.contains('_')
                    ? rawJob
                          .split('_')
                          .where((value) => value.isNotEmpty)
                          .map(
                            (value) =>
                                '${value[0]}${value.substring(1).toLowerCase()}',
                          )
                          .join(' ')
                    : rawJob;
                final status =
                    (nested?['status'] ?? user['status'])?.toString() ??
                    'ACTIVE';
                final isAdmin =
                    isFirmAdminAccount(user) || identical(user, firmAdminUser);

                return Card(
                  child: ListTile(
                    onTap: isAdmin
                        ? () => context.push(
                            AppRouter.firmAdminDetails(widget.firmId),
                            extra: {'firm': f, 'admin': user},
                          )
                        : null,
                    leading: Icon(
                      isAdmin
                          ? Icons.admin_panel_settings_outlined
                          : Icons.person_outline,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            (fullName != null && fullName.isNotEmpty)
                                ? fullName
                                : context.tr('unnamed_employee'),
                          ),
                        ),
                        if (isAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Firm Admin',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      [
                        email,
                        jobClassification,
                        status,
                      ].where((value) => value.isNotEmpty).join(' · '),
                    ),
                    isThreeLine: true,
                    // The deployed API exposes tenant status management but
                    // no per-user status endpoint. Do not issue a guaranteed
                    // 404/500 from this screen; use the firm status control
                    // above until that backend capability is deployed.
                    trailing: isAdmin
                        ? const Icon(Icons.chevron_right_rounded)
                        : null,
                  ),
                );
              }),
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
    required this.subscription,
    required this.plans,
  });

  final Map<String, dynamic> firm;
  final List<Map<String, dynamic>> users;
  final Map<String, dynamic>? subscription;
  final List<Map<String, dynamic>> plans;
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
