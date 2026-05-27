import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/features/parent/models/parent_model.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';

/// A lightweight parent-profile form shown immediately after role selection.
/// FIX 7: Now calls ParentProvider.saveParent() so hasParentData becomes true
/// and _RootNavigator routes to MainLayoutScreen instead of looping back here.
class SimpleParentProfileScreen extends StatefulWidget {
  const SimpleParentProfileScreen({super.key});

  @override
  State<SimpleParentProfileScreen> createState() =>
      _SimpleParentProfileScreenState();
}

class _SimpleParentProfileScreenState
    extends State<SimpleParentProfileScreen> {
  final _formKey              = GlobalKey<FormState>();
  final _parentNameController = TextEditingController();
  final _cityController       = TextEditingController();
  final _emergencyController  = TextEditingController();

  String _relationship = 'Mother';

  @override
  void dispose() {
    _parentNameController.dispose();
    _cityController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth         = context.read<AuthProvider>();
    final provider     = context.read<ParentProvider>();

    final parent = ParentModel(
      id:               DateTime.now().millisecondsSinceEpoch.toString(),
      name:             _parentNameController.text.trim(),
      phone:            auth.phoneNumber ?? '',
      email:            null,
      address:          _cityController.text.trim(),
      city:             _cityController.text.trim(),
      state:            '',
      emergencyContact: _emergencyController.text.trim(),
      relationship:     _relationship,
      preferredHospital: null,
      isVerified:       false,
    );

    provider.setDeclaration(true);
    await provider.saveParent(parent);

    if (!mounted) return;

    // FIX 7: Navigate to babyProfile (next onboarding step).
    // _RootNavigator will then forward to MainLayoutScreen once baby is saved.
    context.go(RouteConstants.babyProfile);
  }

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final isSaving = context.watch<ParentProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Complete your profile to get started',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              _buildLabel('Your Name *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _parentNameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration('Full name', Icons.person),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),

              const SizedBox(height: 20),
              _buildLabel('Relationship to Baby'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _relationship,
                decoration: _inputDecoration('Relationship', Icons.family_restroom),
                items: ['Mother', 'Father', 'Guardian']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _relationship = v!),
              ),

              const SizedBox(height: 20),
              _buildLabel('City / Village'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: _inputDecoration('City or village', Icons.location_city),
              ),

              const SizedBox(height: 20),
              _buildLabel('Emergency Contact Number'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emergencyController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('10-digit mobile number', Icons.contact_phone),
              ),

              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: isSaving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save & Continue',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      );
}
