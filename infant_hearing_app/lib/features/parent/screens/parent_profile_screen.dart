import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/data/models/v2/app_user.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';
import 'package:infant_hearing_app/shared/widgets/app_text_field.dart';
import 'package:infant_hearing_app/shared/widgets/app_card.dart';
import 'package:infant_hearing_app/shared/widgets/app_dropdown.dart';

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
  late TextEditingController _emergencyContactController;
  late TextEditingController _preferredHospitalController;
  late TextEditingController _detailedAddressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;

  String? _relationshipToChild;

  bool _declarationChecked = false;

  @override
  void initState() {
    super.initState();
    final parentProvider = context.read<ParentProvider>();
    final parent = parentProvider.parent;
    final phone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

    _nameController = TextEditingController(text: parent?.name);
    _phoneController = TextEditingController(text: parent?.phone ?? phone);
    _emailController = TextEditingController(text: parent?.email);
    _emergencyContactController = TextEditingController(text: parent?.emergencyContact);
    _preferredHospitalController = TextEditingController(text: parent?.preferredHospital);
    _detailedAddressController = TextEditingController(text: parent?.detailedAddress);
    _cityController = TextEditingController(text: parent?.city);
    _stateController = TextEditingController(text: parent?.state);
    
    _relationshipToChild = parent?.relationshipToChild ?? 'Mother';
    
    _declarationChecked = parentProvider.hasDeclared;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyContactController.dispose();
    _preferredHospitalController.dispose();
    _detailedAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(AppLocalizations l10n) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_declarationChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.acceptDeclaration)),
        );
        return;
      }

      final parent = AppUser(
        uid: FirebaseAuth.instance.currentUser?.uid ?? '',
        role: 'parent',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        relationshipToChild: _relationshipToChild,
        emergencyContact: _emergencyContactController.text.trim(),
        preferredHospital: _preferredHospitalController.text.trim(),
        detailedAddress: _detailedAddressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
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
              content: Text(provider.errorMessage ?? l10n.failedSaveProfile),
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
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              if (context.mounted) {
                context.go(RouteConstants.phoneLogin);
              }
            }
          },
        ),
        title: Text(l10n.parentProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.completeProfileGuardian,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildSectionTitle(l10n.basicInformation.toUpperCase()),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(controller: _nameController, label: l10n.parentName, prefixIcon: Icons.person_outline),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(controller: _phoneController, label: l10n.parentPhone, prefixIcon: Icons.phone_outlined, readOnly: true),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(controller: _emailController, label: l10n.emailOptional, prefixIcon: Icons.email_outlined),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.l),
              _buildSectionTitle(l10n.hospitalEmergency.toUpperCase()),
              AppCard(
                child: Column(
                  children: [
                    AppDropdown<String>(
                      value: _relationshipToChild,
                      label: l10n.relationshipToChild,
                      items: [
                        DropdownMenuItem(value: 'Mother', child: Text(l10n.mother)),
                        DropdownMenuItem(value: 'Father', child: Text(l10n.fatherLabel)),
                        DropdownMenuItem(value: 'Guardian', child: Text(l10n.guardian)),
                      ],
                      onChanged: (val) => setState(() => _relationshipToChild = val),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(controller: _emergencyContactController, label: l10n.emergencyContact, prefixIcon: Icons.contact_phone_outlined),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(controller: _preferredHospitalController, label: l10n.preferredHospital, prefixIcon: Icons.add_box),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.l),
              _buildSectionTitle(l10n.addressLabel.toUpperCase()),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(controller: _detailedAddressController, label: l10n.detailedAddress, prefixIcon: Icons.home_outlined),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(controller: _cityController, label: l10n.city, prefixIcon: Icons.location_city_outlined),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: AppTextField(controller: _stateController, label: l10n.stateLabel, prefixIcon: Icons.map_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              AppCard(
                color: AppColors.primary.withValues(alpha: 0.05),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Checkbox(
                      value: _declarationChecked,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _declarationChecked = v ?? false),
                    ),
                    Expanded(
                      child: Text(
                        l10n.declarationText,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              AppPrimaryButton(
                onPressed: isLoading ? null : () => _saveProfile(l10n),
                isLoading: isLoading,
                label: l10n.saveAndNext,
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
