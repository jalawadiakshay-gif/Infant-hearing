import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/constants/app_language.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/core/providers/language_provider.dart';
import 'package:infant_hearing_app/core/services/tts_service.dart';

class LanguageSelectorList extends StatelessWidget {
  const LanguageSelectorList({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.s),
          child: Text(
            l10n.changeLanguage,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        ...AppLanguage.values.map(
          (lang) => RadioListTile<AppLanguage>(
            value: lang,
            groupValue: langProvider.language,
            title: Text(lang.nativeName, style: AppTextStyles.subheading2.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text(lang.englishName, style: AppTextStyles.caption),
            activeColor: AppColors.primary,
            onChanged: (selected) async {
              if (selected == null) return;
              await _applyLanguage(context, selected);
            },
          ),
        ),
      ],
    );
  }
}

class LanguagePopupButton extends StatelessWidget {
  const LanguagePopupButton({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final current = langProvider.language;

    return PopupMenuButton<AppLanguage>(
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusM)),
      // Premium text-based language selector — no flags
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          color: AppColors.primaryLight.withOpacity(0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show abbreviated code in uppercase
            Text(
              current.code.toUpperCase(),
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppColors.primary),
          ],
        ),
      ),
      onSelected: (lang) => _applyLanguage(context, lang),
      itemBuilder: (_) => AppLanguage.values.map((lang) {
        final isSelected = lang == current;
        return PopupMenuItem<AppLanguage>(
          value: lang,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    lang.code.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.nativeName,
                    style: AppTextStyles.subheading2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(lang.englishName, style: AppTextStyles.caption),
                ],
              ),
              if (isSelected) ...[
                const Spacer(),
                const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

Future<void> _applyLanguage(BuildContext context, AppLanguage lang) async {
  final langProvider = context.read<LanguageProvider>();
  final tts = context.read<TtsService>();
  await langProvider.setLanguage(lang);
  await tts.setLanguage(langProvider.ttsLocale);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${lang.nativeName} (${lang.englishName})'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
