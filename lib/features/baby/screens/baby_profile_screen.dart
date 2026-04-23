import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/constants/route_constants.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dropdown.dart';
import '../../../shared/widgets/step_indicator.dart';
import '../../../shared/widgets/screen_header.dart';
import '../models/baby_model.dart';
import '../providers/baby_provider.dart';
import '../../parent/providers/parent_provider.dart';


class BabyProfileScreen extends StatefulWidget {
  const BabyProfileScreen({super.key});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _gestationalAgeController = TextEditingController();

  bool _nicuAdmission = false;
  String? _selectedDeliveryMode;

  final _ageFocus = FocusNode();
  final _weightFocus = FocusNode();
  final _gestFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baby = context.read<BabyProvider>().baby;
      if (baby != null) {
        _nameController.text = baby.name;
        _ageController.text = baby.ageMonths.toString();
        _weightController.text = baby.birthWeight.toString();
        _gestationalAgeController.text = baby.gestationalAge.toString();
        setState(() {
          _nicuAdmission = baby.nicuAdmission;
          _selectedDeliveryMode = baby.deliveryMode;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _gestationalAgeController.dispose();
    _ageFocus.dispose();
    _weightFocus.dispose();
    _gestFocus.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<BabyProvider>().saveBaby(
          name: _nameController.text.trim(),
          ageMonths: int.parse(_ageController.text.trim()),
          birthWeight: double.parse(_weightController.text.trim()),
          gestationalAge: int.parse(_gestationalAgeController.text.trim()),
          nicuAdmission: _nicuAdmission,
          deliveryMode: _selectedDeliveryMode!,
        );

    if (!mounted) return;

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final baby = context.read<BabyProvider>().baby!;
    final parent = context.read<ParentProvider>().parent;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Profile Complete!',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All information saved successfully.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    if (parent != null) ...[
                      _summaryRow(
                        Icons.person_outline_rounded,
                        'Parent',
                        parent.name,
                      ),
                      const SizedBox(height: 8),
                    ],
                    _summaryRow(
                      Icons.child_care_rounded,
                      'Baby',
                      baby.name,
                    ),
                    const SizedBox(height: 8),
                    _summaryRow(
                      Icons.monitor_weight_outlined,
                      'Birth Weight',
                      '${baby.birthWeight} kg',
                    ),
                    if (baby.isHighRisk) ...[
                      const SizedBox(height: 8),
                      _summaryRow(
                        Icons.warning_amber_rounded,
                        'Risk',
                        'High-risk indicators found',
                        valueColor: AppColors.warning,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.pushReplacementNamed(RouteConstants.home);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Proceed to Screening →',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: Navigator.of(ctx).pop,
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<BabyProvider, bool>((p) => p.isSaving);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: context.pop,
        ),
        title: Text(
          'Screening Setup',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: StepIndicator(
                currentStep: 2,
                totalSteps: 3,
                stepLabels: const ['Parent', 'Baby', 'Screening'],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      const ScreenHeader(
                        title: 'Baby\nProfile',
                        subtitle:
                            "Provide your baby's details to personalise the hearing screening.",
                        icon: Icons.child_care_rounded,
                      ),

                      const SizedBox(height: 32),

                      // Basic info
                      _buildSectionTitle('BASIC INFORMATION'),
                      const SizedBox(height: 12),
                      _buildCard([
                        AppTextField(
                          controller: _nameController,
                          label: AppStrings.babyName,
                          hint: "Baby's first name",
                          prefixIcon: Icons.face_rounded,
                          textCapitalization: TextCapitalization.words,
                          validator: (v) => Validators.required(v, fieldName: "Baby's name"),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_ageFocus),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _ageController,
                          label: AppStrings.babyAgeMonths,
                          hint: 'e.g. 3',
                          prefixIcon: Icons.calendar_month_outlined,
                          keyboardType: TextInputType.number,
                          validator: Validators.ageMonths,
                          focusNode: _ageFocus,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_weightFocus),
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // Clinical info
                      _buildSectionTitle('CLINICAL DETAILS'),
                      const SizedBox(height: 12),
                      _buildCard([
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _weightController,
                                label: AppStrings.birthWeight,
                                hint: 'e.g. 2.8',
                                prefixIcon: Icons.monitor_weight_outlined,
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: Validators.weight,
                                focusNode: _weightFocus,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).requestFocus(_gestFocus),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                controller: _gestationalAgeController,
                                label: AppStrings.gestationalAge,
                                hint: 'e.g. 38',
                                prefixIcon: Icons.pregnant_woman_outlined,
                                keyboardType: TextInputType.number,
                                validator: Validators.gestationalAge,
                                focusNode: _gestFocus,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppDropdown<String>(
                          value: _selectedDeliveryMode,
                          label: AppStrings.deliveryMode,
                          hint: 'Select delivery mode',
                          prefixIcon: Icons.local_hospital_outlined,
                          items: DeliveryMode.values
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m.label,
                                  child: Text(m.label),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedDeliveryMode = v),
                          validator: (v) =>
                              v == null ? 'Please select delivery mode' : null,
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // NICU section
                      _buildSectionTitle('NICU STATUS'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _nicuAdmission
                                    ? AppColors.warning.withOpacity(0.15)
                                    : AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.local_hospital_rounded,
                                size: 20,
                                color: _nicuAdmission
                                    ? AppColors.warning
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.nicuAdmission,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _nicuAdmission
                                        ? 'Baby was admitted to NICU'
                                        : 'Baby was not admitted to NICU',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _nicuAdmission,
                              onChanged: (v) =>
                                  setState(() => _nicuAdmission = v),
                              activeColor: AppColors.primary,
                              activeTrackColor: AppColors.primaryLight,
                            ),
                          ],
                        ),
                      ),

                      // High risk warning
                      if (_nicuAdmission) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.warning.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.warning,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'NICU admission is a risk factor for hearing loss. Screening is strongly recommended.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: const Color(0xFF856404),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 36),

                      AppPrimaryButton(
                        label: AppStrings.continueBtn,
                        onPressed: _onContinue,
                        isLoading: isSaving,
                      ),

                      const SizedBox(height: 32),
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
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
