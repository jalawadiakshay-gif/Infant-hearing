import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';
import 'package:infant_hearing_app/core/providers/app_provider.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';
import 'package:infant_hearing_app/shared/widgets/app_text_field.dart';
import 'package:infant_hearing_app/shared/widgets/app_logo.dart';

class PhoneLoginScreen extends StatelessWidget {
  const PhoneLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PhoneLoginBody();
  }
}

class _PhoneLoginBody extends StatefulWidget {
  const _PhoneLoginBody();

  @override
  State<_PhoneLoginBody> createState() => _PhoneLoginBodyState();
}

class _PhoneLoginBodyState extends State<_PhoneLoginBody> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _otpSent = false;
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  void _validatePhone() {
    final text = _phoneController.text;
    final isValid = text.length == 10 && RegExp(r'^[0-9]+$').hasMatch(text);
    if (isValid != _isPhoneValid) {
      setState(() => _isPhoneValid = isValid);
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhone);
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.sendOtp(_phoneController.text);
      
      if (!mounted) return;

      if (success) {
        setState(() => _otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully (Mock: 123456)')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to send OTP'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleVerifyOtp(AppLocalizations l10n) async {
    if (_otpController.text.length == 6) {
      final authProvider = context.read<AuthProvider>();
      final appProvider = context.read<AppProvider>();
      
      final success = await authProvider.verifyOtp(_otpController.text);
      
      if (!mounted) return;

      if (success) {
        // Refresh app data (Parent/Baby) after successful login
        await appProvider.initializeApp();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? l10n.chatbotErrorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = context.watch<AuthProvider>().status;
    final isLoading = status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                const Center(child: AppLogo(size: 100)),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.appName.toUpperCase(),
                  style: AppTextStyles.h1.copyWith(letterSpacing: 2, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.welcomeSubtitle,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                
                Text(
                  _otpSent ? 'ENTER VERIFICATION CODE' : 'LOGIN TO PROCEED',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: AppSpacing.m),
                
                AppTextField(
                  controller: _phoneController,
                  label: l10n.parentPhone,
                  hint: 'Enter 10 digit number',
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  readOnly: _otpSent,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.fieldRequired;
                    if (value.length != 10) return 'Exactly 10 digits required';
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Numbers only';
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.l),

                if (!_otpSent)
                  AppPrimaryButton(
                    onPressed: _isPhoneValid ? _handleSendOtp : null,
                    isLoading: isLoading,
                    label: l10n.continueButton,
                  ),

                if (_otpSent) ...[
                  AppTextField(
                    controller: _otpController,
                    label: 'Verification Code',
                    hint: 'Enter 6-digit OTP',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.verified_user_rounded,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppPrimaryButton(
                    onPressed: () => _handleVerifyOtp(l10n),
                    isLoading: isLoading,
                    label: l10n.submit,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextButton(
                    onPressed: () => setState(() => _otpSent = false),
                    child: Text(l10n.back, style: AppTextStyles.button.copyWith(color: AppColors.textHint)),
                  ),
                ],

                const SizedBox(height: 40),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                      child: Text('OR', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 40),
                OutlinedButton.icon(
                  onPressed: isLoading 
                      ? null 
                      : () async {
                          final success = await context.read<AuthProvider>().signInWithGoogle();
                          if (success && mounted) {
                            await context.read<AppProvider>().initializeApp();
                          }
                        },
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: const Text('CONTINUE WITH GOOGLE'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.border, width: 1.5),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'RESEARCH-GRADE CLINICAL SCREENING TOOL',
                  style: AppTextStyles.caption.copyWith(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textHint),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
