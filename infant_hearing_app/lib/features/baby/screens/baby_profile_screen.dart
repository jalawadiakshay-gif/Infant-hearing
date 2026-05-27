import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dropdown.dart';
import '../../../shared/widgets/step_indicator.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/baby_provider.dart';

class BabyProfileScreen extends StatefulWidget {
  const BabyProfileScreen({super.key});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _weightController = TextEditingController();
  final _gestationalAgeController = TextEditingController();
  final _medicalNotesController = TextEditingController();

  bool _nicuAdmission = false;
  String? _selectedDeliveryMode;
  String? _selectedGender;
  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final baby = context.read<BabyProvider>().baby;
      if (baby != null) {
        _nameController.text = baby.name;
        _selectedDob = baby.dob;
        _dobController.text = DateFormat('dd/MM/yyyy').format(baby.dob);
        _weightController.text = baby.birthWeight.toString();
        _gestationalAgeController.text = baby.gestationalAge.toString();
        _medicalNotesController.text = baby.medicalNotes ?? '';
        setState(() {
          _nicuAdmission = baby.nicuAdmission;
          _selectedDeliveryMode = baby.deliveryMode;
          _selectedGender = baby.gender;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _gestationalAgeController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _selectDob() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now(),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  static DateTime get now => DateTime.now();

  Future<void> _onContinue(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }

    if (_selectedDeliveryMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select mode of delivery')),
      );
      return;
    }

    final success = await context.read<BabyProvider>().saveBaby(
          name: _nameController.text.trim(),
          dob: _selectedDob!,
          gender: _selectedGender!,
          birthWeight: double.tryParse(_weightController.text.trim()) ?? 0.0,
          gestationalAge: int.tryParse(_gestationalAgeController.text.trim()) ?? 0,
          nicuAdmission: _nicuAdmission,
          deliveryMode: _selectedDeliveryMode!,
          medicalNotes: _medicalNotesController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      _showSuccessDialog(l10n);
    } else {
      final error = context.read<BabyProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to save profile'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusL)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                l10n.sectionComplete,
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                l10n.done,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go(RouteConstants.mainLayout);
                },
                label: l10n.continueButton,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSaving = context.select<BabyProvider, bool>((p) => p.isSaving);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Profile'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: StepIndicator(
                currentStep: 2,
                totalSteps: 3,
                stepLabels: [l10n.parentInfo, l10n.welcomeSubtitle, l10n.questionnaire],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScreenHeader(
                        title: l10n.welcomeSubtitle,
                        subtitle: l10n.welcomeDescription,
                        icon: Icons.child_care_rounded,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      _buildSectionTitle('BASIC INFORMATION'),
                      AppCard(
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _nameController,
                              label: l10n.infantName,
                              prefixIcon: Icons.face_rounded,
                              textCapitalization: TextCapitalization.words,
                              validator: (v) => Validators.required(v, fieldName: l10n.infantName),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    controller: _dobController,
                                    label: 'Date of Birth',
                                    prefixIcon: Icons.calendar_today_outlined,
                                    readOnly: true,
                                    onTap: _selectDob,
                                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.m),
                                Expanded(
                                  child: AppDropdown<String>(
                                    value: _selectedGender,
                                    label: 'Gender',
                                    prefixIcon: Icons.people_outline,
                                    items: const [
                                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                                    ],
                                    onChanged: (v) => setState(() => _selectedGender = v),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.l),

                      _buildSectionTitle('CLINICAL DETAILS'),
                      AppCard(
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _weightController,
                              label: l10n.birthWeight,
                              prefixIcon: Icons.monitor_weight_outlined,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) => Validators.weight(v),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            AppTextField(
                              controller: _gestationalAgeController,
                              label: l10n.gestationalAge,
                              prefixIcon: Icons.hourglass_empty_rounded,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (v) => Validators.gestationalAge(v),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            AppDropdown<String>(
                              value: _selectedDeliveryMode,
                              label: l10n.deliveryMode,
                              prefixIcon: Icons.local_hospital_outlined,
                              items: [
                                DropdownMenuItem(value: 'Normal', child: Text(l10n.normalDelivery)),
                                DropdownMenuItem(value: 'C-Section', child: Text(l10n.cesareanDelivery)),
                              ],
                              onChanged: (v) => setState(() => _selectedDeliveryMode = v),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.l),

                      _buildSectionTitle('NICU STATUS'),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: SwitchListTile(
                          title: Text(l10n.nicuAdmission, style: AppTextStyles.subheading1),
                          value: _nicuAdmission,
                          onChanged: (v) => setState(() => _nicuAdmission = v),
                          activeColor: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      AppPrimaryButton(
                        label: l10n.continueButton,
                        onPressed: () => _onContinue(l10n),
                        isLoading: isSaving,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
          color: AppColors.primary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
