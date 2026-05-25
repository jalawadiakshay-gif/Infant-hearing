import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await context.read<AuthProvider>().verifyOtp(_otpController.text);
      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteConstants.roleSelection,
          (route) => false,
        );
      } else if (mounted) {
        final error = context.read<AuthProvider>().errorMessage ?? 'Invalid OTP';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = context.watch<AuthProvider>().status;
    final phone = context.read<AuthProvider>().phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Verification Code',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Please enter the code sent to\n+91 $phone',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: const InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(color: Colors.grey, letterSpacing: 8),
                ),
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter OTP';
                  if (value.length != 6) return 'Enter 6 digit OTP';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: status == AuthStatus.loading ? null : _handleVerify,
                child: status == AuthStatus.loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Verify & Proceed'),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  // Resend OTP logic
                },
                child: const Text('Resend Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
