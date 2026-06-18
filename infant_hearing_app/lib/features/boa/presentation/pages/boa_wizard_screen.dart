import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';

class BoaWizardScreen extends StatefulWidget {
  const BoaWizardScreen({super.key});

  @override
  State<BoaWizardScreen> createState() => _BoaWizardScreenState();
}

class _BoaWizardScreenState extends State<BoaWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.boaClinicalWizard),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPrepStep(l10n),
                _buildPositioningStep(l10n),
                _buildTestingStep(l10n),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(l10n),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPrepStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.clinicalPreparation, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.s),
          Text(l10n.ensureConditions, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          _CheckTile(title: l10n.quietEnvironment, subtitle: l10n.ambientNoise, icon: Icons.volume_off_rounded),
          _CheckTile(title: l10n.infantStateLabel, subtitle: l10n.alertButCalm, icon: Icons.child_care_rounded),
          _CheckTile(title: l10n.deviceCalibration, subtitle: l10n.volumeAt80, icon: Icons.tune_rounded),
          _CheckTile(title: l10n.distractionFree, subtitle: l10n.noToysLights, icon: Icons.visibility_off_rounded),
        ],
      ),
    );
  }

  Widget _buildPositioningStep(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          Text(l10n.infantPositioning, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.face_retouching_natural_rounded, color: Colors.white, size: 120),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.positionInstructions,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestingStep(AppLocalizations l10n) {
    return Center(
      child: Text(l10n.testComplete),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: ElevatedButton(
          onPressed: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            } else {
              context.go(RouteConstants.boaTest);
            }
          },
          child: Text(_currentStep == 2 ? l10n.startClinicalTest : l10n.continueButton),
        ),
      ),
    );
  }
}

class _CheckTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _CheckTile({required this.title, required this.subtitle, required this.icon});

  @override
  State<_CheckTile> createState() => _CheckTileState();
}

class _CheckTileState extends State<_CheckTile> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: _checked,
      onChanged: (val) => setState(() => _checked = val ?? false),
      title: Text(widget.title, style: AppTextStyles.subheading1),
      subtitle: Text(widget.subtitle, style: AppTextStyles.bodyMedium),
      secondary: Icon(widget.icon, color: AppColors.primary),
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusM)),
    );
  }
}
