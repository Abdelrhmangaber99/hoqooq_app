import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'youssefusama@gmail.com');
  final _passwordController = TextEditingController(text: '12345678');
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // App Bar Logo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.balance, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.tr('lexora'),
                    style: AppTypography.h3.copyWith(fontSize: 24),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Welcome Text
              Text(context.tr('welcome_back'), style: AppTypography.h1.copyWith(fontSize: 48, height: 1.1)),
              const SizedBox(height: 16),
              Text(
                context.tr('sign_in_to_workspace'),
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              
              const SizedBox(height: 48),
              
              // Form Fields
              AppTextField(
                label: context.tr('email_address'),
                hint: 'your@email.com',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: context.tr('password'),
                hint: 'Enter your password',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    context.tr('forgot_password'),
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Sign In Button
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    context.go(AppRouter.home);
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                    );
                  }
                },
                builder: (context, state) {
                  return AppButton(
                    text: context.tr('sign_in'),
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      context.read<AuthBloc>().add(LoginRequested(
                        _emailController.text,
                        _passwordController.text,
                      ));
                    },
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.surfaceLight)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      context.tr('or_continue_with'),
                      style: AppTypography.bodySmall.copyWith(fontSize: 10),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.surfaceLight)),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Social Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: context.tr('google'),
                      style: AppButtonStyle.secondary,
                      onPressed: () {},
                      icon: Icons.g_mobiledata, // Placeholder for Google Icon
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: context.tr('apple'),
                      style: AppButtonStyle.secondary,
                      onPressed: () {},
                      icon: Icons.apple,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 60),
              
              // Footer
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.bodyMedium,
                    children: [
                      TextSpan(text: '${context.tr('new_to_lexora')} '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => context.push(AppRouter.signUp),
                          child: Text(
                            context.tr('create_account'),
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
