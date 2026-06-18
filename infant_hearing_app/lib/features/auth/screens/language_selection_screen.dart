import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/app_language.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/core/providers/language_provider.dart';
import 'package:infant_hearing_app/core/services/tts_service.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final bool fromSettings;
  const LanguageSelectionScreen({super.key, this.fromSettings = false});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late AppLanguage _selected;

  @override
  void initState() {
    super.initState();
    _selected = context.read<LanguageProvider>().language;
  }

  Future<void> _confirm() async {
    final langProvider = context.read<LanguageProvider>();
    final tts = context.read<TtsService>();

    await langProvider.setLanguage(_selected);
    await tts.setLanguage(langProvider.ttsLocale);

    if (!mounted) return;

    if (widget.fromSettings) {
      Navigator.of(context).pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  ),
                  child: const Icon(Icons.hearing_rounded, size: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                l10n.welcomeTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                l10n.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: AppSpacing.xxxxl),

              Text(
                l10n.selectLanguage,
                style: AppTextStyles.subheading1.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.l),

              ...AppLanguage.values.map(
                (lang) => _LangTile(
                  language: lang,
                  isSelected: _selected == lang,
                  onTap: () => setState(() => _selected = lang),
                ),
              ),

              const Spacer(),

              AppPrimaryButton(
                onPressed: _confirm,
                label: l10n.continueButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.nativeName,
                    style: AppTextStyles.subheading1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    language.englishName,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
