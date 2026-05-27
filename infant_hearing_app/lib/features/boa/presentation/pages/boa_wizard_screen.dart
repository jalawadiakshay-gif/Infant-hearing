import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import '../controllers/boa_controller.dart';
import '../state/boa_state.dart';
import '../../domain/boa_models.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BOA Clinical Wizard'),
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
                _buildPrepStep(),
                _buildPositioningStep(),
                _buildTestingStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
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

  Widget _buildPrepStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clinical Preparation', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.s),
          Text('Ensure the following conditions are met for an accurate test.', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          _CheckTile(title: 'Quiet Environment', subtitle: 'Ambient noise < 40dB', icon: Icons.volume_off_rounded),
          _CheckTile(title: 'Infant State', subtitle: 'Alert but calm/quiet', icon: Icons.child_care_rounded),
          _CheckTile(title: 'Device Calibration', subtitle: 'Volume at 80%', icon: Icons.tune_rounded),
          _CheckTile(title: 'Distraction Free', subtitle: 'No toys or bright lights', icon: Icons.visibility_off_rounded),
        ],
      ),
    );
  }

  Widget _buildPositioningStep() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          Text('Infant Positioning', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.face_retouching_natural_rounded, color: Colors.white24, size: 80),
                  Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_m6cu96.json', // Medical scan anim
                    width: 200,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Place the infant facing away from the caregiver. Hold the device 12 inches from the ear.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestingStep() {
    return const Center(
      child: Text('Testing logic will go here (Connecting to BoaTestScreen)'),
    );
  }

  Widget _buildBottomBar() {
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
          child: Text(_currentStep == 2 ? 'Start Clinical Test' : 'Continue'),
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
