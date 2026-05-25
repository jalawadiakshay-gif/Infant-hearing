// ─────────────────────────────────────────────────────────────────────────────
// features/questionnaire/models/questionnaire_data.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'questionnaire_models.dart';

class QuestionnaireData {
  static List<QuestionnaireSection> getSections({int babyAgeMonths = 0}) {
    return [
      _section0(),
      _section1(),
      _section2(babyAgeMonths),
      _section3(),
      _section4(),
      _section5(),
    ];
  }

  // ── Section 0: Basic Infant Info (unscored) ─────────────────────────────────
  static QuestionnaireSection _section0() => const QuestionnaireSection(
        index: 0,
        title: {
          'en': 'Basic Information',
          'hi': 'मूलभूत जानकारी',
          'kn': 'ಮೂಲ ಮಾಹಿತಿ',
          'mr': 'मूलभूत माहिती',
        },
        subtitle: {
          'en': 'Confirm your baby\'s key details before we begin.',
          'hi': 'शुरू करने से पहले अपने बच्चे के मुख्य विवरणों की पुष्टि करें।',
          'kn': 'ಪ್ರಾರಂಭಿಸುವ ಮೊದಲು ನಿಮ್ಮ ಮಗುವಿನ ಪ್ರಮುಖ ವಿವರಗಳನ್ನು ಖಚಿತಪಡಿಸಿ.',
          'mr': 'सुरू करण्यापूर्वी तुमच्या बाळाच्या महत्त्वाच्या तपशीलांची पुष्टी करा.',
        },
        questions: [
          Question(
            id: 's0_q1',
            scored: false,
            text: {
              'en': 'Was the baby born at term (≥37 weeks gestational age)?',
              'hi': 'क्या बच्चा समय पर (≥37 सप्ताह) जन्मा था?',
              'kn': 'ಮಗು ಸಮಯಕ್ಕೆ (≥37 ವಾರ) ಜನಿಸಿದೆಯೇ?',
              'mr': 'बाळाचा जन्म वेळेवर (≥३७ आठवडे गर्भधारणेचे वय) झाला होता का?',
            },
          ),
          Question(
            id: 's0_q2',
            scored: false,
            text: {
              'en': 'Did the baby have a normal birth weight (≥2.5 kg)?',
              'hi': 'क्या बच्चे का जन्म वजन सामान्य (≥2.5 kg) था?',
              'kn': 'ಮಗುವಿನ ಜನ್ಮ ತೂಕ ಸಾಮಾನ್ಯ (≥2.5 kg) ಇತ್ತೇ?',
              'mr': 'जन्माच्या वेळी बाळाचे वजन सामान्य (≥२.५ किलो) होते का?',
            },
          ),
          Question(
            id: 's0_q3',
            scored: false,
            text: {
              'en': 'Was the delivery without major complications?',
              'hi': 'क्या प्रसव बिना किसी बड़ी जटिलता के हुआ?',
              'kn': 'ಹೆರಿಗೆ ದೊಡ್ಡ ತೊಂದರೆಗಳಿಲ್ಲದೆ ಆಯಿತೇ?',
              'mr': 'प्रसूती कोणत्याही मोठ्या गुंतागुंतीशिवाय झाली का?',
            },
          ),
        ],
      );

