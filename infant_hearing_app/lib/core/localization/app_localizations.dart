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

  // ── Role Selection ────────────────────────────────────────────────────────
  String get chooseYourRole       => _t('chooseYourRole');
  String get selectRoleSubtitle   => _t('selectRoleSubtitle');
  String get roleParent           => _t('roleParent');
  String get roleParentDesc       => _t('roleParentDesc');
  String get roleAshaWorker       => _t('roleAshaWorker');
  String get roleAshaWorkerDesc   => _t('roleAshaWorkerDesc');

  // ── Phone Login ───────────────────────────────────────────────────────────
  String get loginToProceed       => _t('loginToProceed');
  String get enterVerificationCode => _t('enterVerificationCode');
  String get enterPhoneHint       => _t('enterPhoneHint');
  String get exactDigitsRequired  => _t('exactDigitsRequired');
  String get numbersOnly          => _t('numbersOnly');
  String get otpSentSuccess       => _t('otpSentSuccess');
  String get failedSendOtp        => _t('failedSendOtp');
  String get verificationCode     => _t('verificationCode');
  String get enterOtpHint         => _t('enterOtpHint');
  String get enterSixDigitOtp     => _t('enterSixDigitOtp');
  String get switchToAsha         => _t('switchToAsha');
  String get clinicalTool         => _t('clinicalTool');

  // ── Parent Profile ────────────────────────────────────────────────────────
  String get parentProfile        => _t('parentProfile');
  String get completeProfileGuardian => _t('completeProfileGuardian');
  String get basicInformation     => _t('basicInformation');
  String get hospitalEmergency    => _t('hospitalEmergency');
  String get emailOptional        => _t('emailOptional');
  String get relationshipToChild  => _t('relationshipToChild');
  String get fatherLabel          => _t('fatherLabel');
  String get emergencyContact     => _t('emergencyContact');
  String get preferredHospital    => _t('preferredHospital');
  String get addressLabel         => _t('addressLabel');
  String get detailedAddress      => _t('detailedAddress');
  String get city                 => _t('city');
  String get stateLabel           => _t('stateLabel');
  String get declarationText      => _t('declarationText');
  String get saveAndNext          => _t('saveAndNext');
  String get acceptDeclaration    => _t('acceptDeclaration');
  String get failedSaveProfile    => _t('failedSaveProfile');
  String get yourProfile          => _t('yourProfile');

  // ── Account / Profile Screen ──────────────────────────────────────────────
  String get accountSettings      => _t('accountSettings');
  String get childProfiles        => _t('childProfiles');
  String get addNew               => _t('addNew');
  String get noChildrenYet        => _t('noChildrenYet');
  String ageMonths(int months)    => _t('ageMonths').replaceAll('{months}', months.toString());
  String get appSettingsLabel     => _t('appSettingsLabel');
  String get languagePreference   => _t('languagePreference');
  String get changeAppLanguage    => _t('changeAppLanguage');
  String get manageAlerts         => _t('manageAlerts');
  String get privacySecurity      => _t('privacySecurity');
  String get manageData           => _t('manageData');
  String get signOutAccount       => _t('signOutAccount');
  String get noPhoneLinked        => _t('noPhoneLinked');
  String get noEmailLinked        => _t('noEmailLinked');

  // ── Home Screen ───────────────────────────────────────────────────────────
  String get screeningLabel       => _t('screeningLabel');
  String get startPhase1          => _t('startPhase1');
  String get historyLabel         => _t('historyLabel');
  String get pastRecordsShort     => _t('pastRecordsShort');
  String get aiAssistant          => _t('aiAssistant');
  String get chatSupport          => _t('chatSupport');
  String get insightsLabel        => _t('insightsLabel');
  String get resourcesLabel       => _t('resourcesLabel');
  String get latestInsights       => _t('latestInsights');
  String get screeningStatus      => _t('screeningStatus');
  String get phase1Complete       => _t('phase1Complete');
  String get completeQuestionnaire => _t('completeQuestionnaire');
  String get clinicalBadge        => _t('clinicalBadge');

  // ── Settings Screen ───────────────────────────────────────────────────────
  String get preferences          => _t('preferences');
  String get accountLabel         => _t('accountLabel');
  String get aboutLabel           => _t('aboutLabel');
  String get partnerLabel         => _t('partnerLabel');
  String get versionLabel         => _t('versionLabel');
  String get editProfile          => _t('editProfile');
  String get areYouSureLogout     => _t('areYouSureLogout');
  String get appLabel             => _t('appLabel');
  String get notifications        => _t('notifications');
  String get logout               => _t('logout');

  // ── History Screen ────────────────────────────────────────────────────────
  String get clinicalHistory      => _t('clinicalHistory');
  String get noRecordsFound       => _t('noRecordsFound');
  String get completedRecordsAppear => _t('completedRecordsAppear');
  String screenedOn(String date)  => _t('screenedOn').replaceAll('{date}', date);
  String get passLabel            => _t('passLabel');
  String get viewReport           => _t('viewReport');
  String get dateUnknown          => _t('dateUnknown');
  String get unknownLabel         => _t('unknownLabel');

  // ── Questionnaire / Screening Tab ─────────────────────────────────────────
  String get hearingScreening     => _t('hearingScreening');
  String get phase1Screening      => _t('phase1Screening');
  String get unansweredQuestions  => _t('unansweredQuestions');
  String get answerAllQuestions   => _t('answerAllQuestions');
  String get informationOnlySection => _t('informationOnlySection');
  String get phase1Questionnaire  => _t('phase1Questionnaire');
  String get phase1QuestionnaireDesc => _t('phase1QuestionnaireDesc');
  String get phase2Boa            => _t('phase2Boa');
  String get phase2BoaDesc        => _t('phase2BoaDesc');
  String get completedStatus      => _t('completedStatus');
  String get pendingStatus        => _t('pendingStatus');
  String get requiredStatus       => _t('requiredStatus');
  String get lockedStatus         => _t('lockedStatus');
  String get notRequiredStatus    => _t('notRequiredStatus');
  String get completePhase1First  => _t('completePhase1First');
  String get boaNotRequired       => _t('boaNotRequired');
  String get boaNotRequiredDesc   => _t('boaNotRequiredDesc');
  String get viewScreeningHistory => _t('viewScreeningHistory');
  String get startPhase2Boa       => _t('startPhase2Boa');
  String get viewPhase1Result     => _t('viewPhase1Result');
  String get startPhase1Questionnaire => _t('startPhase1Questionnaire');

  // ── BOA Wizard / Test Screen ──────────────────────────────────────────────
  String get boaClinicalWizard    => _t('boaClinicalWizard');
  String get clinicalPreparation  => _t('clinicalPreparation');
  String get ensureConditions     => _t('ensureConditions');
  String get quietEnvironment     => _t('quietEnvironment');
  String get ambientNoise         => _t('ambientNoise');
  String get infantStateLabel     => _t('infantStateLabel');
  String get alertButCalm         => _t('alertButCalm');
  String get deviceCalibration    => _t('deviceCalibration');
  String get volumeAt80           => _t('volumeAt80');
  String get distractionFree      => _t('distractionFree');
  String get noToysLights         => _t('noToysLights');
  String get infantPositioning    => _t('infantPositioning');
  String get positionInstructions => _t('positionInstructions');
  String get startClinicalTest    => _t('startClinicalTest');
  String get positionInfant       => _t('positionInfant');
  String get positionInfantDesc   => _t('positionInfantDesc');
  String get proceedWithoutDetection => _t('proceedWithoutDetection');
  String get eyeResponse          => _t('eyeResponse');
  String get headTurnLabel        => _t('headTurnLabel');
  String get startleReflex        => _t('startleReflex');
  String get movementLabel        => _t('movementLabel');
  String get aiVerified           => _t('aiVerified');
  String get catchTrialLabel      => _t('catchTrialLabel');
  String get moveWellLitArea      => _t('moveWellLitArea');
  String get initializingCamera   => _t('initializingCamera');
  String get playStimulus         => _t('playStimulus');
  String get preparingStimulus    => _t('preparingStimulus');
  String get waitLabel            => _t('waitLabel');
  String get observeLabel         => _t('observeLabel');
  String get positionInfantCamera => _t('positionInfantCamera');
  String get readyToBegin         => _t('readyToBegin');
  String get calibratingBehavior  => _t('calibratingBehavior');
  String get checkingNoise        => _t('checkingNoise');
  String get preparingStimulusKeepStill => _t('preparingStimulusKeepStill');
  String get soundPlayingObserve  => _t('soundPlayingObserve');
  String get didInfantRespond     => _t('didInfantRespond');
  String get testComplete         => _t('testComplete');
  String get flipCamera           => _t('flipCamera');
  String get restartTest          => _t('restartTest');

  String get phase1Desc           => _t('phase1Desc');
  String get phase2Desc           => _t('phase2Desc');
  String get statusCompleted      => _t('statusCompleted');
  String get statusPending        => _t('statusPending');
  String get statusRequired       => _t('statusRequired');
  String get statusNotRequired    => _t('statusNotRequired');
  String get statusLocked         => _t('statusLocked');
  String get startPhase2          => _t('startPhase2');
  String get startPhase1Desc      => _t('startPhase1Desc');

  // ── PDF Report Keys ─────────────────────────────────────────────────────
  String get pdfParentScreeningReport  => _t('pdfParentScreeningReport');
  String get pdfClinicalScreeningReport => _t('pdfClinicalScreeningReport');
  String get pdfHearingScreeningReport => _t('pdfHearingScreeningReport');
  String get pdfEarlyDetection         => _t('pdfEarlyDetection');
  String get pdfChildInformation       => _t('pdfChildInformation');
  String get pdfChildName              => _t('pdfChildName');
  String get pdfDateOfBirth            => _t('pdfDateOfBirth');
  String get pdfAgeLabel               => _t('pdfAgeLabel');
  String get pdfGenderLabel            => _t('pdfGenderLabel');
  String get pdfScreeningDate          => _t('pdfScreeningDate');
  String get pdfScreeningId            => _t('pdfScreeningId');
  String get pdfMonths                 => _t('pdfMonths');
  String get pdfMale                   => _t('pdfMale');
  String get pdfFemale                 => _t('pdfFemale');

  String get pdfScreeningResult        => _t('pdfScreeningResult');
  String get pdfOverallResult          => _t('pdfOverallResult');
  String get pdfScreeningPassed        => _t('pdfScreeningPassed');
  String get pdfMonitorFollowUp        => _t('pdfMonitorFollowUp');
  String get pdfFurtherEvaluation      => _t('pdfFurtherEvaluation');

  String get pdfRecommendation         => _t('pdfRecommendation');
  String get pdfPassRecommendation     => _t('pdfPassRecommendation');
  String get pdfMonitorRecommendation1 => _t('pdfMonitorRecommendation1');
  String get pdfMonitorRecommendation2 => _t('pdfMonitorRecommendation2');
  String get pdfReferRecommendation    => _t('pdfReferRecommendation');

  String get pdfScreeningTimeline      => _t('pdfScreeningTimeline');
  String get pdfPhase1Questionnaire    => _t('pdfPhase1Questionnaire');
  String get pdfPhase2Boa              => _t('pdfPhase2Boa');
  String get pdfFinalRecommendation    => _t('pdfFinalRecommendation');
  String get pdfTimelineCompleted      => _t('pdfTimelineCompleted');
  String get pdfTimelinePending        => _t('pdfTimelinePending');
  String get pdfTimelineNotStarted     => _t('pdfTimelineNotStarted');
  String get pdfTimelineInProgress     => _t('pdfTimelineInProgress');
  String get pdfTimelineNotRequired    => _t('pdfTimelineNotRequired');
  String get pdfTimelineRecommended    => _t('pdfTimelineRecommended');

  String get pdfFollowUpActions        => _t('pdfFollowUpActions');
  String get pdfContinueMonitoring     => _t('pdfContinueMonitoring');
  String get pdfRepeatScreening        => _t('pdfRepeatScreening');
  String get pdfRepeatScreening1Month  => _t('pdfRepeatScreening1Month');
  String get pdfScheduleAudiology      => _t('pdfScheduleAudiology');
  String get pdfVisitJNMC              => _t('pdfVisitJNMC');

  String get pdfImportantNotice        => _t('pdfImportantNotice');
  String get pdfDisclaimerText         => _t('pdfDisclaimerText');

  String get pdfCategoryBreakdown      => _t('pdfCategoryBreakdown');
  String get pdfDetailedResponses      => _t('pdfDetailedResponses');
  String get pdfScorePercent           => _t('pdfScorePercent');
  String get pdfRiskScoreLabel         => _t('pdfRiskScoreLabel');
  String get pdfPartialLabel           => _t('pdfPartialLabel');
  String get pdfClinicalSummary        => _t('pdfClinicalSummary');

  String get pdfGeneratedOn            => _t('pdfGeneratedOn');
  String get pdfVersion                => _t('pdfVersion');
  String get pdfScanDigitalReport      => _t('pdfScanDigitalReport');
  String get pdfSelectReportType       => _t('pdfSelectReportType');
  String get pdfParentReportDesc       => _t('pdfParentReportDesc');
  String get pdfClinicalReportDesc     => _t('pdfClinicalReportDesc');
  String get pdfRecommendedLabel       => _t('pdfRecommendedLabel');
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
