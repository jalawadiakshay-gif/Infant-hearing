import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';
import 'package:infant_hearing_app/shared/widgets/app_card.dart';
import 'package:infant_hearing_app/shared/widgets/language_switcher.dart';

class BoaIntroScreen extends StatelessWidget {
  const BoaIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.boaTest),
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
        actions: const [
          LanguagePopupButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroHeader(l10n: l10n),
              const SizedBox(height: AppSpacing.xl),

              _SectionLabel(l10n.knowTheSigns.toUpperCase()),
              const SizedBox(height: AppSpacing.s),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.boaTest,
                      style: AppTextStyles.subheading1,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      l10n.welcomeDescription,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              _SectionLabel(l10n.boaPreChecklist.toUpperCase()),
              const SizedBox(height: AppSpacing.s),
              _CheckItem(text: l10n.preCheckQuiet),
              _CheckItem(text: l10n.preCheckInfantAlert),
              _CheckItem(text: l10n.preCheckNoDistraction),
              _CheckItem(text: l10n.preCheckDeviceVolume),

              const SizedBox(height: AppSpacing.xxxl),

              AppPrimaryButton(
                label: l10n.continueButton,
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.push(RouteConstants.boaWizard),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _HeroHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
          ),
          child: const Icon(Icons.hearing_rounded, color: AppColors.primary, size: 32),
        ),
        const SizedBox(height: AppSpacing.l),
        Text(l10n.boaTest, style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.s),
        Text(
          l10n.welcomeSubtitle,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;
  const _CheckItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 20, color: AppColors.success),
          const SizedBox(width: AppSpacing.m),
          Expanded(child: Text(text, style: AppTextStyles.bodyLarge)),
        ],
      ),
    );
  }
}