  // ── Section 1: High-Risk Medical Factors ────────────────────────────────────
  static QuestionnaireSection _section1() => const QuestionnaireSection(
        index: 1,
        title: {
          'en': 'High-Risk Medical Factors',
          'hi': 'उच्च-जोखिम वाले चिकित्सा कारक',
          'kn': 'ಹೆಚ್ಚಿನ ಅಪಾಯದ ವೈದ್ಯಕೀಯ ಅಂಶಗಳು',
          'mr': 'उच्च-धोक्याचे वैद्यकीय घटक',
        },
        subtitle: {
          'en': 'These clinical factors are linked to a higher risk of hearing loss.',
          'hi': 'ये नैदानिक ​​कारक सुनने की शक्ति कम होने के उच्च जोखिम से जुड़े हैं।',
          'kn': 'ಈ ವೈದ್ಯಕೀಯ ಅಂಶಗಳು ಶ್ರವಣ ನಷ್ಟದ ಹೆಚ್ಚಿನ ಅಪಾಯಕ್ಕೆ ಸಂಬಂಧಿಸಿವೆ.',
          'mr': 'हे क्लिनिकल घटक श्रवणदोषाच्या उच्च जोखमीशी संबंधित आहेत.',
        },
        questions: [
          Question(
            id: 's1_q1',
            text: {
              'en': 'Does the family have a history of childhood hearing loss?',
              'hi': 'क्या परिवार में बचपन की सुनने की समस्या का इतिहास है?',
              'kn': 'ಕುಟುಂಬದಲ್ಲಿ ಬಾಲ್ಯದ ಶ್ರವಣ ನಷ್ಟದ ಇತಿಹಾಸ ಇದೆಯೇ?',
              'mr': 'कुटुंबात बालपणातील श्रवणदोषाचा इतिहास आहे का?',
            },
          ),
          Question(
            id: 's1_q2',
            text: {
              'en': 'Was the baby admitted to the NICU for more than 5 days?',
              'hi': 'क्या बच्चे को 5 दिन से अधिक NICU में भर्ती किया गया था?',
              'kn': 'ಮಗುವನ್ನು 5 ದಿನಗಳಿಗಿಂತ ಹೆಚ್ಚು NICU ನಲ್ಲಿ ದಾಖಲಿಸಲಾಗಿತ್ತೇ?',
              'mr': 'बाळाला ५ दिवसांपेक्षा जास्त काळ NICU मध्ये दाखल केले होते का?',
            },
          ),
          Question(
            id: 's1_q3',
            text: {
              'en': 'Was the baby exposed to ototoxic medications (e.g., gentamicin, furosemide)?',
              'hi': 'क्या बच्चे को कर्णविषाक्त दवाएं (जैसे जेंटामाइसिन) दी गई थीं?',
              'kn': 'ಮಗುವಿಗೆ ಕಿವಿಗೆ ಹಾನಿಕರ ಔಷಧಗಳು (ಉದಾ: ಜೆಂಟಾಮೈಸಿನ್) ಕೊಡಲಾಗಿತ್ತೇ?',
              'mr': 'बाळाला कानासाठी घातक औषधे (उदा. जेंटामायसिन) देण्यात आली होती का?',
            },
          ),
          Question(
            id: 's1_q4',
            text: {
              'en': 'Did the mother have a congenital infection during pregnancy (CMV, rubella, herpes)?',
              'hi': 'क्या माँ को गर्भावस्था के दौरान कोई जन्मजात संक्रमण (CMV, रूबेला) था?',
              'kn': 'ಗರ್ಭಾವಸ್ಥೆಯಲ್ಲಿ ತಾಯಿಗೆ ಜನ್ಮಜಾತ ಸೋಂಕು (CMV, ರುಬೆಲ್ಲಾ) ಇತ್ತೇ?',
              'mr': 'आईला गर्भधारणेदरम्यान जन्मजात संसर्ग (CMV, रुबेला) झाला होता का?',
            },
          ),
          Question(
            id: 's1_q5',
            text: {
              'en': 'Did the baby have hyperbilirubinemia (jaundice) requiring exchange transfusion?',
              'hi': 'क्या बच्चे को एक्सचेंज ट्रांसफ्यूजन की जरूरत पड़ी (गंभीर पीलिया)?',
              'kn': 'ಮಗುವಿಗೆ ವಿನಿಮಯ ರಕ್ತ ವರ್ಗಾವಣೆ ಅಗತ್ಯವಾದ ಕಾಮಾಲೆ ಇತ್ತೇ?',
              'mr': 'बाळाला एक्सचेंज ट्रान्सफ्यूजन आवश्यक असलेली कावीळ झाली होती का?',
            },
          ),
          Question(
            id: 's1_q6',
            text: {
              'en': 'Does the baby have craniofacial abnormalities (ears, face, or head shape)?',
              'hi': 'क्या बच्चे के कान, चेहरे या सिर के आकार में कोई असामान्यता है?',
              'kn': 'ಮಗುವಿನ ಕಿವಿ, ಮುಖ ಅಥವಾ ತಲೆ ಆಕಾರದಲ್ಲಿ ಅಸ್ವಾಭಾವಿಕತೆ ಇದೆಯೇ?',
              'mr': 'बाळाच्या कान, चेहरा किंवा डोक्याच्या आकारात काही विकृती आहे का?',
            },
          ),
          Question(
            id: 's1_q7',
            text: {
              'en': 'Was the baby diagnosed with bacterial meningitis?',
              'hi': 'क्या बच्चे को बैक्टीरियल मेनिनजाइटिस का निदान हुआ था?',
              'kn': 'ಮಗುವಿಗೆ ಬ್ಯಾಕ್ಟೀರಿಯಲ್ ಮೆನಿಂಜೈಟಿಸ್ ರೋಗನಿರ್ಣಯ ಆಗಿತ್ತೇ?',
              'mr': 'बाळाला बॅक्टेरियल मेनिंजाइटिसचे निदान झाले होते का?',
            },
          ),
          Question(
            id: 's1_q8',
            text: {
              'en': 'Was the baby on a ventilator (mechanical ventilation) for more than 5 days?',
              'hi': 'क्या बच्चे को 5 दिन से अधिक वेंटिलेटर पर रखा गया था?',
              'kn': 'ಮಗುವನ್ನು 5 ದಿನಗಳಿಗಿಂತ ಹೆಚ್ಚು ವೆಂಟಿಲೇಟರ್ ಮೇಲೆ ಇಡಲಾಗಿತ್ತೇ?',
              'mr': 'बाळाला ५ दिवसांपेक्षा जास्त काळ व्हेंटिलेटरवर ठेवले होते का?',
            },
          ),
          Question(
            id: 's1_q9',
            text: {
              'en': 'Is the baby associated with a syndrome known to include hearing loss (e.g., Down, Waardenburg)?',
              'hi': 'क्या बच्चे में सुनने की समस्या से जुड़ा कोई सिंड्रोम है (जैसे डाउन सिंड्रोम)?',
              'kn': 'ಮಗುವಿಗೆ ಶ್ರವಣ ನಷ್ಟ ಸಂಬಂಧಿತ ಸಿಂಡ್ರೋಮ್ (ಉದಾ: ಡೌನ್ ಸಿಂಡ್ರೋಮ್) ಇದೆಯೇ?',
              'mr': 'बाळामध्ये श्रवणदोषाशी संबंधित काही सिंड्रोम (उदा. डाऊन सिंड्रोम) आहे का?',
            },
          ),
          Question(
            id: 's1_q10',
            text: {
              'en': 'Was there significant birth asphyxia (low Apgar score, lack of oxygen at birth)?',
              'hi': 'क्या जन्म के समय ऑक्सीजन की कमी (बर्थ एस्फिक्सिया) हुई थी?',
              'kn': 'ಜನ್ಮದ ಸಮಯದಲ್ಲಿ ಆಮ್ಲಜನಕದ ಕೊರತೆ (ಬರ್ತ್ ಅಸ್ಫಿಕ್ಸಿಯಾ) ಆಗಿತ್ತೇ?',
              'mr': 'जन्माच्या वेळी ऑक्सिजनची कमतरता (बर्थ एस्फिक्सिया) झाली होती का?',
            },
          ),
        ],
      );

