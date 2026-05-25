import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_language.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/services/tts_service.dart';

/// Allows the user to change the app language at any time.
/// Drop this widget inside your Settings screen.
class LanguageSettingsWidget extends StatelessWidget {
  const LanguageSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langProvider = context.watch<LanguageProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            l10n.changeLanguage,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        ...AppLanguage.values.map(
          (lang) => RadioListTile<AppLanguage>(
            value: lang,
            groupValue: langProvider.currentLanguage,
            title: Text(lang.nativeName),
            subtitle: Text(lang.englishName),
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (selected) async {
              if (selected == null) return;
              final tts = context.read<TtsService>();
              await langProvider.setLanguage(selected);
              await tts.setLanguage(langProvider.ttsLocale);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${selected.nativeName} (${selected.englishName})'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}