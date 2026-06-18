import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/data/models/v2/app_user.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _districtController   = TextEditingController();

  @override
  void dispose() {
    _parentNameController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth         = FirebaseAuth.instance;
    final provider     = context.read<ParentProvider>();

    final parent = AppUser(
      uid:              auth.currentUser?.uid ?? '',
      role:             'parent',
      name:             _parentNameController.text.trim(),
      phone:            auth.currentUser?.phoneNumber ?? '',
      district:         _districtController.text.trim(),
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
    final l10n     = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.yourProfile),
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
                l10n.completeProfileGuardian,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              _buildLabel('${l10n.parentName} *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _parentNameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(l10n.parentName, Icons.person),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),

              const SizedBox(height: 20),
              _buildLabel('District'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _districtController,
                decoration: _inputDecoration('District', Icons.location_city),
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
                    : Text(
                        l10n.saveAndNext,
                        style: const TextStyle(
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
