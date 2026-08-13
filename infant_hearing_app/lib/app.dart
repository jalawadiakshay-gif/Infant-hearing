import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';
import 'package:infant_hearing_app/features/asha/providers/asha_provider.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:infant_hearing_app/features/baby/providers/baby_provider.dart';
import 'package:infant_hearing_app/core/navigation/app_router.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/core/providers/language_provider.dart';
import 'package:infant_hearing_app/core/providers/app_provider.dart';
import 'package:infant_hearing_app/core/theme/app_theme.dart';
import 'package:infant_hearing_app/features/boa/presentation/controllers/boa_checklist_controller.dart';

class InfantHearingApp extends StatefulWidget {
  const InfantHearingApp({super.key});

  @override
  State<InfantHearingApp> createState() => _InfantHearingAppState();
}

class _InfantHearingAppState extends State<InfantHearingApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Create the router once and keep it stable across rebuilds
    _router = AppRouter.router(
      Listenable.merge([
        context.read<LanguageProvider>(),
        context.read<AuthProvider>(),
        context.read<AshaProvider>(),
        context.read<ParentProvider>(),
        context.read<BabyProvider>(),
        context.read<AppProvider>(), // Ensure app initialization triggers redirect
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BoaChecklistController()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, child) {
          return MaterialApp.router(
            title: 'Baalshravya',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: langProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router, // Use the stable router instance
          );
        },
      ),
    );
  }
}