  // ── Section 2: Auditory Behaviour (age-banded) ──────────────────────────────
  static QuestionnaireSection _section2(int ageMonths) {
    final allQuestions = <Question>[
      const Question(
        id: 's2_q1',
        minAgeMonths: 0,
        maxAgeMonths: 3,
        text: {
          'en': 'Does the baby startle or blink when there is a sudden loud sound?',
          'hi': 'क्या बच्चा अचानक तेज आवाज सुनकर चौंकता या पलकें झपकाता है?',
          'kn': 'ಇದ್ದಕ್ಕಿದ್ದಂತೆ ದೊಡ್ಡ ಶಬ್ದ ಕೇಳಿದಾಗ ಮಗು ಬೆಚ್ಚಿಬೀಳುತ್ತದೆ ಅಥವಾ ಕಣ್ಣು ಮಿಟುಕಿಸುತ್ತದೆಯೇ?',
          'mr': 'अचानक मोठा आवाज आल्यावर बाळ दचकते किंवा डोळे मिचकावते का?',
        },
      ),
      const Question(
        id: 's2_q2',
        minAgeMonths: 0,
        maxAgeMonths: 3,
        text: {
          'en': 'Does the baby seem to calm down or wake up in response to your voice?',
          'hi': 'क्या बच्चा आपकी आवाज सुनकर शांत होता है या जागता है?',
          'kn': 'ನಿಮ್ಮ ಧ್ವನಿ ಕೇಳಿ ಮಗು ಶಾಂತವಾಗುತ್ತದೆ ಅಥವಾ ಎಚ್ಚರಗೊಳ್ಳುತ್ತದೆಯೇ?',
          'mr': 'तुमचा आवाज ऐकल्यावर बाळ शांत होते किंवा जागे होते असे वाटते का?',
        },
      ),
      const Question(
        id: 's2_q3',
        minAgeMonths: 2,
        maxAgeMonths: 5,
        text: {
          'en': 'Does the baby smile or show a reaction when you speak to them?',
          'hi': 'क्या बच्चा आपसे बात करने पर मुस्कुराता है या प्रतिक्रिया देता है?',
          'kn': 'ನೀವು ಮಾತನಾಡಿದಾಗ ಮಗು ನಗುತ್ತದೆ ಅಥವಾ ಪ್ರತಿಕ್ರಿಯಿಸುತ್ತದೆಯೇ?',
          'mr': 'तुम्ही बाळाशी बोलता तेव्हा ते हसते किंवा काही प्रतिक्रिया देते का?',
        },
      ),
      const Question(
        id: 's2_q4',
        minAgeMonths: 2,
        maxAgeMonths: 5,
        text: {
          'en': 'Does the baby make cooing or gurgling sounds?',
          'hi': 'क्या बच्चा गुनगुनाने या बुदबुदाने जैसी आवाजें निकालता है?',
          'kn': 'ಮಗು ಗುರುಗುರು ಅಥವಾ ಕೊಕ್ಕರೆ ಶಬ್ದ ಮಾಡುತ್ತದೆಯೇ?',
          'mr': 'बाळ कुई-कुई किंवा गुळण्या केल्यासारखे आवाज काढते का?',
        },
      ),
      const Question(
        id: 's2_q5',
        minAgeMonths: 4,
        maxAgeMonths: 7,
        text: {
          'en': 'Does the baby turn their eyes or head toward a sound source?',
          'hi': 'क्या बच्चा आवाज की दिशा में आंखें या सिर घुमाता है?',
          'kn': 'ಮಗು ಶಬ್ದ ಬರುವ ದಿಕ್ಕಿಗೆ ಕಣ್ಣು ಅಥವಾ ತಲೆ ತಿರುಗಿಸುತ್ತದೆಯೇ?',
          'mr': 'बाळ डोळे किंवा डोके आवाजाच्या दिशेने वळवते का?',
        },
      ),
      const Question(
        id: 's2_q6',
        minAgeMonths: 4,
        maxAgeMonths: 7,
        text: {
          'en': 'Does the baby respond differently to happy versus angry voice tones?',
          'hi': 'क्या बच्चा खुश और गुस्से वाली आवाज के बीच फर्क करता है?',
          'kn': 'ಮಗು ಸಂತೋಷ ಮತ್ತು ಕೋಪದ ದನಿಗಳ ನಡುವೆ ವ್ಯತ್ಯಾಸ ತೋರಿಸುತ್ತದೆಯೇ?',
          'mr': 'आनंदी विरुद्ध रागीट आवाजाच्या सुरांना बाळ वेगळ्या प्रकारे प्रतिसाद देते का?',
        },
      ),
      const Question(
        id: 's2_q7',
        minAgeMonths: 6,
        maxAgeMonths: 9,
        text: {
          'en': 'Does the baby babble (e.g., "ba-ba", "da-da", "ma-ma")?',
          'hi': 'क्या बच्चा बड़बड़ाता है (जैसे "बा-बा", "मा-मा")?',
          'kn': 'ಮಗು ಬಡ್ಬಡಿಸುತ್ತದೆಯೇ (ಉದಾ: "ಬಾ-ಬಾ", "ಮಾ-ಮಾ")?',
          'mr': 'बाळ "बा-बा", "दा-दा", "मा-मा" असे बडबडते का?',
        },
      ),
      const Question(
        id: 's2_q8',
        minAgeMonths: 6,
        maxAgeMonths: 9,
        text: {
          'en': 'Does the baby respond to their own name when called?',
          'hi': 'क्या बच्चा अपना नाम बुलाने पर प्रतिक्रिया देता है?',
          'kn': 'ಮಗುವನ್ನು ಹೆಸರಿನಿಂದ ಕರೆದಾಗ ಪ್ರತಿಕ್ರಿಯಿಸುತ್ತದೆಯೇ?',
          'mr': 'बाळाला त्याच्या नावाने हाक मारल्यास ते प्रतिसाद देते का?',
        },
      ),
      const Question(
        id: 's2_q9',
        minAgeMonths: 9,
        maxAgeMonths: 12,
        text: {
          'en': 'Does the baby imitate sounds or words they hear from you?',
          'hi': 'क्या बच्चा आपसे सुनी आवाजें या शब्द दोहराता है?',
          'kn': 'ಮಗು ನಿಮ್ಮಿಂದ ಕೇಳಿದ ಶಬ್ದಗಳನ್ನು ಅಥವಾ ಪದಗಳನ್ನು ಅನುಕರಿಸುತ್ತದೆಯೇ?',
          'mr': 'बाळ तुम्ही काढलेले आवाज किंवा शब्दांचे अनुकरण करते का?',
        },
      ),
      const Question(
        id: 's2_q10',
        minAgeMonths: 9,
        maxAgeMonths: 12,
        text: {
          'en': 'Does the baby understand simple words like "no" or "bye-bye"?',
          'hi': 'क्या बच्चा "नहीं" या "बाय-बाय" जैसे सरल शब्द समझता है?',
          'kn': 'ಮಗು "ಬೇಡ" ಅಥವಾ "ಬಾಯ್-ಬಾಯ್" ಮುಂತಾದ ಸರಳ ಪದಗಳನ್ನು ಅರ್ಥ ಮಾಡಿಕೊಳ್ಳುತ್ತದೆಯೇ?',
          'mr': 'बाळाला "नाही" किंवा "बाय-बाय" यांसारखे सोपे शब्द समजतात का?',
        },
      ),
    ];

    final filtered = allQuestions.where((q) {
      if (q.minAgeMonths == null && q.maxAgeMonths == null) return true;
      final min = q.minAgeMonths ?? 0;
      final max = q.maxAgeMonths ?? 12;
      return ageMonths >= min && ageMonths <= max;
    }).toList();

    final questions = filtered.isNotEmpty
        ? filtered
        : allQuestions.where((q) => (q.maxAgeMonths ?? 12) <= 3).toList();

    return QuestionnaireSection(
      index: 2,
      title: {
        'en': 'Auditory Behaviour',
        'hi': 'श्रवण व्यवहार',
        'kn': 'ಶ್ರವಣ ವರ್ತನೆ',
        'mr': 'श्रवण वर्तणूक',
      },
      subtitle: {
        'en': 'Observe and answer based on your baby\'s recent responses to sound.',
        'hi': 'अपने बच्चे की आवाज के प्रति हालिया प्रतिक्रियाओं के आधार पर निरीक्षण करें और उत्तर दें।',
        'kn': 'ಶಬ್ದಕ್ಕೆ ನಿಮ್ಮ ಮಗುವಿನ ಇತ್ತೀಚಿನ ಪ್ರತಿಕ್ರಿಯೆಗಳ ಆಧಾರದ ಮೇಲೆ ಗಮನಿಸಿ ಮತ್ತು ಉತ್ತರಿಸಿ.',
        'mr': 'बाळाच्या आवाजाला मिळालेल्या अलीकडील प्रतिसादांच्या आधारावर निरीक्षण करा आणि उत्तरे द्या.',
      },
      questions: questions,
    );
  }

