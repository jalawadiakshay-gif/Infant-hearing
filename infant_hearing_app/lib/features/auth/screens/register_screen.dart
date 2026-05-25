import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();
    final success = await provider.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.showSnackBar('Account created! Please sign in.');
      context.pushReplacementNamed(RouteConstants.login);
    } else {
      context.showSnackBar(
        provider.errorMessage ?? 'Registration failed.',
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: context.pop,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.m),
                const AuthBrand(),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  'Create your\naccount',
                  style: AppTextStyles.h1.copyWith(fontSize: 32),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Register to start the hearing screening for your baby.',
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.xxxl),

                _buildSectionLabel('PERSONAL INFORMATION'),
                const SizedBox(height: AppSpacing.s),
                AppCard(
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _nameController,
                        label: AppStrings.fullName,
                        prefixIcon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => Validators.required(v, fieldName: 'Full name'),
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        focusNode: _emailFocus,
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        controller: _phoneController,
                        label: AppStrings.phoneNumber,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                        focusNode: _phoneFocus,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-]'))],
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.l),

                _buildSectionLabel('SECURITY'),
                const SizedBox(height: AppSpacing.s),
                AppCard(
                  child: Column(
                    children: [
                      PasswordField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        validator: Validators.password,
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmFocus),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      PasswordField(
                        controller: _confirmPasswordController,
                        label: AppStrings.confirmPassword,
                        validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onRegister(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.s),
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.s),
                  child: Text('• Minimum 8 characters required', style: AppTextStyles.caption),
                ),

                const SizedBox(height: AppSpacing.xxxl),
                AppPrimaryButton(
                  label: AppStrings.createAccount,
                  onPressed: _onRegister,
                  isLoading: isLoading,
                ),

                const SizedBox(height: AppSpacing.l),
                AppTextButton(
                  prefix: "${AppStrings.alreadyHaveAccount} ",
                  label: AppStrings.signIn,
                  onPressed: context.pop,
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.s),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }
}
