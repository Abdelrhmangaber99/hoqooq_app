import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/error_messages.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/cache_busted_url.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../../profile/presentation/bloc/profile_cubit.dart';
import '../../../subscriptions/presentation/bloc/subscription_cubit.dart';
import '../../../subscriptions/presentation/bloc/subscription_state.dart';
import '../../../subscriptions/presentation/widgets/firm_logo_image.dart';
import '../bloc/settings_cubit.dart';

/// Settings — firm profile (gated by `firm.profile.manage` for edits),
/// personal profile, appearance & language preferences, password change,
/// and navigation to subscription / employee-permission management.
///
/// Visual structure mirrors the reference web app's Settings page (`D:\hoqooq_frontend`):
/// a fixed section sidebar with grouped navigation and a single main content panel,
/// with immediate reactive state synchronization and inline banners — no dialogs,
/// no full-page reloads, no app restarts.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.subscriptionCubit,
    this.settingsCubit,
    this.profileCubit,
    this.sessionCubit,
  });

  final SubscriptionCubit? subscriptionCubit;
  final SettingsCubit? settingsCubit;
  final ProfileCubit? profileCubit;
  final SessionCubit? sessionCubit;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

enum _SettingsSection { firmInfo, personalInfo, preferences, changePassword }

class _SettingsPageState extends State<SettingsPage> {
  // Resolved once per page instance. These used to be getters calling
  // `getIt<>()` on every access, which for `@injectable`-registered cubits
  // (SettingsCubit, ProfileCubit) returned a *new* instance each time: a
  // submission's emitted state landed on a cubic nobody was listening to,
  // so a successful save or password change produced no visible feedback.
  late final SubscriptionCubit _subscriptionCubit =
      widget.subscriptionCubit ?? getIt<SubscriptionCubit>();
  late final SettingsCubit _settingsCubit =
      widget.settingsCubit ?? getIt<SettingsCubit>();
  late final ProfileCubit _profileCubit =
      widget.profileCubit ?? getIt<ProfileCubit>();
  late final SessionCubit _sessionCubit =
      widget.sessionCubit ?? getIt<SessionCubit>();

  _SettingsSection _section = _SettingsSection.firmInfo;

  // Firm info controllers
  final _firmNameController = TextEditingController();
  final _firmAddressController = TextEditingController();
  final _firmEmailController = TextEditingController();
  bool _firmSaved = false;

  // Personal profile controllers
  final _fullNameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _emailController = TextEditingController();
  bool _profileSaved = false;
  bool _suppressListener = false;

  bool get _canManageFirm =>
      currentUserHasPerm(PermissionCodes.firmProfileManage);

  @override
  void initState() {
    super.initState();
    if (_subscriptionCubit.state is! SubscriptionLoaded) {
      _subscriptionCubit.fetchSubscription();
    }
    _initUserControllers();
    for (final controller in [
      _firmNameController,
      _firmAddressController,
      _firmEmailController,
    ]) {
      controller.addListener(() {
        if (_suppressListener) return;
        if (_firmSaved) setState(() => _firmSaved = false);
      });
    }
    for (final controller in [_fullNameController, _avatarUrlController]) {
      controller.addListener(() {
        if (_suppressListener) return;
        if (_profileSaved) setState(() => _profileSaved = false);
      });
    }
  }

  void _initUserControllers() {
    final session = _sessionCubit.state;
    if (session is SessionAuthenticated) {
      _suppressListener = true;
      _fullNameController.text = session.user.fullName;
      _avatarUrlController.text = session.user.avatarUrl ?? '';
      _emailController.text = session.user.email;
      _suppressListener = false;
    }
  }