  // ── Section 3: Advanced Behavioral Indicators ───────────────────────────────
  static QuestionnaireSection _section3() => const QuestionnaireSection(
        index: 3,
        title: {
          'en': 'Advanced Behavioural Indicators',
          'hi': 'उन्नत व्यवहार संबंधी संकेतक',
          'kn': 'ಸುಧಾರಿತ ವರ್ತನೆಯ ಸೂಚಕಗಳು',
          'mr': 'प्रगत वर्तणूक निर्देशक',
        },
        subtitle: {
          'en': 'These patterns can indicate problems with auditory processing.',
          'hi': 'ये पैटर्न श्रवण प्रसंस्करण के साथ समस्याओं का संकेत दे सकते हैं।',
          'kn': 'ಈ ಮಾದರಿಗಳು ಶ್ರವಣ ಸಂಸ್ಕರಣೆಯ ಸಮಸ್ಯೆಗಳನ್ನು ಸೂಚಿಸಬಹುದು.',
          'mr': 'हे नमुने श्रवण प्रक्रियेतील समस्या दर्शवू शकतात.',
        },
        questions: [
          Question(
            id: 's3_q1',
            text: {
              'en': 'Does the baby seem unaware of sounds not in their direct line of sight?',
              'hi': 'क्या बच्चा अपनी दृष्टि के बाहर की आवाजों से अनजान लगता है?',
              'kn': 'ಮಗು ತನ್ನ ದೃಷ್ಟಿಯ ಹೊರಗಿನ ಶಬ್ದಗಳ ಬಗ್ಗೆ ಅರಿವಿಲ್ಲದಂತೆ ಕಾಣುತ್ತದೆಯೇ?',
              'mr': 'बाळाच्या थेट नजरेत नसलेल्या आवाजांबाबत बाळ अनभिज्ञ वाटते का?',
            },
          ),
          Question(
            id: 's3_q2',
            text: {
              'en': 'Does the baby fail to locate the source of a sound by turning their head?',
              'hi': 'क्या बच्चा सिर घुमाकर आवाज के स्रोत को पहचान पाने में असफल रहता है?',
              'kn': 'ಮಗು ತಲೆ ತಿರುಗಿಸಿ ಶಬ್ದದ ಮೂಲವನ್ನು ಗುರುತಿಸಲು ವಿಫಲವಾಗುತ್ತದೆಯೇ?',
              'mr': 'बाळ आपले डोके वळवून आवाजाचा स्रोत शोधण्यात अपयशी ठरते का?',
            },
          ),
          Question(
            id: 's3_q3',
            text: {
              'en': 'Is the baby\'s speech or sound production delayed compared to peers of the same age?',
              'hi': 'क्या बच्चे की बोलने की क्षमता या आवाज समवयस्कों की तुलना में देर से विकसित हो रही है?',
              'kn': 'ಅದೇ ವಯಸ್ಸಿನ ಮಕ್ಕಳಿಗೆ ಹೋಲಿಸಿದರೆ ಮಗುವಿನ ಮಾತು ಅಥವಾ ಶಬ್ದ ಉತ್ಪಾದನೆ ತಡವಾಗಿದೆಯೇ?',
              'mr': 'बाळाचे बोलणे किंवा आवाज काढणे त्याच वयाच्या इतर मुलांच्या तुलनेत उशिरा होत आहे का?',
            },
          ),
          Question(
            id: 's3_q4',
            text: {
              'en': 'Does the baby rely on visual cues (lip-reading, gestures) more than hearing?',
              'hi': 'क्या बच्चा सुनने से ज्यादा दृश्य संकेतों (होठों को पढ़ना, हाव-भाव) पर निर्भर करता है?',
              'kn': 'ಮಗು ಶ್ರವಣಕ್ಕಿಂತ ದೃಶ್ಯ ಸೂಚನೆಗಳಿಗೆ (ತುಟಿ ಓದುವುದು, 身振り) ಹೆಚ್ಚು ಅವಲಂಬಿಸುತ್ತದೆಯೇ?',
              'mr': 'बाळ ऐकण्यापेक्षा दृश्य संकेतांवर (ओठ वाचणे, हावभाव) जास्त अवलंबून आहे का?',
            },
          ),
        ],
      );

