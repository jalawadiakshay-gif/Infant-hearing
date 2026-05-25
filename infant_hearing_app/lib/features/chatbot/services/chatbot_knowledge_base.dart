import 'package:infant_hearing_app/core/constants/app_language.dart';

/// Pure data class. No Flutter dependencies.
/// Maps intent keys → multilingual responses.
class ChatbotKnowledgeBase {
  ChatbotKnowledgeBase._();

  // ── Quick-action intents ─────────────────────────────────────────────────
  static const String intentMilestones        = 'hearing_milestones';
  static const String intentSymptoms          = 'check_symptoms';
  static const String intentBookScreening     = 'book_screening';
  static const String intentQuestionnaireHelp = 'questionnaire_help';
  static const String intentOae              = 'oae';
  static const String intentAbr              = 'abr';
  static const String intentReferResult      = 'refer_result';
  static const String intentPassResult       = 'pass_result';
  static const String intentHearingLoss      = 'hearing_loss';
  static const String intentWhenToSeeDoctor  = 'see_doctor';
  static const String intentGreeting         = 'greeting';

  // ── Response map: intent → language code → response text ────────────────
  static const Map<String, Map<String, String>> _responses = {
    intentGreeting: {
      'en': 'Hello! I am your Baalshravya assistant. I can help you with hearing milestones, screening steps, and understanding your results. How can I help today?',
      'hi': 'नमस्ते! मैं आपका बालश्रव्य सहायक हूँ। मैं श्रवण मील के पत्थर, जाँच चरणों और आपके परिणामों को समझने में मदद कर सकता हूँ।',
      'kn': 'ನಮಸ್ಕಾರ! ನಾನು ನಿಮ್ಮ ಬಾಲಶ್ರಾವ್ಯ ಸಹಾಯಕ.',
      'mr': 'नमस्कार! मी तुमचा बालश्रव्य सहाय्यक आहे. मी तुम्हाला श्रवण टप्पे, तपासणीचे टप्पे आणि तुमचे निकाल समजून घेण्यास मदत करू शकतो.',
    },
    intentMilestones: {
      'en': '''Infant hearing milestones:
• 0–3 months: Startles at loud sounds, calms to familiar voices.
• 3–6 months: Turns toward sounds, babbles.
• 6–9 months: Responds to name, imitates sounds.
• 9–12 months: Says simple words like "mama", "dada".

If your baby is not meeting these milestones, please use this app to complete a screening.''',

      'hi': '''शिशु श्रवण मील के पत्थर:
• 0–3 महीने: तेज आवाज से चौंकता है, परिचित आवाजों से शांत होता है।
• 3–6 महीने: आवाज की ओर मुड़ता है, बड़बड़ाता है।
• 6–9 महीने: अपने नाम पर प्रतिक्रिया देता है।
• 9–12 महीने: "माँ", "दादा" जैसे सरल शब्द कहता है।

यदि आपका शिशु इन मील के पत्थरों को पूरा नहीं कर रहा, तो कृपया स्क्रीनिंग करें।''',

      'kn': '''ಶಿಶು ಶ್ರವಣ ಮೈಲಿಗಲ್ಲುಗಳು:
• 0–3 ತಿಂಗಳು: ದೊಡ್ಡ ಶಬ್ದಕ್ಕೆ ಬೆಚ್ಚಿಬೀಳುತ್ತದೆ.
• 3–6 ತಿಂಗಳು: ಶಬ್ದದ ಕಡೆ ತಿರುಗುತ್ತದೆ.
• 6–9 ತಿಂಗಳು: ತನ್ನ ಹೆಸರಿಗೆ ಪ್ರತಿಕ್ರಿಯಿಸುತ್ತದೆ.
• 9–12 ತಿಂಗಳು: "ಅಮ್ಮ", "ಅಪ್ಪ" ಎಂದು ಹೇಳುತ್ತದೆ.

ನಿಮ್ಮ ಶಿಶು ಈ ಮೈಲಿಗಲ್ಲುಗಳನ್ನು ತಲುಪದಿದ್ದರೆ, ದಯವಿಟ್ಟು ಸ್ಕ್ರೀನಿಂಗ್ ಮಾಡಿ.''',

      'mr': '''शिशू श्रवण टप्पे:
• ०–३ महिने: मोठ्या आवाजाला बाळ दचकते, ओळखीच्या आवाजाला शांत होते.
• ३–६ महिने: आवाजाच्या दिशेला मान वळवते, आवाज काढते.
• ६–९ महिने: नावावर प्रतिसाद देते.
• ९–१२ महिने: "आई", "बाबा" असे सोपे शब्द म्हणते.

जर तुमचे बाळ हे टप्पे पूर्ण करत नसेल, तर कृपया या ॲपद्वारे तपासणी करा.''',
    },

    intentSymptoms: {
      'en': '''Warning signs of hearing loss in infants:
• Does not startle at loud sounds after 1 month.
• Does not turn toward voices after 3 months.
• Does not respond to their name by 9 months.
• No babbling by 12 months.
• Shows no speech development by 12–15 months.

If you notice any of these signs, please complete the screening questionnaire immediately.''',

      'hi': '''शिशुओं में सुनने की समस्या के चेतावनी संकेत:
• 1 महीने के बाद तेज आवाज से नहीं चौंकता।
• 3 महीने के बाद आवाज की ओर नहीं मुड़ता।
• 9 महीने तक अपने नाम पर प्रतिक्रिया नहीं देता।
• 12 महीने तक बड़बड़ाना नहीं।
• 12–15 महीने तक कोई भाषण विकास नहीं।

यदि आप इनमें से कोई भी संकेत देखते हैं, तो कृपया तुरंत स्क्रीनिंग प्रश्नावली पूरी करें।''',

      'kn': '''ಶಿಶುಗಳಲ್ಲಿ ಶ್ರವಣ ನಷ್ಟದ ಎಚ್ಚರಿಕೆ ಚಿಹ್ನೆಗಳು:
• 1 ತಿಂಗಳ ನಂತರ ದೊಡ್ಡ ಶಬ್ದಕ್ಕೆ ಬೆಚ್ಚಿಬೀಳದಿರುವುದು.
• 3 ತಿಂಗಳ ನಂತರ ಧ್ವನಿಯ ಕಡೆ ತಿರುಗದಿರುವುದು.
• 9 ತಿಂಗಳ ವೇಳೆಗೆ ಹೆಸರಿಗೆ ಪ್ರತಿಕ್ರಿಯಿಸದಿರುವುದು.
• 12 ತಿಂಗಳ ವೇಳೆಗೆ ಮಾತನ್ನಾಡದಿರುವುದು.

ನೀವು ಈ ಯಾವುದೇ ಚಿಹ್ನೆ ಗಮನಿಸಿದರೆ, ದಯವಿಟ್ಟು ತಕ್ಷಣ ಸ್ಕ್ರೀನಿಂಗ್ ಮಾಡಿ.''',

      'mr': '''शिशूंमध्ये श्रवणदोष दर्शवणारी चिन्हे:
• १ महिन्यानंतर मोठ्या आवाजाला न दचकणे.
• ३ महिन्यांनंतर आवाजाच्या दिशेला न वळणे.
• ९ महिन्यांपर्यंत नावावर प्रतिसाद न देणे.
• १२ महिन्यांपर्यंत आवाज (babbling) न काढणे.

जर तुम्हाला यांपैकी कोणतीही चिन्हे दिसली, तर कृपया त्वरित तपासणी करा.''',
    },

    intentBookScreening: {
      'en': 'To book a hearing screening at JNMC:\n\n1. Visit the JNMC Audiology / ENT Department.\n2. Register at the OPD counter.\n3. Mention you are here for the Baalshravya infant hearing screening.\n\nYou can also start the digital screening right now by tapping "Start Screening" on the Home screen.',
      'hi': 'JNMC में श्रवण जाँच बुक करने के लिए:\n\n1. JNMC ऑडियोलॉजी/ENT विभाग में जाएं।\n2. OPD काउंटर पर पंजीकरण करें।\n3. बताएं कि आप बालश्रव्य शिशु श्रवण जाँच के लिए आए हैं।\n\nआप होम स्क्रीन पर "जाँच शुरू करें" टैप करके अभी डिजिटल जाँच भी शुरू कर सकते हैं।',
      'kn': 'JNMC ನಲ್ಲಿ ಶ್ರವಣ ಸ್ಕ್ರೀನಿಂಗ್ ಬುಕ್ ಮಾಡಲು:\n\n1. JNMC ಆಡಿಯಾಲಜಿ / ENT ವಿಭಾಗಕ್ಕೆ ಭೇಟಿ ನೀಡಿ.\n2. OPD ಕೌಂಟರ್‌ನಲ್ಲಿ ನೋಂದಾಯಿಸಿ.\n3. ಬಾಲಶ್ರಾವ್ಯ ಶಿಶು ಶ್ರವಣ ಸ್ಕ್ರೀನಿಂಗ್‌ಗಾಗಿ ಬಂದಿರುವುದಾಗಿ ತಿಳಿಸಿ.',
      'mr': 'JNMC मध्ये श्रवण तपासणी बुक करण्यासाठी:\n\n१. JNMC ऑडिओलॉजी / ENT विभागाला भेट द्या.\n२. OPD काउंटरवर नोंदणी करा.\n३. बालश्रव्य शिशु श्रवण तपासणीसाठी आल्याचे सांगा.',
    },

    intentQuestionnaireHelp: {
      'en': 'The questionnaire has 7 sections:\n\n• Section 0: Basic information about your baby.\n• Section 1: Medical risk factors (NICU, medications, infections).\n• Section 2: How your baby responds to sounds.\n• Section 3: Advanced hearing behaviour indicators.\n• Section 4: Your concerns as a parent.\n• Section 5: Previous hearing screening history.\n• Section 6: The app will compute the risk score.\n\nAnswer all questions honestly. The results are for screening only and should be confirmed by a doctor.',
      'hi': 'प्रश्नावली में 7 खंड हैं:\n\n• खंड 0: आपके शिशु के बारे में बुनियादी जानकारी।\n• खंड 1: चिकित्सा जोखिम कारक।\n• खंड 2: आपका शिशु आवाजों पर कैसे प्रतिक्रिया देता है।\n• खंड 3: उन्नत श्रवण व्यवहार संकेतक।\n• खंड 4: माता-पिता के रूप में आपकी चिंताएं।\n• खंड 5: पिछली श्रवण जाँच का इतिहास।\n• खंड 6: ऐप जोखिम स्कोर की गणना करेगा।\n\nसभी प्रश्नों का ईमानदारी से उत्तर दें।',
      'kn': 'ಪ್ರಶ್ನಾವಳಿಯಲ್ಲಿ 7 ವಿಭಾಗಗಳಿವೆ:\n\n• ವಿಭಾಗ 0: ನಿಮ್ಮ ಶಿಶುವಿನ ಬಗ್ಗೆ ಮೂಲ ಮಾಹಿತಿ.\n• ವಿಭಾಗ 1: ವೈದ್ಯಕೀಯ ಅಪಾಯ ಅಂಶಗಳು.\n• ವಿಭಾಗ 2: ಶಿಶು ಶಬ್ದಗಳಿಗೆ ಹೇಗೆ ಪ್ರತಿಕ್ರಿಯಿಸುತ್ತದೆ.\n• ವಿಭಾಗ 3: ಸುಧಾರಿತ ಶ್ರವಣ ನಡವಳಿಕೆ ಸೂಚಕಗಳು.\n• ವಿಭಾಗ 4: ಪೋಷಕರಾಗಿ ನಿಮ್ಮ ಕಾಳಜಿಗಳು.\n• ವಿಭಾಗ 5: ಹಿಂದಿನ ಶ್ರವಣ ಸ್ಕ್ರೀನಿಂಗ್ ಇತಿಹಾಸ.\n• ವಿಭಾಗ 6: ಅಪ್ಲಿಕೇಶನ್ ಅಪಾಯ ಸ್ಕೋರ್ ಲೆಕ್ಕ ಹಾಕುತ್ತದೆ.',
      'mr': 'प्रश्नावलीमध्ये ७ विभाग आहेत:\n\n• विभाग ०: तुमच्या बाळाबद्दल मूलभूत माहिती.\n• विभाग १: वैद्यकीय जोखीम घटक.\n• विभाग २: बाळ आवाजाला कसा प्रतिसाद देते.\n• विभाग ३: प्रगत श्रवण वर्तन संकेतक.\n• विभाग ४: पालकांच्या चिंता.\n• विभाग ५: मागील श्रवण तपासणी इतिहास.\n• विभाग ६: ॲप जोखीम गुणांची गणना करेल.',
    },

    intentOae: {
      'en': 'OAE (Otoacoustic Emissions) is a painless, quick test that checks if your baby\'s inner ear (cochlea) is working properly. A small probe is placed in the ear and plays soft sounds. It is safe for newborns and takes less than 5 minutes.',
      'hi': 'OAE (ओटोअकॉस्टिक एमिशन) एक दर्दरहित, त्वरित परीक्षण है जो जाँचता है कि आपके शिशु का आंतरिक कान सही ढंग से काम कर रहा है या नहीं। यह नवजात शिशुओं के लिए सुरक्षित है और 5 मिनट से कम समय लेता है।',
      'kn': 'OAE ಪರೀಕ್ಷೆ ನೋವುರಹಿತ ಮತ್ತು ತ್ವರಿತವಾಗಿದ್ದು ನಿಮ್ಮ ಶಿಶುವಿನ ಒಳಗಿನ ಕಿವಿ ಸರಿಯಾಗಿ ಕಾರ್ಯ ನಿರ್ವಹಿಸುತ್ತಿದೆಯೇ ಎಂದು ಪರಿಶೀಲಿಸುತ್ತದೆ. ಇದು ನವಜಾತ ಶಿಶುಗಳಿಗೆ ಸುರಕ್ಷಿತ.',
      'mr': 'OAE ही एक वेदनारहित आणि जलद चाचणी आहे जी तुमच्या बाळाचा आतील कान नीट काम करत आहे की नाही हे तपासते. ही नवजात बाळांसाठी सुरक्षित आहे.',
    },

    intentReferResult: {
      'en': 'A REFER result means your baby\'s responses suggest a possible hearing concern. This does NOT confirm hearing loss — it means a follow-up test is needed.\n\nPlease visit JNMC Audiology for a formal OAE or ABR test as soon as possible. Early detection leads to much better outcomes.',
      'hi': 'REFER परिणाम का मतलब है कि आपके शिशु की प्रतिक्रियाएं संभावित श्रवण समस्या का सुझाव देती हैं। यह श्रवण हानि की पुष्टि नहीं करता — इसका मतलब है कि अनुवर्ती परीक्षण आवश्यक है।\n\nकृपया जल्द से जल्द JNMC ऑडियोलॉजी जाएं।',
      'kn': 'REFER ಫಲಿತಾಂಶ ಎಂದರೆ ನಿಮ್ಮ ಶಿಶುವಿನ ಪ್ರತಿಕ್ರಿಯೆಗಳು ಸಂಭಾವ್ಯ ಶ್ರವಣ ಸಮಸ್ಯೆಯನ್ನು ಸೂಚಿಸುತ್ತವೆ. ದಯವಿಟ್ಟು JNMC ಆಡಿಯಾಲಜಿಗೆ ಭೇಟಿ ನೀಡಿ.',
      'mr': 'REFER निकालाचा अर्थ असा आहे की तुमच्या बाळाच्या प्रतिसादांवरून श्रवणदोषाची शक्यता आहे. हे कायमस्वरूपी बहिरेपणा सिद्ध करत नाही — याचा अर्थ पुढील तपासणी आवश्यक आहे.',
    },

    intentPassResult: {
      'en': 'A PASS result means no significant hearing risk factors were identified at this time. Continue monitoring your baby\'s hearing development and complete the next screening in 3 months.',
      'hi': 'PASS परिणाम का मतलब है कि इस समय कोई महत्वपूर्ण श्रवण जोखिम कारक नहीं पाए गए। 3 महीने में अगली जाँच पूरी करें।',
      'kn': 'PASS ಫಲಿತಾಂಶ ಎಂದರೆ ಈ ಸಮಯದಲ್ಲಿ ಯಾವುದೇ ಮಹತ್ವದ ಶ್ರವಣ ಅಪಾಯ ಅಂಶಗಳು ಕಂಡುಬಂದಿಲ್ಲ. 3 ತಿಂಗಳ ನಂತರ ಮುಂದಿನ ಸ್ಕ್ರೀನಿಂಗ್ ಮಾಡಿ.',
      'mr': 'PASS निकालाचा अर्थ असा आहे की सध्या कोणतेही गंभीर धोके आढळलेले नाहीत. बाळाच्या श्रवण विकासावर लक्ष ठेवा आणि ३ महिन्यांनी पुन्हा तपासणी करा.',
    },

    intentHearingLoss: {
      'en': 'Hearing loss in infants can be:\n• Sensorineural (inner ear damage) — often permanent.\n• Conductive (outer/middle ear issue) — often treatable.\n• Mixed — a combination of both.\n\nEarly identification before 6 months of age and intervention by 6 months leads to significantly better speech and language outcomes.',
      'hi': 'शिशुओं में सुनने की समस्या हो सकती है:\n• सेंसोरिन्यूरल (आंतरिक कान की क्षति) — अक्सर स्थायी।\n• कंडक्टिव (बाहरी/मध्य कान की समस्या) — अक्सर उपचार योग्य।\n\n6 महीने की उम्र से पहले पहचान और हस्तक्षेप से भाषण और भाषा के परिणामों में काफी सुधार होता है।',
      'kn': 'ಶಿಶುಗಳಲ್ಲಿ ಶ್ರವಣ ನಷ್ಟ ಹೀಗಿರಬಹುದು:\n• ಸೆನ್ಸೋರಿನ್ಯೂರಲ್ (ಒಳ ಕಿವಿ ಹಾನಿ) — ಸಾಮಾನ್ಯವಾಗಿ ಶಾಶ್ವತ.\n• ಕಂಡಕ್ಟಿವ್ (ಹೊರ/ಮಧ್ಯ ಕಿವಿ ಸಮಸ್ಯೆ) — ಸಾಮಾನ್ಯವಾಗಿ ಚಿಕಿತ್ಸೆ ಮಾಡಬಹುದು.',
      'mr': 'शिशूंमधील श्रवणदोष खालीलप्रमाणे असू शकतात:\n• सेन्सोरीन्यूरल (आतील कानाची इजा) - अनेकदा कायमस्वरूपी.\n• कंडक्टिव्ह (बाहेरील/मध्य कानाची समस्या) - अनेकदा उपचार करण्यायोग्य.',
    },

    intentWhenToSeeDoctor: {
      'en': 'Please consult a doctor immediately if:\n• Your baby does not respond to sound at any age.\n• Your baby passed a newborn screen but you notice hearing concerns later.\n• Your baby has had meningitis, severe jaundice, or ototoxic drugs.\n• The app result is REFER.\n\nDo not wait. Early intervention makes a life-changing difference.',
      'hi': 'यदि निम्नलिखित हो तो तुरंत डॉक्टर से मिलें:\n• आपका शिशु किसी भी उम्र में आवाज पर प्रतिक्रिया नहीं देता।\n• ऐप परिणाम REFER है।\n• शिशु को मेनिन्जाइटिस, गंभीर पीलिया या ओटोटॉक्सिक दवाएं मिली हों।',
      'kn': 'ತಕ್ಷಣ ವೈದ್ಯರನ್ನು ಸಂಪರ್ಕಿಸಿ:\n• ನಿಮ್ಮ ಶಿಶು ಯಾವ ವಯಸ್ಸಿನಲ್ಲೂ ಶಬ್ದಕ್ಕೆ ಪ್ರತಿಕ್ರಿಯಿಸದಿದ್ದರೆ.\n• ಅಪ್ಲಿಕೇಶನ್ ಫಲಿತಾಂಶ REFER ಆಗಿದ್ದರೆ.',
      'mr': 'खालील परिस्थितीत त्वरित डॉक्टरांचा सल्ला घ्या:\n• तुमचे बाळ कोणत्याही वयात आवाजाला प्रतिसाद देत नसेल.\n• ॲपचा निकाल "REFER" आला असेल.',
    },
  };

