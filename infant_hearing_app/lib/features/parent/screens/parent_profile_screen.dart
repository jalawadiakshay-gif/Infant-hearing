import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/features/parent/models/parent_model.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';
import 'package:infant_hearing_app/shared/widgets/app_text_field.dart';
import 'package:infant_hearing_app/shared/widgets/app_card.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _preferredHospitalController;

  String _relationship = 'Mother';
  bool _declarationChecked = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final parentProvider = context.read<ParentProvider>();
    final parent = parentProvider.parent;

    _nameController = TextEditingController(text: parent?.name);
    _phoneController = TextEditingController(text: parent?.phone ?? auth.phoneNumber);
    _emailController = TextEditingController(text: parent?.email);
    _addressController = TextEditingController(text: parent?.address);
    _cityController = TextEditingController(text: parent?.city);
    _stateController = TextEditingController(text: parent?.state);
    _emergencyContactController = TextEditingController(text: parent?.emergencyContact);
    _preferredHospitalController = TextEditingController(text: parent?.preferredHospital);
    
    if (parent != null) {
      _relationship = parent.relationship;
    }
    _declarationChecked = parentProvider.hasDeclared;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _emergencyContactController.dispose();
    _preferredHospitalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(AppLocalizations l10n) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_declarationChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the declaration to proceed.')),
        );
        return;
      }

      final parent = ParentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim(),
        relationship: _relationship,
        preferredHospital: _preferredHospitalController.text.trim(),
      );

      final provider = context.read<ParentProvider>();
      provider.setDeclaration(true);
      final success = await provider.saveParent(parent);
      
      if (mounted) {
        if (success) {
          context.go(RouteConstants.babyProfile);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to save profile'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoading = context.watch<ParentProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () async {
            await context.read<AuthProvider>().logout();
            if (mounted) context.go(RouteConstants.phoneLogin);
          },
        ),
        title: const Text('Parent Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Complete your profile as a primary guardian.',
                style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildSectionTitle('BASIC INFORMATION'),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(controller: _nameController, label: l10n.parentName, prefixIcon: Icons.person_outline),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(controller: _phoneController, label: l10n.parentPhone, prefixIcon: Icons.phone_outlined, readOnly: true),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(controller: _emailController, label: 'Email Address (Optional)', prefixIcon: Icons.email_outlined, validator: null),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.l),
              _buildSectionTitle('HOSPITAL & EMERGENCY'),
              AppCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _relationship,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Relationship to Child',
                        prefixIcon: Icon(Icons.people_outline, size: 20),
                      ),
                      items: ['Mother', 'Father', 'Guardian'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _relationship = v!),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(
                      controller: _emergencyContactController,
                      label: 'Emergency Contact Number',
                      prefixIcon: Icons.contact_phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(
                      controller: _preferredHospitalController,
                      label: 'Preferred Hospital',
                      prefixIcon: Icons.local_hospital_outlined,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.l),
              _buildSectionTitle('ADDRESS'),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(controller: _addressController, label: 'Detailed Address', prefixIcon: Icons.home_outlined, maxLines: 2),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: _cityController, label: 'City', prefixIcon: Icons.location_city_outlined)),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(child: AppTextField(controller: _stateController, label: 'State', prefixIcon: Icons.map_outlined)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              AppCard(
                color: AppColors.primary.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Checkbox(
                      value: _declarationChecked,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _declarationChecked = v ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'I confirm that I am the parent or legal guardian of the child being added.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              AppPrimaryButton(
                onPressed: isLoading ? null : () => _saveProfile(l10n),
                isLoading: isLoading,
                label: 'Save & Next: Add Your Child',
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.s, bottom: AppSpacing.s),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.info,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
