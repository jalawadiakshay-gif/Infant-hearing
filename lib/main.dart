import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/parent/providers/parent_provider.dart';
import 'features/baby/providers/baby_provider.dart';
import 'features/questionnaire/providers/questionnaire_provider.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
  _configureSystemUi();
}

void _configureSystemUi() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ParentProvider>(create: (_) => ParentProvider()),
        ChangeNotifierProvider<BabyProvider>(create: (_) => BabyProvider()),
        ChangeNotifierProvider(create: (_) => QuestionnaireProvider()),
      ],
      child: const InfantHearingApp(),
    );
  }
}
