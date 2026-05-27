import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/auth_provider.dart';
import '../widgets/password_field.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();
    final success = await provider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.showSnackBar('Welcome back!');
      context.go(RouteConstants.simpleParentProfile);
    } else {
      context.showSnackBar(
        provider.errorMessage ?? 'Login failed. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>(
      (p) => p.status == AuthStatus.loading,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                const AuthBrand(),
                const SizedBox(height: AppSpacing.xxxxl),
                Text(
                  'Welcome\nback',
                  style: AppTextStyles.h1.copyWith(fontSize: 32),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sign in to continue the screening process.',
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.xxxxl),

                AppCard(
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PasswordField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        validator: Validators.password,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onLogin(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.s),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppTextButton(
                    onPressed: () {},
                    label: 'Forgot password?',
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
                AppPrimaryButton(
                  label: AppStrings.signIn,
                  onPressed: _onLogin,
                  isLoading: isLoading,
                ),

                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                      child: Text('or', style: AppTextStyles.caption),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),
                AppTextButton(
                  prefix: "${AppStrings.dontHaveAccount} ",
                  label: AppStrings.signUp,
                  onPressed: () => context.push(RouteConstants.register),
                ),

                const SizedBox(height: AppSpacing.xxxl),
                AppCard(
                  color: AppColors.secondary.withValues(alpha: 0.05),
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          'Demo mode: enter any valid email & 8+ char password.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