  // ── Keyword → intent matching ────────────────────────────────────────────
  static const Map<String, List<String>> _keywords = {
    intentMilestones:        ['milestone', 'milestones', 'development', 'age', 'month', 'मील', 'विकास', 'महिने', 'टप्पे', 'ಮೈಲಿ', 'टप्पे'],
    intentSymptoms:          ['symptom', 'symptoms', 'sign', 'signs', 'warning', 'लक्षण', 'संकेत', 'चिन्हे', 'ಲಕ್ಷಣ', 'लक्षणे'],
    intentBookScreening:     ['book', 'appointment', 'schedule', 'visit', 'jnmc', 'बुक', 'अपॉइंटमेंट', 'नोंदणी', 'तपासणी', 'ಬುಕ್'],
    intentQuestionnaireHelp: ['questionnaire', 'question', 'section', 'form', 'प्रश्नावली', 'विभाग', 'प्रश्न', 'ಪ್ರಶ್ನೆ'],
    intentOae:               ['oae', 'otoacoustic', 'emissions', 'test', 'ओएई', 'ಒಎಇ'],
    intentReferResult:       ['refer', 'referred', 'रेफर', 'ರೆಫರ್'],
    intentPassResult:        ['pass', 'passed', 'यशस्वी', 'ಉತ್ತೀರ್ಣ'],
    intentHearingLoss:       ['hearing loss', 'deaf', 'deafness', 'बहिरेपणा', 'सुनने', 'ಶ್ರವಣ ನಷ್ಟ'],
    intentWhenToSeeDoctor:   ['doctor', 'consult', 'डॉक्टर', 'सल्ला', 'ವೈದ್ಯ'],
    intentGreeting:          ['hello', 'hi', 'hey', 'good morning', 'नमस्ते', 'नमस्कार', 'ನಮಸ್ಕಾರ'],
  };

