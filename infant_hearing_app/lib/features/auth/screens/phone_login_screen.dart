import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/constants/app_strings.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';
import 'package:infant_hearing_app/core/providers/app_provider.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/utils/validators.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';
import 'package:infant_hearing_app/shared/widgets/app_text_field.dart';
import 'package:infant_hearing_app/shared/widgets/app_card.dart';
import 'package:infant_hearing_app/shared/widgets/app_logo.dart';
import 'package:infant_hearing_app/features/auth/widgets/password_field.dart';

class PhoneLoginScreen extends StatelessWidget {
  const PhoneLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _UnifiedLoginBody();
  }
}

class _UnifiedLoginBody extends StatefulWidget {
  const _UnifiedLoginBody();

  @override
  State<_UnifiedLoginBody> createState() => _UnifiedLoginBodyState();
}

class _UnifiedLoginBodyState extends State<_UnifiedLoginBody> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Phone OTP controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneFormKey = GlobalKey<FormState>();
  bool _otpSent = false;
  bool _isPhoneValid = false;

  // Email controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
    _phoneController.removeListener(_validatePhone);
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        action: message.toLowerCase().contains('register') || message.toLowerCase().contains('not found') || message.toLowerCase().contains('not registered')
            ? SnackBarAction(
                label: 'REGISTER',
                textColor: Colors.white,
                onPressed: () => context.push(RouteConstants.register),
              )
            : null,
      ),
    );
  }

  Future<void> _handleSendOtp(AppLocalizations l10n) async {
    if (_phoneFormKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.sendOtp(_phoneController.text.trim());
      
      if (!mounted) return;

      if (success && authProvider.status != AuthStatus.error) {
        setState(() => _otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.otpSentSuccess)),
        );
      } else {
        _showError(authProvider.errorMessage ?? l10n.failedSendOtp);
      }
    }
  }

  Future<void> _handleVerifyOtp(AppLocalizations l10n) async {
    if (_otpController.text.length == 6) {
      final authProvider = context.read<AuthProvider>();
      final appProvider = context.read<AppProvider>();
      
      final success = await authProvider.verifyOtp(_otpController.text.trim());
      
      if (!mounted) return;

      if (success && authProvider.status != AuthStatus.error) {
        await appProvider.initializeApp();
      } else {
        _showError(authProvider.errorMessage ?? l10n.chatbotErrorMessage);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterSixDigitOtp)),
      );
    }
  }

  Future<void> _handleEmailLogin() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    final appProvider = context.read<AppProvider>();

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success && authProvider.status != AuthStatus.error) {
      await appProvider.initializeApp();
    } else {
      _showError(authProvider.errorMessage ?? 'Login failed. Please try again.');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    final appProvider = context.read<AppProvider>();

    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success && authProvider.status != AuthStatus.error) {
      await appProvider.initializeApp();
    } else {
      if (authProvider.status != AuthStatus.idle) {
        _showError(authProvider.errorMessage ?? 'Google Sign In failed.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = context.watch<AuthProvider>().status;
    final isLoading = status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () {
            if (_otpSent) {
              setState(() => _otpSent = false);
            } else {
              context.go(RouteConstants.roleSelection);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    const Center(child: AppLogo(size: 80)),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      l10n.appName.toUpperCase(),
                      style: AppTextStyles.h1.copyWith(letterSpacing: 2, fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Parent / Caregiver Sign In',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: AppTextStyles.button.copyWith(fontSize: 14),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Phone OTP', icon: Icon(Icons.phone_android_rounded, size: 18)),
                          Tab(text: 'Email / Google', icon: Icon(Icons.mail_outline_rounded, size: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tab Views inside sizing builder
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        return _tabController.index == 0
                            ? _buildPhoneTab(l10n, isLoading)
                            : _buildEmailGoogleTab(l10n, isLoading);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Footer Navigation to Register
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("New user? ", style: AppTextStyles.bodyMedium),
                  InkWell(
                    onTap: () => context.push(RouteConstants.register),
                    child: Text(
                      "Register First",
                      style: AppTextStyles.button.copyWith(color: AppColors.primary, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneTab(AppLocalizations l10n, bool isLoading) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _otpSent ? l10n.enterVerificationCode.toUpperCase() : l10n.loginToProceed.toUpperCase(),
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, color: AppColors.textSecondary),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: AppSpacing.m),
          if (!_otpSent) ...[
            AppTextField(
              controller: _phoneController,
              label: AppStrings.phoneNumber,
              hint: l10n.enterPhoneHint,
              prefixIcon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.fieldRequired;
                }
                if (value.length != 10) {
                  return AppStrings.invalidPhone;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppPrimaryButton(
              label: 'Send OTP',
              onPressed: (_isPhoneValid && !isLoading) ? () => _handleSendOtp(l10n) : null,
              isLoading: isLoading,
            ),
          ] else ...[
            AppTextField(
              controller: _otpController,
              label: l10n.verificationCode,
              hint: '000000',
              prefixIcon: Icons.lock_outline_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (val) => (val == null || val.length < 6) ? l10n.enterSixDigitOtp : null,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppPrimaryButton(
              label: 'Verify & Login',
              onPressed: !isLoading ? () => _handleVerifyOtp(l10n) : null,
              isLoading: isLoading,
            ),
            const SizedBox(height: AppSpacing.m),
            Center(
              child: TextButton(
                onPressed: isLoading ? null : () => setState(() => _otpSent = false),
                child: Text('Change Phone Number', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            color: AppColors.primary.withValues(alpha: 0.05),
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Text(
                    "You must be a registered parent/caregiver to log in with OTP.",
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailGoogleTab(AppLocalizations l10n, bool isLoading) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SIGN IN WITH EMAIL OR GOOGLE',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            controller: _emailController,
            label: 'Email Address',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
          ),
          const SizedBox(height: AppSpacing.m),
          PasswordField(
            controller: _passwordController,
            label: 'Password',
            validator: Validators.password,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleEmailLogin(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppPrimaryButton(
            label: 'Sign In with Email',
            onPressed: !isLoading ? _handleEmailLogin : null,
            isLoading: isLoading,
          ),
          const SizedBox(height: AppSpacing.l),
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
          const SizedBox(height: AppSpacing.l),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : _handleGoogleSignIn,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.white,
              ),
              icon: const Icon(Icons.g_mobiledata_rounded, size: 32, color: Colors.blue),
              label: Text(
                'Sign In with Google',
                style: AppTextStyles.button.copyWith(color: AppColors.textPrimary, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
