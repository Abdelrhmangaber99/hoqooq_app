import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
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
    required this.showMobileLogo,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onTogglePassword,
    required this.onRememberChanged,
  });

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(authState.message)));
        }
      },
      builder: (context, authState) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showMobileLogo) ...[
            const Center(child: _Logo(size: 54)),
            const SizedBox(height: 28),
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
            onPressed: () => context.read<AuthBloc>().add(
              LoginRequested(
                emailController.text.trim(),
                passwordController.text,
              ),
            ),
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
        ],
      ),
    );
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
                const _Logo(size: 66),
                const SizedBox(height: 16),
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

class _Logo extends StatelessWidget {
  const _Logo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/hoqooq-logo.png',
    width: size,
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