  // ── Section 4: Parental Concerns ────────────────────────────────────────────
  static QuestionnaireSection _section4() => const QuestionnaireSection(
        index: 4,
        title: {
          'en': 'Parental Concerns',
          'hi': 'माता-पिता की चिंताएं',
          'kn': 'ಪೋಷಕರ ಕಳವಳಗಳು',
          'mr': 'पालकांच्या चिंता',
        },
        subtitle: {
          'en': 'Your observations as a parent are clinically valuable.',
          'hi': 'एक माता-पिता के रूप में आपके अवलोकन चिकित्सकीय रूप से मूल्यवान हैं।',
          'kn': 'ಪೋಷಕರಾಗಿ ನಿಮ್ಮ ಅವಲೋಕನಗಳು ವೈದ್ಯಕೀಯವಾಗಿ ಮೌಲ್ಯಯುತವಾಗಿವೆ.',
          'mr': 'पालक म्हणून तुमची निरीक्षणे वैद्यकीयदृष्ट्या मौल्यवान आहेत.',
        },
        questions: [
          Question(
            id: 's4_q1',
            text: {
              'en': 'Do you feel your baby does not hear as well as expected?',
              'hi': 'क्या आपको लगता है कि आपका बच्चा उतना नहीं सुनता जितना सुनना चाहिए?',
              'kn': 'ನಿಮ್ಮ ಮಗು ನಿರೀಕ್ಷಿತಷ್ಟು ಚೆನ್ನಾಗಿ ಕೇಳುತ್ತಿಲ್ಲ ಎಂದು ನಿಮಗೆ ಅನಿಸುತ್ತದೆಯೇ?',
              'mr': 'तुमच्या बाळाला अपेक्षेप्रमाणे ऐकू येत नाही असे तुम्हाला वाटते का?',
            },
          ),
          Question(
            id: 's4_q2',
            text: {
              'en': 'Have others (family, doctor) expressed concern about your baby\'s hearing?',
              'hi': 'क्या परिवार या डॉक्टर ने बच्चे की सुनने की क्षमता को लेकर चिंता जताई है?',
              'kn': 'ಕುಟುಂಬ ಅಥವಾ ವೈದ್ಯರು ಮಗುವಿನ ಶ್ರವಣದ ಬಗ್ಗೆ ಕಳವಳ ವ್ಯಕ್ತಪಡಿಸಿದ್ದಾರೆಯೇ?',
              'mr': 'इतरांनी (कुटुंब, डॉक्टर) तुमच्या बाळाच्या श्रवणक्षमतेबद्दल चिंता व्यक्त केली आहे का?',
            },
          ),
          Question(
            id: 's4_q3',
            text: {
              'en': 'Do you need to speak louder than usual to get a reaction from your baby?',
              'hi': 'क्या बच्चे से प्रतिक्रिया पाने के लिए आपको सामान्य से ज्यादा जोर से बोलना पड़ता है?',
              'kn': 'ಮಗುವಿನಿಂದ ಪ್ರತಿಕ್ರಿಯೆ ಪಡೆಯಲು ನೀವು ಸಾಮಾನ್ಯಕ್ಕಿಂತ ಜೋರಾಗಿ ಮಾತನಾಡಬೇಕಾಗುತ್ತದೆಯೇ?',
              'mr': 'बाळाकडून प्रतिसाद मिळवण्यासाठी तुम्हाला नेहमीपेक्षा मोठ्याने बोलावे लागते का?',
            },
          ),
          Question(
            id: 's4_q4',
            text: {
              'en': 'Has your baby been unusually quiet or less vocal than other babies of the same age?',
              'hi': 'क्या आपका बच्चा समान उम्र के अन्य बच्चों की तुलना में असामान्य रूप से शांत है?',
              'kn': 'ನಿಮ್ಮ ಮಗು ಅದೇ ವಯಸ್ಸಿನ ಇತರ ಮಕ್ಕಳಿಗಿಂತ ಅಸಾಮಾನ್ಯವಾಗಿ ಶಾಂತ ಅಥವಾ ಕಡಿಮೆ ಮಾತನಾಡುತ್ತಿದೆಯೇ?',
              'mr': 'तुमचे बाळ त्याच वयाच्या इतर बाळांच्या तुलनेत असामान्यपणे शांत किंवा कमी बोलके आहे का?',
            },
          ),
        ],
      );

