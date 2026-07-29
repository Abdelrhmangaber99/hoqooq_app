import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firmController = TextEditingController();
  final _passwordController = TextEditingController();

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
              const SizedBox(height: 16),
              
              // Back Button
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text('Create your\naccount.', style: AppTypography.h1.copyWith(fontSize: 48, height: 1.1)),
              const SizedBox(height: 16),
              Text(
                'Join thousands of legal professionals',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              
              const SizedBox(height: 40),
              
              // Form Fields
              AppTextField(
                label: 'Full Name',
                hint: 'James Reynolds',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Email',
                hint: 'you@lawfirm.com',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Law Firm',
                hint: 'Reynolds & Associates',
                controller: _firmController,
                prefixIcon: Icons.business_outlined,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Password',
                hint: 'Create strong password',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              
              const SizedBox(height: 16),
              
              // Password Requirements
              _buildRequirementRow(Icons.check_circle_outline, 'Uppercase letter', true),
              _buildRequirementRow(Icons.check_circle_outline, 'Number or symbol', true),
              _buildRequirementRow(Icons.check_circle_outline, '8+ characters', true),
              
              const SizedBox(height: 40),
              
              // Create Account Button
              AppButton(
                text: 'Create Account',
                onPressed: () => context.go(AppRouter.home),
              ),
              
              const SizedBox(height: 24),
              
              // Terms & Privacy
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      children: [
                        const TextSpan(text: 'By creating an account you agree to our '),
                        TextSpan(
                          text: 'Terms & Privacy Policy',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Footer
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.bodyMedium,
                    children: [
                      const TextSpan(text: 'Have an account? '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Sign in',
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

  Widget _buildRequirementRow(IconData icon, String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isMet ? AppColors.primary : AppColors.textHint,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: isMet ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