  @override
  void dispose() {
    _firmNameController.dispose();
    _firmAddressController.dispose();
    _firmEmailController.dispose();
    _fullNameController.dispose();
    _avatarUrlController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _syncFirmControllers(Map<String, dynamic> firm) {
    _suppressListener = true;
    _firmNameController.text = firm['name'] as String? ?? '';
    _firmAddressController.text = firm['address'] as String? ?? '';
    _firmEmailController.text = firm['contactEmail'] as String? ?? '';
    _suppressListener = false;
  }

  Future<void> _pickAndUploadLogo() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null) return;
    await _subscriptionCubit.uploadFirmLogo(path);
  }

  Future<void> _pickAndSetAvatar() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null) return;
    setState(() {
      _avatarUrlController.text = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SubscriptionCubit>.value(value: _subscriptionCubit),
        BlocProvider<SettingsCubit>.value(value: _settingsCubit),
        BlocProvider<ProfileCubit>.value(value: _profileCubit),
        // The personal-info panel renders through a BlocBuilder<SessionCubit>
        // and the app provides that only at the root (main.dart). Providing
        // it here too keeps the page self-contained — otherwise the panel
        // throws ProviderNotFoundException whenever it is mounted without
        // that root provider above it.
        BlocProvider<SessionCubit>.value(value: _sessionCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(context.tr('settings'))),
        body: SafeArea(
          child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
            listener: (context, state) {
              if (state is SubscriptionLoaded) {
                _syncFirmControllers(state.firm);
              }
            },
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final panel = _buildPanel(context, state);
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionSidebar(context),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(child: panel),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.m,
                          ),
                          children: [
                            _buildChip(context, _SettingsSection.firmInfo),
                            const SizedBox(width: AppSpacing.s),
                            _buildChip(context, _SettingsSection.personalInfo),
                            const SizedBox(width: AppSpacing.s),
                            _buildChip(context, _SettingsSection.preferences),
                            const SizedBox(width: AppSpacing.s),
                            _buildChip(
                              context,
                              _SettingsSection.changePassword,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Expanded(child: panel),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, _SettingsSection section) {
    final selected = _section == section;
    final label = switch (section) {
      _SettingsSection.firmInfo => context.tr('firm_information'),
      _SettingsSection.personalInfo => context.tr('personal_information'),
      _SettingsSection.preferences => context.tr('preferences'),
      _SettingsSection.changePassword => context.tr('change_password'),
    };
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      label: Text(label),
      onSelected: (_) => setState(() => _section = section),
    );
  }

  Widget _buildSectionSidebar(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.all(AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: _panelDecoration,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // No group header above these two: the reference sidebar never
            // repeats a group title as its own item label, and a header
            // here would render the identical string twice.
            _sidebarItem(
              context.tr('firm_information'),
              selected: _section == _SettingsSection.firmInfo,
              onTap: () => setState(() => _section = _SettingsSection.firmInfo),
            ),
            _sidebarItem(
              context.tr('personal_information'),
              selected: _section == _SettingsSection.personalInfo,
              onTap: () =>
                  setState(() => _section = _SettingsSection.personalInfo),
            ),
            _sidebarItem(
              context.tr('appearance_and_language'),
              selected: _section == _SettingsSection.preferences,
              onTap: () =>
                  setState(() => _section = _SettingsSection.preferences),
            ),
            _sidebarHeader(context.tr('security')),
            _sidebarItem(
              context.tr('change_password'),
              selected: _section == _SettingsSection.changePassword,
              onTap: () =>
                  setState(() => _section = _SettingsSection.changePassword),
            ),
            _sidebarHeader(context.tr('firm_members_section')),
            _sidebarLink(
              context.tr('roles_and_permissions'),
              onTap: () => context.push(AppRouter.employees),
            ),
            _sidebarHeader(context.tr('subscription')),
            _sidebarLink(
              context.tr('subscription_plan_and_billing'),
              onTap: () => context.push(AppRouter.subscription),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.m,
        right: AppSpacing.m,
        top: AppSpacing.m,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(color: AppColors.textHint),
      ),
    );
  }

  Widget _sidebarItem(
    String title, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? AppColors.brass100 : Colors.transparent,
        borderRadius: AppRadius.small,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.small,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: 10,
            ),
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: selected ? AppColors.brass800 : AppColors.ink600,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sidebarLink(String title, {required VoidCallback onTap}) {
    return _sidebarItem(title, selected: false, onTap: onTap);
  }

  Widget _buildPanel(BuildContext context, SubscriptionState subState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        0,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
      ),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: _panelDecoration,
      child: SingleChildScrollView(
        child: switch (_section) {
          _SettingsSection.firmInfo =>
            _buildFirmInfoSection(context, subState),
          _SettingsSection.personalInfo => _buildPersonalInfoPanel(context),
          _SettingsSection.preferences => _buildPreferencesPanel(context),
          _SettingsSection.changePassword =>
            _buildChangePasswordPanel(context),
        },
      ),
    );
  }

  Widget _buildFirmInfoSection(
    BuildContext context,
    SubscriptionState state,
  ) {
    if (state is SubscriptionLoading || state is SubscriptionInitial) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (state is SubscriptionError) {
      return ErrorView(
        message: state.message,
        onRetry: () => _subscriptionCubit.fetchSubscription(),
      );
    }
    if (state is SubscriptionLoaded) {
      return _buildFirmInfoPanel(context, state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildFirmInfoPanel(BuildContext context, SubscriptionLoaded state) {
    final firm = state.firm;
    final logoUrl = firm['logoUrl'] as String?;
    final showMutationSpinner = state.isMutating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('firm_information'), style: AppTypography.h2),
        const SizedBox(height: AppSpacing.l),
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.paperSoft,
                borderRadius: AppRadius.large,
                border: Border.all(color: AppColors.paperLine),
              ),
              clipBehavior: Clip.antiAlias,
              // `logoUrl` is a MinIO object key, not a URL — rendering it as a
              // network image 404'd and always showed the placeholder.
              // FirmLogoImage fetches the real bytes through the
              // authenticated dio client instead.
              child: FirmLogoImage(
                logoKey: logoUrl,
                version: firm['updatedAt'],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('firm_logo'),
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('firm_logo_hint'),
                    style: AppTypography.bodySmall,
                  ),
                  if (_canManageFirm) ...[
                    const SizedBox(height: AppSpacing.s),
                    OutlinedButton.icon(
                      onPressed: showMutationSpinner
                          ? null
                          : _pickAndUploadLogo,
                      icon: showMutationSpinner
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_outlined, size: 14),
                      label: Text(
                        showMutationSpinner
                            ? context.tr('uploading')
                            : context.tr('upload_logo'),
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const Divider(height: AppSpacing.xl, color: AppColors.paperLine),
        // Two columns on wide screens, one on narrow — the reference uses
        // `grid grid-cols-1 sm:grid-cols-2 gap-4` for these same fields.
        LayoutBuilder(
          builder: (context, constraints) {
            final fieldWidth = constraints.maxWidth >= 520
                ? (constraints.maxWidth - AppSpacing.m) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: AppSpacing.m,
              runSpacing: AppSpacing.m,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: AppTextField(
                    label: context.tr('firm_name'),
                    controller: _firmNameController,
                    readOnly: !_canManageFirm,
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: AppTextField(
                    label: context.tr('firm_address'),
                    controller: _firmAddressController,
                    readOnly: !_canManageFirm,
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: AppTextField(
                    label: context.tr('contact_email'),
                    controller: _firmEmailController,
                    readOnly: !_canManageFirm,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.l),
        if (state.error != null) ...[
          _inlineBanner(
            message: state.error!,
            background: AppColors.rust100,
            foreground: AppColors.rust600,
            icon: Icons.error_outline,
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        if (_firmSaved) ...[
          _inlineBanner(
            message: context.tr('changes_saved'),
            background: AppColors.brass100,
            foreground: AppColors.brass700,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        if (_canManageFirm)
          AppButton(
            text: context.tr('save_changes'),
            isLoading: showMutationSpinner,
            onPressed: _saveFirmInfo,
            fullWidth: false,
          ),
      ],
    );
  }

  Future<void> _saveFirmInfo() async {
    final name = _firmNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('firm_name_required'))));
      return;
    }
    final ok = await _subscriptionCubit.saveFirmInfo(
      name: name,
      address: _firmAddressController.text.trim(),
      contactEmail: _firmEmailController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _firmSaved = ok);
  }

  Widget _buildPersonalInfoPanel(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, session) {
        final user = session is SessionAuthenticated ? session.user : null;
        return BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is ProfileUpdateSuccess) {
              setState(() => _profileSaved = true);
            }
          },
          builder: (context, state) {
            final isLoading = state is ProfileUpdateLoading;
            final errorKey = state is ProfileUpdateError
                ? state.messageKey
                : null;

            final initials = (user?.fullName ?? '')
                .split(RegExp(r'\s+'))
                .where((part) => part.isNotEmpty)
                .take(2)
                .map((part) => part[0].toUpperCase())
                .join();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('personal_information'),
                  style: AppTypography.h2,
                ),
                const SizedBox(height: AppSpacing.l),
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.brass100,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.paperLine),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                          ? Image.network(
                              cacheBustedUrl(user.avatarUrl!, user.updatedAt),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  initials.isEmpty ? '?' : initials,
                                  style: AppTypography.h3.copyWith(
                                    color: AppColors.brass800,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                initials.isEmpty ? '?' : initials,
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.brass800,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? context.tr('unnamed_employee'),
                            style: AppTypography.labelLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(
                  height: AppSpacing.xl,
                  color: AppColors.paperLine,
                ),
                AppTextField(
                  label: context.tr('full_name'),
                  controller: _fullNameController,
                ),
                const SizedBox(height: AppSpacing.m),
                AppTextField(
                  label: context.tr('email_address'),
                  readOnly: true,
                  controller: _emailController,
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: context.tr('avatar_url'),
                        controller: _avatarUrlController,
                        keyboardType: TextInputType.url,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: OutlinedButton.icon(
                        onPressed: _pickAndSetAvatar,
                        icon: const Icon(Icons.image_outlined, size: 16),
                        label: Text(
                          context.tr('choose_photo'),
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                if (errorKey != null) ...[
                  _inlineBanner(
                    // The state carries either a localization key
                    // (`full_name_required`) or the failure's own text; both
                    // resolve to the active locale here.
                    message: localizedErrorKeyOrMessage(context, errorKey),
                    background: AppColors.rust100,
                    foreground: AppColors.rust600,
                    icon: Icons.error_outline,
                  ),
                  const SizedBox(height: AppSpacing.m),
                ],
                if (_profileSaved) ...[
                  _inlineBanner(
                    message: context.tr('profile_updated_success'),
                    background: AppColors.brass100,
                    foreground: AppColors.brass700,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: AppSpacing.m),
                ],
                AppButton(
                  text: context.tr('save_changes'),
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _saveUserProfile,
                  fullWidth: false,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveUserProfile() {
    final name = _fullNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('full_name_required'))));
      return;
    }
    _settingsCubit.submitProfileUpdate(
      fullName: name,
      // No phone field exists in this panel, so `phone` is omitted rather
      // than sent as an empty string — otherwise every save would clear a
      // phone number the app never displayed or let the user edit.
      avatarUrl: _avatarUrlController.text.trim(),
    );
  }

  Widget _buildPreferencesPanel(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        final isArabic = profileState.locale.languageCode == 'ar';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('preferences'), style: AppTypography.h2),
            const SizedBox(height: AppSpacing.l),
            // The Light/Dark/System picker was removed: the app ships a single
            // light theme (see `main.dart`), so an appearance choice here
            // would be a control that does nothing. Language stays.
            Text(context.tr('app_language'), style: AppTypography.h3),
            const SizedBox(height: AppSpacing.s),
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.paperSoft,
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.paperLine),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.language,
                    size: 22,
                    color: AppColors.brass700,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'العربية' : 'English',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isArabic ? 'RTL Layout Active' : 'LTR Layout Active',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _profileCubit.toggleLocale(),
                    child: Text(
                      isArabic
                          ? context.tr('switch_to_english')
                          : context.tr('switch_to_arabic'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChangePasswordPanel(BuildContext context) {
    return _ChangePasswordForm(settingsCubit: _settingsCubit);
  }

  Widget _inlineBanner({
    required String message,
    required Color background,
    required Color foreground,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.large,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }

}

class _ChangePasswordForm extends StatefulWidget {
  const _ChangePasswordForm({this.settingsCubit});

  final SettingsCubit? settingsCubit;

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = widget.settingsCubit ?? context.read<SettingsCubit>();
    cubit.submitPasswordChange(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  String _errorText(BuildContext context, String key) {
    return switch (key) {
      'password_mismatch' => context.tr('password_mismatch'),
      'password_required' => context.tr('password_required'),
      'new_password_required' => context.tr('new_password_required'),
      'password_min_length|8' ||
      'password_min_length' => context.tr('password_min_length'),
      'password_change_wrong_current' => context.tr(
        'password_change_wrong_current',
      ),
      'password_change_forbidden' => context.tr('password_change_forbidden'),
      'network_error_message' => context.tr('network_error_message'),
      'password_change_validation_error' || 'password_change_generic_error' =>
        context.tr('password_change_generic_error'),
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cubit = widget.settingsCubit ?? context.read<SettingsCubit>();

    return BlocConsumer<SettingsCubit, SettingsState>(
      bloc: cubit,
      listener: (context, state) {
        if (state is PasswordChangeSuccess) {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      },
      builder: (context, state) {
        final isLoading = state is PasswordChangeLoading;
        final errorKey = state is PasswordChangeError ? state.messageKey : null;
        final isSuccess = state is PasswordChangeSuccess;

        // The reference caps this form at `max-w-sm` (384px) so it does
        // not stretch across a wide panel.
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 384),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('change_password'), style: AppTypography.h2),
              const SizedBox(height: AppSpacing.l),
              _passwordField(
                context,
                label: context.tr('current_password'),
                controller: _currentPasswordController,
              ),
              const SizedBox(height: AppSpacing.m),
              _passwordField(
                context,
                label: context.tr('new_password'),
                controller: _newPasswordController,
              ),
              const SizedBox(height: AppSpacing.m),
              _passwordField(
                context,
                label: context.tr('confirm_new_password'),
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: AppSpacing.l),
              if (errorKey != null) ...[
                _Banner(
                  message: _errorText(context, errorKey),
                  background: AppColors.rust100,
                  foreground: AppColors.rust600,
                  icon: Icons.error_outline,
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              if (isSuccess) ...[
                _Banner(
                  message: context.tr('password_changed_success'),
                  background: AppColors.brass100,
                  foreground: AppColors.brass700,
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              AppButton(
                text: context.tr('change_password'),
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
                fullWidth: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _passwordField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
  }) {
    return AppTextField(
      label: label,
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.message,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final String message;
  final Color background;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.large,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

const _panelDecoration = BoxDecoration(
  color: AppColors.surface,
  borderRadius: AppRadius.large,
  border: Border.fromBorderSide(BorderSide(color: AppColors.paperLine)),
);