  // ── Section 5: Screening History ────────────────────────────────────────────
  static QuestionnaireSection _section5() => const QuestionnaireSection(
        index: 5,
        title: {
          'en': 'Screening History',
          'hi': 'स्क्रीनिंग का इतिहास',
          'kn': 'ಸ್ಕ್ರೀನಿಂಗ್ ಇತಿಹಾಸ',
          'mr': 'तपासणीचा इतिहास',
        },
        subtitle: {
          'en': 'Previous newborn hearing screening results (if available).',
          'hi': 'पिछली नवजात श्रवण स्क्रीनिंग के परिणाम (यदि उपलब्ध हों)।',
          'kn': 'ಹಿಂದಿನ ನವಜಾತ ಶ್ರವಣ ಸ್ಕ್ರೀನಿಂಗ್ ಫಲಿತಾಂಶಗಳು (ಲಭ್ಯವಿದ್ದರೆ).',
          'mr': 'मागील नवजात श्रवण तपासणी निकाल (उपलब्ध असल्यास).',
        },
        questions: [
          Question(
            id: 's5_q1',
            text: {
              'en': 'Did the baby fail or receive an inconclusive OAE newborn hearing screen?',
              'hi': 'क्या बच्चे की नवजात OAE सुनवाई स्क्रीनिंग असफल या अनिश्चित रही?',
              'kn': 'ಮಗುವಿನ ನವಜಾತ OAE ಶ್ರವಣ ಪರೀಕ್ಷೆ ವಿಫಲ ಅಥವಾ ಅನಿಶ್ಚಿತ ಫಲಿತಾಂಶ ಬಂತೇ?',
              'mr': 'बाळाची नवजात OAE श्रवण तपासणी अयशस्वी किंवा अनिर्णित ठरली का?',
            },
          ),
          Question(
            id: 's5_q2',
            text: {
              'en': 'Has the baby had a formal hearing test (ABR/ASSR) before?',
              'hi': 'क्या बच्चे की पहले कोई औपचारिक सुनवाई जांच (ABR/ASSR) हुई है?',
              'kn': 'ಮಗುವಿಗೆ ಮೊದಲು ಔಪಚಾರಿಕ ಶ್ರವಣ ಪರೀಕ್ಷೆ (ABR/ASSR) ಆಗಿದೆಯೇ?',
              'mr': 'बाळाची यापूर्वी औपचारिक श्रवण चाचणी (ABR/ASSR) झाली आहे का?',
            },
          ),
          Question(
            id: 's5_q3',
            text: {
              'en': 'Was the result of any previous formal hearing test abnormal or inconclusive?',
              'hi': 'क्या पिछली किसी औपचारिक सुनवाई जांच का परिणाम असामान्य या अनिश्चित था?',
              'kn': 'ಯಾವುದೇ ಹಿಂದಿನ ಔಪಚಾರಿಕ ಶ್ರವಣ ಪರೀಕ್ಷೆಯ ಫಲಿತಾಂಶ ಅಸ್ವಾಭಾವಿಕ ಅಥವಾ ಅನಿಶ್ಚಿತ ಆಗಿತ್ತೇ?',
              'mr': 'मागील कोणत्याही औपचारिक श्रवण चाचणीचा निकाल असामान्य किंवा अनिर्णित होता का?',
            },
          ),
        ],
      );
}
