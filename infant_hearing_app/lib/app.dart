import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';
import 'package:infant_hearing_app/features/asha/providers/asha_provider.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:infant_hearing_app/features/baby/providers/baby_provider.dart';
import 'package:infant_hearing_app/core/navigation/app_router.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/core/providers/language_provider.dart';
import 'package:infant_hearing_app/core/theme/app_theme.dart';
import 'package:infant_hearing_app/features/boa/presentation/controllers/boa_controller.dart';
import 'package:infant_hearing_app/features/boa/presentation/controllers/boa_checklist_controller.dart';
import 'package:infant_hearing_app/shared/repositories/boa_repository.dart';
import 'package:infant_hearing_app/core/services/tts_service.dart';

class InfantHearingApp extends StatelessWidget {
  const InfantHearingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (ctx) => BoaController(
                boaRepository: ctx.read<BoaRepository>(),
                ttsService: ctx.read<TtsService>(),
              )..initialize(),
            ),
            ChangeNotifierProvider(create: (_) => BoaChecklistController()),
          ],
          child: MaterialApp.router(
            title: 'Baalshravya',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: langProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: AppRouter.router(
              Listenable.merge([
                langProvider,
                context.read<AuthProvider>(),
                context.read<AshaProvider>(),
                context.read<ParentProvider>(),
                context.read<BabyProvider>(),
              ]),
            ),
          ),
        );
      },
    );
  }
}
