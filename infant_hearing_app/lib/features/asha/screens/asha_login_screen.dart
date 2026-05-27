import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/asha_provider.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';
import 'package:infant_hearing_app/shared/widgets/app_text_field.dart';

class AshaLoginScreen extends StatefulWidget {
  const AshaLoginScreen({super.key});

  @override
  State<AshaLoginScreen> createState() => _AshaLoginScreenState();
}

class _AshaLoginScreenState extends State<AshaLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ashaIdController = TextEditingController();
  final _pinController = TextEditingController();
  bool _pinVisible = false;

  @override
  void dispose() {
    _ashaIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AshaProvider>();
    final success = await provider.login(
      ashaId: _ashaIdController.text.trim(),
      pin: _pinController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go(RouteConstants.ashaDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Header
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.badge_outlined,
                      size: 36, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  'ASHA Worker Login',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in with your ASHA ID and PIN',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 36),

                // ASHA ID field
                AppTextField(
                  controller: _ashaIdController,
                  label: 'ASHA Worker ID',
                  hint: 'e.g. ASHA001',
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your ASHA ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // PIN field
                AppTextField(
                  controller: _pinController,
                  label: 'PIN',
                  hint: 'Enter your 4-digit PIN',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_pinVisible,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _pinVisible ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _pinVisible = !_pinVisible),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your PIN';
                    }
                    if (value.trim().length < 4) {
                      return 'PIN must be 4 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Error message
                Consumer<AshaProvider>(
                  builder: (context, provider, _) {
                    if (provider.status == AshaStatus.error &&
                        provider.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          provider.errorMessage!,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 28),

                // Login button — using AppPrimaryButton (your project's widget)
                Consumer<AshaProvider>(
                  builder: (context, provider, _) {
                    return AppPrimaryButton(
                      label: 'Sign In',
                      isLoading: provider.status == AshaStatus.loading,
                      onPressed: _handleLogin,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Switch to Parent Mode
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      context.go(RouteConstants.roleSelection);
                    },
                    icon: const Icon(Icons.swap_horiz_rounded,
                        color: Color(0xFF2563EB)),
                    label: const Text(
                      'SWITCH TO PARENT MODE',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Demo hint
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Demo: ID = ASHA001  •  PIN = 1234',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
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