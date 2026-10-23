import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/error_messages.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showBrandPanel = constraints.maxWidth >= 760;
            return Row(
              children: [
                if (showBrandPanel) const Expanded(child: _BrandPanel()),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 384),
                        child: _LoginForm(
                          formKey: _formKey,
                          showMobileLogo: !showBrandPanel,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          rememberMe: _rememberMe,
                          onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onRememberChanged: (value) =>
                              setState(() => _rememberMe = value ?? false),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.showMobileLogo,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onTogglePassword,
    required this.onRememberChanged,
  });

  final GlobalKey<FormState> formKey;
  final bool showMobileLogo;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          context.go(AppRouter.home);
        } else if (authState is AuthError) {
          context.showErrorSnackBar(authState.message);
        }
      },
      builder: (context, authState) => Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showMobileLogo) ...[
              const Center(child: _Logo(size: 88)),
              const SizedBox(height: 30),
            ],
            Text(context.tr('welcome_back'), style: AppTypography.h2),
            const SizedBox(height: 6),
            Text(
              context.tr('sign_in_to_workspace'),
              style: AppTypography.bodyMedium.copyWith(color: AppColors.ink400),
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: context.tr('email_address'),
              hint: 'example@lawfirm.com',
              controller: emailController,
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => _emailValidator(context, value),
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: context.tr('password'),
              hint: '••••••••••••',
              controller: passwordController,
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.ink300,
                  size: 19,
                ),
                onPressed: onTogglePassword,
              ),
              validator: (value) => _passwordValidator(context, value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: AppColors.brass500,
                        visualDensity: VisualDensity.compact,
                        onChanged: onRememberChanged,
                      ),
                      Flexible(
                        child: Text(
                          context.tr('remember_me'),
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.ink500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      if (authState is AuthLoading) return;
                      context.push(AppRouter.forgotPassword);
                    },
                    child: Text(
                      context.tr('forgot_password'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppButton(
              text: context.tr('sign_in'),
              isLoading: authState is AuthLoading,
              icon: Icons.login_rounded,
              onPressed: () {
                if (authState is AuthLoading) return;
                // Validate locally first. The backend answers a blank or
                // malformed field with `class-validator`'s own English
                // sentence, which is not worth a round trip (and used to
                // surface on the sign-in screen in Arabic mode).
                if (!(formKey.currentState?.validate() ?? false)) return;
                context.read<AuthBloc>().add(
                  LoginRequested(
                    emailController.text.trim(),
                    passwordController.text,
                  ),
                );
              },
            ),
            const SizedBox(height: 26),
            Text(
              context.tr('invite_only_access'),
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.ink300,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            const _PoweredByEthereal(),
          ],
        ),
      ),
    );
  }

  String? _emailValidator(BuildContext context, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.tr('field_required');
    // The backend owns the authoritative email rule; this only catches the
    // obviously malformed value that would otherwise return a 400.
    if (!text.contains('@') || text.endsWith('@')) {
      return context.tr('invalid_email');
    }
    return null;
  }

  String? _passwordValidator(BuildContext context, String? value) {
    if (value == null || value.isEmpty) return context.tr('field_required');
    // LoginDto enforces @MinLength(6); checking it here keeps the backend's
    // English validation sentence off the screen.
    if (value.length < 6) return context.tr('error_password_min_length');
    return null;
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink800,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _ArabesquePainter()),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _Logo(size: 112),
                const SizedBox(height: 20),
                Text(
                  context.tr('hoqooq_brand'),
                  style: AppTypography.h1.copyWith(
                    color: Colors.white,
                    fontSize: 34,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('legal_case_management'),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.ink200,
                  ),
                ),
                const SizedBox(height: 26),
                Container(width: 64, height: 1, color: AppColors.ink600),
                const SizedBox(height: 26),
                Text(
                  context.tr('brand_quote'),
                  textAlign: TextAlign.center,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.brass300,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 36),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 22,
                  runSpacing: 12,
                  children: [
                    _Feature(
                      Icons.business_center_outlined,
                      context.tr('cases'),
                    ),
                    _Feature(Icons.gavel_rounded, context.tr('hearings')),
                    _Feature(Icons.task_alt_rounded, context.tr('tasks')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The internal logo is the full horizontal lockup — mark, the wordmark
/// "حقوق", and the platform tagline — at roughly 2.4:1 (1600x668).
///
/// It is rendered bare, with no surrounding card: the previous white
/// `Container` was decorative padding around an image that already carries its
/// own background, so removing it lets the wordmark itself define the shape.
class _Logo extends StatelessWidget {
  const _Logo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/app_internal_logo.jpeg',
    width: size * 2.4,
    height: size,
    fit: BoxFit.contain,
  );
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: AppColors.brass400),
      const SizedBox(width: 6),
      Text(
        label,
        style: AppTypography.bodySmall.copyWith(color: AppColors.ink100),
      ),
    ],
  );
}

class _ArabesquePainter extends CustomPainter {
  const _ArabesquePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const tile = 180.0;
    for (double y = -tile / 2; y < size.height + tile; y += tile) {
      for (double x = -tile / 2; x < size.width + tile; x += tile) {
        final center = Offset(x + tile / 2, y + tile / 2);
        final path = Path();
        for (var i = 0; i < 10; i++) {
          final radius = i.isEven ? 62.0 : 28.0;
          final angle = -math.pi / 2 + i * math.pi / 5;
          final point =
              center + Offset(math.cos(angle), math.sin(angle)) * radius;
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawCircle(center, 23, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vendor credit shown under the sign-in form: a ruled "POWERED BY" eyebrow
/// over the Ethereal lockup.
///
/// This mirrors the desktop client's block class for class. The numbers come
/// from converting its Tailwind arbitrary values to logical pixels: `mt-12` is
/// 48, `gap-4` is 16, `tracking-[0.32em]` at 10px is 3.2, `tracking-tight` is
/// -0.025em and `tracking-[0.18em]` at 9.5px is 1.71. The two colours are the
/// vendor's own brand values rather than anything from the parchment scale, so
/// the credit looks the same here as it does on the web build.
///
/// Drawn with widgets rather than shipped as one flat image so it stays crisp
/// at any density, and pinned to LTR because it is a Latin wordmark even when
/// the rest of the screen is Arabic.
class _PoweredByEthereal extends StatelessWidget {
  const _PoweredByEthereal();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Both rules fade out towards the outside edge and reach the page's
            // line colour as they meet the eyebrow, same as the web build.
            const Expanded(
              child: _CreditRule(transparentAt: Alignment.centerLeft),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'POWERED BY',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.brandBrown.withValues(alpha: .40),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 3.2,
                  height: 1,
                ),
              ),
            ),
            const Expanded(
              child: _CreditRule(transparentAt: Alignment.centerRight),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The asset is the mark alone, cropped to its own bounds with the
              // source's off-white field keyed out, so it sits on the cream
              // page without the white box the original square canvas painted.
              Image.asset(
                'assets/images/ethereal_mark.png',
                height: 36,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ethereal',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.etherealNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.45,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'SOFTWARE SOLUTIONS',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.etherealTeal,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.71,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The hairline either side of the "POWERED BY" eyebrow: fully transparent at
/// [transparentAt], reaching the page's line colour at the other end.
class _CreditRule extends StatelessWidget {
  const _CreditRule({required this.transparentAt});

  final Alignment transparentAt;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: transparentAt,
        end: Alignment(-transparentAt.x, 0),
        colors: const [Colors.transparent, AppColors.brandBorder],
      ),
    ),
    child: const SizedBox(height: 1),
  );
}
