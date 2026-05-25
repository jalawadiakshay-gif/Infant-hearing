import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _strings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _Delegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('mr'),
  ];

  Future<bool> load() async {
    final raw = await rootBundle.loadString(
      'lib/core/localization/l10n/app_${locale.languageCode}.arb',
    );
    final map = json.decode(raw) as Map<String, dynamic>;
    _strings = map.map((k, v) => MapEntry(k, v.toString()))
      ..removeWhere((k, _) => k.startsWith('@'));
    return true;
  }

  String _t(String key) => _strings[key] ?? key;

  // ── App-wide ─────────────────────────────────────────────────────────────
  String get appName          => _t('appName');
  String get selectLanguage   => _t('selectLanguage');
  String get continueButton   => _t('continueButton');
  String get changeLanguage   => _t('changeLanguage');
  String get settings         => _t('settings');
  String get save             => _t('save');
  String get cancel           => _t('cancel');
  String get next             => _t('next');
  String get back             => _t('back');
  String get submit           => _t('submit');
  String get yes              => _t('yes');
  String get no               => _t('no');
  String get loading          => _t('loading');
  String get error            => _t('error');
  String get retry            => _t('retry');
  String get ok               => _t('ok');
  String get done             => _t('done');
  String get or               => _t('or');
  String get ofWord            => _t('of');
  String get continueWithGoogle => _t('continueWithGoogle');

  // ── Welcome / Onboarding ─────────────────────────────────────────────────
  String get welcomeTitle       => _t('welcomeTitle');
  String get welcomeSubtitle    => _t('welcomeSubtitle');
  String get welcomeDescription => _t('welcomeDescription');

  // ── Home ─────────────────────────────────────────────────────────────────
  String get homeTitle      => _t('homeTitle');
  String get homeGreeting   => _t('homeGreeting');
  String get goodMorning    => _t('goodMorning');
  String get goodAfternoon  => _t('goodAfternoon');
  String get goodEvening    => _t('goodEvening');
  String get startScreening => _t('startScreening');
  String get viewHistory    => _t('viewHistory');
  String get awareness      => _t('awareness');
  String get chatWithUs     => _t('chatWithUs');
  String get quickActions   => _t('quickActions');
  String get checkBabyHearing => _t('checkBabyHearing');
  String get pastRecords      => _t('pastRecords');
  String get askAIAssistant   => _t('askAIAssistant');
  String get learnAboutHearing => _t('learnAboutHearing');
  String get tapToAddProfile   => _t('tapToAddProfile');
  String get earlyDetectionMatters => _t('earlyDetectionMatters');
  String get earlyDetectionDesc    => _t('earlyDetectionDesc');
  String get knowTheSigns          => _t('knowTheSigns');
  String get knowTheSignsDesc       => _t('knowTheSignsDesc');

  // ── Registration ─────────────────────────────────────────────────────────
  String get registerInfant    => _t('registerInfant');
  String get infantName        => _t('infantName');
  String get dateOfBirth       => _t('dateOfBirth');
  String get birthWeight       => _t('birthWeight');
  String get gestationalAge    => _t('gestationalAge');
  String get nicuAdmission     => _t('nicuAdmission');
  String get deliveryMode      => _t('deliveryMode');
  String get normalDelivery    => _t('normalDelivery');
  String get cesareanDelivery  => _t('cesareanDelivery');

  String get parentInfo       => _t('parentInfo');
  String get parentName       => _t('parentName');
  String get parentPhone      => _t('parentPhone');
  String get parentRelation   => _t('parentRelation');
  String get mother           => _t('mother');
  String get father           => _t('father');
  String get guardian         => _t('guardian');

  // ── Authentication & More ────────────────────────────────────────────────
  String get email            => _t('email');
  String get fieldRequired    => _t('fieldRequired');
  String get invalidPhone     => _t('invalidPhone');
  String get sectionComplete  => _t('sectionComplete');
  String get sectionLabel     => _t('sectionLabel');

  // ── Questionnaire ────────────────────────────────────────────────────────
  String get questionnaire          => _t('questionnaire');
  String get questionnaireSection0  => _t('questionnaireSection0');
  String get questionnaireSection1  => _t('questionnaireSection1');
  String get questionnaireSection2  => _t('questionnaireSection2');
  String get questionnaireSection3  => _t('questionnaireSection3');
  String get questionnaireSection4  => _t('questionnaireSection4');
  String get questionnaireSection5  => _t('questionnaireSection5');
  String get questionnaireSection6  => _t('questionnaireSection6');

  // ── Risk / Outcome ───────────────────────────────────────────────────────
  String get riskScoreLow    => _t('riskScoreLow');
  String get riskScoreMedium => _t('riskScoreMedium');
  String get riskScoreHigh   => _t('riskScoreHigh');
  String get outcomePass     => _t('outcomePass');
  String get outcomeMonitor  => _t('outcomeMonitor');
  String get outcomeRefer    => _t('outcomeRefer');

  // ── BOA ──────────────────────────────────────────────────────────────────
  String get boaTest         => _t('boaTest');
  String get boaPreChecklist => _t('boaPreChecklist');
  String get boaStartTest    => _t('boaStartTest');
  String get boaResponse     => _t('boaResponse');
  String get boaNoResponse   => _t('boaNoResponse');
  String get boaUncertain    => _t('boaUncertain');
  String get boaPlaying      => _t('boaPlaying');
  String get boaFavorableResponse => _t('boaFavorableResponse');
  String get boaMonitorResponse   => _t('boaMonitorResponse');
  String get boaSuspectedLoss      => _t('boaSuspectedLoss');
  String get aiEyeBlink           => _t('aiEyeBlink');
  String get aiHeadTurn            => _t('aiHeadTurn');
  String get aiPositionBaby       => _t('aiPositionBaby');
  String get boaNarrationIntro    => _t('boaNarrationIntro');
  String get boaNarrationPlaying  => _t('boaNarrationPlaying');
  String get boaNarrationResponse => _t('boaNarrationResponse');
  String get boaNarrationNoInfant => _t('boaNarrationNoInfant');
  String get boaCatchTrial        => _t('boaCatchTrial');

  String get preCheckQuiet         => _t('preCheckQuiet');
  String get preCheckInfantAlert   => _t('preCheckInfantAlert');
  String get preCheckNoDistraction => _t('preCheckNoDistraction');
  String get preCheckDeviceVolume  => _t('preCheckDeviceVolume');
  String get preCheckCaregiverFreeze => _t('preCheckCaregiverFreeze');
  String get preCheckCatchTrial      => _t('preCheckCatchTrial');

  // ── Chatbot ──────────────────────────────────────────────────────────────
  String get chatbot             => _t('chatbot');
  String get chatbotPlaceholder  => _t('chatbotPlaceholder');
  String get chatbotListening    => _t('chatbotListening');
  String get chatbotSpeaking     => _t('chatbotSpeaking');
  String get chatbotNarrating    => _t('chatbotNarrating');
  String get chatbotReady        => _t('chatbotReady');
  String get chatbotTapToSpeak   => _t('chatbotTapToSpeak');
  String get chatbotSend         => _t('chatbotSend');
  String get chatbotErrorMessage => _t('chatbotErrorMessage');
  String get chatbotWelcome      => _t('chatbotWelcome');
  String get chatbotWelcomeSub   => _t('chatbotWelcomeSub');
  String get chatbotClearConfirm => _t('chatbotClearConfirm');

  // ── Chatbot quick-action labels ───────────────────────────────────────────
  String get qaHearingMilestones => _t('qaHearingMilestones');
  String get qaCheckSymptoms     => _t('qaCheckSymptoms');
  String get qaBookScreening     => _t('qaBookScreening');
  String get qaQuestionnaireHelp => _t('qaQuestionnaireHelp');

  // ── Report / Follow-up ───────────────────────────────────────────────────
  String get report          => _t('report');
  String get generateReport  => _t('generateReport');
  String get downloadReport  => _t('downloadReport');
  String get shareReport     => _t('shareReport');
  String get followUp        => _t('followUp');
  String get nextScreening   => _t('nextScreening');
  String get setReminder     => _t('setReminder');

  String get screeningResult    => _t('screeningResult');
  String get riskScore          => _t('riskScore');
  String get scoreBreakdown     => _t('scoreBreakdown');
  String get riskScale          => _t('riskScale');
  String get proceedToBoa       => _t('proceedToBoa');
  String get boaRequiredTitle   => _t('boaRequiredTitle');
  String get boaRequiredDesc    => _t('boaRequiredDesc');
  String get recommendedAction => _t('recommendedAction');
  String get referralNote       => _t('referralNote');
  String get monitorNote        => _t('monitorNote');
  String get passNote           => _t('passNote');

  // ── Voice / TTS ──────────────────────────────────────────────────────────
  String get ttsNotAvailable     => _t('ttsNotAvailable');
  String get sttNotAvailable     => _t('sttNotAvailable');
  String get microphonePermission => _t('microphonePermission');
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'kn', 'mr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final l = AppLocalizations(locale);
    await l.load();
    return l;
  }

  @override
  bool shouldReload(_Delegate old) => false;
}