  // ── Offline generic fallback ─────────────────────────────────────────────
  static const Map<String, String> _offlineFallback = {
    'en': 'I\'m sorry, I couldn\'t find an answer to that. For specific medical advice, please visit the JNMC Audiology department.',
    'hi': 'मुझे खेद है, मुझे इसका उत्तर नहीं मिला। विशिष्ट चिकित्सा सलाह के लिए, कृपया JNMC ऑडियोलॉजी विभाग में जाएं।',
    'kn': 'ಕ್ಷಮಿಸಿ, ನನಗೆ ಆ ಪ್ರಶ್ನೆಗೆ ಉತ್ತರ ಸಿಗಲಿಲ್ಲ. ನಿರ್ದಿಷ್ಟ ವೈದ್ಯಕೀಯ ಸಲಹೆಗಾಗಿ JNMC ಆಡಿಯಾಲಜಿ ವಿಭಾಗಕ್ಕೆ ಭೇಟಿ ನೀಡಿ.',
    'mr': 'क्षमस्व, मला याचे उत्तर सापडले नाही. विशिष्ट वैद्यकीय सल्ल्यासाठी, कृपया JNMC ऑडिओलॉजी विभागाला भेट द्या.',
  };

  // ── Public API ───────────────────────────────────────────────────────────

  /// Looks up a response by intent ID + language.
  static String responseForIntent(String intent, AppLanguage lang) {
    final langMap = _responses[intent];
    if (langMap == null) return fallback(lang);
    return langMap[lang.code] ?? langMap['en'] ?? fallback(lang);
  }

  /// Detects the best intent from free-text user input.
  /// Returns null if no intent matches.
  static String? detectIntent(String userInput) {
    final lower = userInput.trim().toLowerCase();
    if (lower.isEmpty) return null;
    
    for (final entry in _keywords.entries) {
      for (final kw in entry.value) {
        if (lower.contains(kw.toLowerCase())) return entry.key;
      }
    }
    return null;
  }

  static String fallback(AppLanguage lang) =>
      _offlineFallback[lang.code] ?? _offlineFallback['en']!;
}