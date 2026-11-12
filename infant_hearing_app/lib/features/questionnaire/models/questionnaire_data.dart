// // ─────────────────────────────────────────────────────────────────────────────
// // features/questionnaire/models/questionnaire_data.dart
// // ─────────────────────────────────────────────────────────────────────────────

import 'questionnaire_models.dart';

// class QuestionnaireData {
//   static List<QuestionnaireSection> getSections({int babyAgeMonths = 0}) {
//     return [
//       _section0(),
//       _section1(),
//       _section2(babyAgeMonths),
//       _section3(),
//       _section4(),
//       _section5(),
//     ];
//   }

//   // ── Section 0: Basic Infant Info (unscored) ─────────────────────────────────
//   static QuestionnaireSection _section0() => const QuestionnaireSection(
//         index: 0,
//         title: {
//           'en': 'Basic Information',
//           'hi': 'मूलभूत जानकारी',
//           'kn': 'ಮೂಲ ಮಾಹಿತಿ',
//           'mr': 'मूलभूत माहिती',
//         },
//         subtitle: {
//           'en': 'Confirm your baby\'s key details before we begin.',
//           'hi': 'शुरू करने से पहले अपने बच्चे के मुख्य विवरणों की पुष्टि करें।',
//           'kn': 'ಪ್ರಾರಂಭಿಸುವ ಮೊದಲು ನಿಮ್ಮ ಮಗುವಿನ ಪ್ರಮುಖ ವಿವರಗಳನ್ನು ಖಚಿತಪಡಿಸಿ.',
//           'mr': 'सुरू करण्यापूर्वी तुमच्या बाळाच्या महत्त्वाच्या तपशीलांची पुष्टी करा.',
//         },
//         questions: [
//           Question(
//             id: 's0_q1',
//             scored: false,
//             text: {
//               'en': 'Was the baby born at term (≥37 weeks gestational age)?',
//               'hi': 'क्या बच्चा समय पर (≥37 सप्ताह) जन्मा था?',
//               'kn': 'ಮಗು ಸಮಯಕ್ಕೆ (≥37 ವಾರ) ಜನಿಸಿದೆಯೇ?',
//               'mr': 'बाळाचा जन्म वेळेवर (≥३७ आठवडे गर्भधारणेचे वय) झाला होता का?',
//             },
//           ),
//           Question(
//             id: 's0_q2',
//             scored: false,
//             text: {
//               'en': 'Did the baby have a normal birth weight (≥2.5 kg)?',
//               'hi': 'क्या बच्चे का जन्म वजन सामान्य (≥2.5 kg) था?',
//               'kn': 'ಮಗುವಿನ ಜನ್ಮ ತೂಕ ಸಾಮಾನ್ಯ (≥2.5 kg) ಇತ್ತೇ?',
//               'mr': 'जन्माच्या वेळी बाळाचे वजन सामान्य (≥२.५ किलो) होते का?',
//             },
//           ),
//           Question(
//             id: 's0_q3',
//             scored: false,
//             text: {
//               'en': 'Was the delivery without major complications?',
//               'hi': 'क्या प्रसव बिना किसी बड़ी जटिलता के हुआ?',
//               'kn': 'ಹೆರಿಗೆ ದೊಡ್ಡ ತೊಂದರೆಗಳಿಲ್ಲದೆ ಆಯಿತೇ?',
//               'mr': 'प्रसूती कोणत्याही मोठ्या गुंतागुंतीशिवाय झाली का?',
//             },
//           ),
//         ],
//       );

//   // ── Section 1: High-Risk Medical Factors ────────────────────────────────────
//   static QuestionnaireSection _section1() => const QuestionnaireSection(
//         index: 1,
//         title: {
//           'en': 'High-Risk Medical Factors',
//           'hi': 'उच्च-जोखिम वाले चिकित्सा कारक',
//           'kn': 'ಹೆಚ್ಚಿನ ಅಪಾಯದ ವೈದ್ಯಕೀಯ ಅಂಶಗಳು',
//           'mr': 'उच्च-धोक्याचे वैद्यकीय घटक',
//         },
//         subtitle: {
//           'en': 'These clinical factors are linked to a higher risk of hearing loss.',
//           'hi': 'ये नैदानिक ​​कारक सुनने की शक्ति कम होने के उच्च जोखिम से जुड़े हैं।',
//           'kn': 'ಈ ವೈದ್ಯಕೀಯ ಅಂಶಗಳು ಶ್ರವಣ ನಷ್ಟದ ಹೆಚ್ಚಿನ ಅಪಾಯಕ್ಕೆ ಸಂಬಂಧಿಸಿವೆ.',
//           'mr': 'हे क्लिनिकल घटक श्रवणदोषाच्या उच्च जोखमीशी संबंधित आहेत.',
//         },
//         questions: [
//           Question(
//             id: 's1_q1',
//             text: {
//               'en': 'Does the family have a history of childhood hearing loss?',
//               'hi': 'क्या परिवार में बचपन की सुनने की समस्या का इतिहास है?',
//               'kn': 'ಕುಟುಂಬದಲ್ಲಿ ಬಾಲ್ಯದ ಶ್ರವಣ ನಷ್ಟದ ಇತಿಹಾಸ ಇದೆಯೇ?',
//               'mr': 'कुटुंबात बालपणातील श्रवणदोषाचा इतिहास आहे का?',
//             },
//           ),
//           Question(
//             id: 's1_q2',
//             text: {
//               'en': 'Was the baby admitted to the NICU for more than 5 days?',
//               'hi': 'क्या बच्चे को 5 दिन से अधिक NICU में भर्ती किया गया था?',
//               'kn': 'ಮಗುವನ್ನು 5 ದಿನಗಳಿಗಿಂತ ಹೆಚ್ಚು NICU ನಲ್ಲಿ ದಾಖಲಿಸಲಾಗಿತ್ತೇ?',
//               'mr': 'बाळाला ५ दिवसांपेक्षा जास्त काळ NICU मध्ये दाखल केले होते का?',
//             },
//           ),
//           Question(
//             id: 's1_q3',
//             text: {
//               'en': 'Was the baby exposed to ototoxic medications (e.g., gentamicin, furosemide)?',
//               'hi': 'क्या बच्चे को कर्णविषाक्त दवाएं (जैसे जेंटामाइसिन) दी गई थीं?',
//               'kn': 'ಮಗುವಿಗೆ ಕಿವಿಗೆ ಹಾನಿಕರ ಔಷಧಗಳು (ಉದಾ: ಜೆಂಟಾಮೈಸಿನ್) ಕೊಡಲಾಗಿತ್ತೇ?',
//               'mr': 'बाळाला कानासाठी घातक औषधे (उदा. जेंटामायसिन) देण्यात आली होती का?',
//             },
//           ),
//           Question(
//             id: 's1_q4',
//             text: {
//               'en': 'Did the mother have a congenital infection during pregnancy (CMV, rubella, herpes)?',
//               'hi': 'क्या माँ को गर्भावस्था के दौरान कोई जन्मजात संक्रमण (CMV, रूबेला) था?',
//               'kn': 'ಗರ್ಭಾವಸ್ಥೆಯಲ್ಲಿ ತಾಯಿಗೆ ಜನ್ಮಜಾತ ಸೋಂಕು (CMV, ರುಬೆಲ್ಲಾ) ಇತ್ತೇ?',
//               'mr': 'आईला गर्भधारणेदरम्यान जन्मजात संसर्ग (CMV, रुबेला) झाला होता का?',
//             },
//           ),
//           Question(
//             id: 's1_q5',
//             text: {
//               'en': 'Did the baby have hyperbilirubinemia (jaundice) requiring exchange transfusion?',
//               'hi': 'क्या बच्चे को एक्सचेंज ट्रांसफ्यूजन की जरूरत पड़ी (गंभीर पीलिया)?',
//               'kn': 'ಮಗುವಿಗೆ ವಿನಿಮಯ ರಕ್ತ ವರ್ಗಾವಣೆ ಅಗತ್ಯವಾದ ಕಾಮಾಲೆ ಇತ್ತೇ?',
//               'mr': 'बाळाला एक्सचेंज ट्रान्सफ्यूजन आवश्यक असलेली कावीळ झाली होती का?',
//             },
//           ),
//           Question(
//             id: 's1_q6',
//             text: {
//               'en': 'Does the baby have craniofacial abnormalities (ears, face, or head shape)?',
//               'hi': 'क्या बच्चे के कान, चेहरे या सिर के आकार में कोई असामान्यता है?',
//               'kn': 'ಮಗುವಿನ ಕಿವಿ, ಮುಖ ಅಥವಾ ತಲೆ ಆಕಾರದಲ್ಲಿ ಅಸ್ವಾಭಾವಿಕತೆ ಇದೆಯೇ?',
//               'mr': 'बाळाच्या कान, चेहरा किंवा डोक्याच्या आकारात काही विकृती आहे का?',
//             },
//           ),
//           Question(
//             id: 's1_q7',
//             text: {
//               'en': 'Was the baby diagnosed with bacterial meningitis?',
//               'hi': 'क्या बच्चे को बैक्टीरियल मेनिनजाइटिस का निदान हुआ था?',
//               'kn': 'ಮಗುವಿಗೆ ಬ್ಯಾಕ್ಟೀರಿಯಲ್ ಮೆನಿಂಜೈಟಿಸ್ ರೋಗನಿರ್ಣಯ ಆಗಿತ್ತೇ?',
//               'mr': 'बाळाला बॅक्टेरियल मेनिंजाइटिसचे निदान झाले होते का?',
//             },
//           ),
//           Question(
//             id: 's1_q8',
//             text: {
//               'en': 'Was the baby on a ventilator (mechanical ventilation) for more than 5 days?',
//               'hi': 'क्या बच्चे को 5 दिन से अधिक वेंटिलेटर पर रखा गया था?',
//               'kn': 'ಮಗುವನ್ನು 5 ದಿನಗಳಿಗಿಂತ ಹೆಚ್ಚು ವೆಂಟಿಲೇಟರ್ ಮೇಲೆ ಇಡಲಾಗಿತ್ತೇ?',
//               'mr': 'बाळाला ५ दिवसांपेक्षा जास्त काळ व्हेंटिलेटरवर ठेवले होते का?',
//             },
//           ),
//           Question(
//             id: 's1_q9',
//             text: {
//               'en': 'Is the baby associated with a syndrome known to include hearing loss (e.g., Down, Waardenburg)?',
//               'hi': 'क्या बच्चे में सुनने की समस्या से जुड़ा कोई सिंड्रोम है (जैसे डाउन सिंड्रोम)?',
//               'kn': 'ಮಗುವಿಗೆ ಶ್ರವಣ ನಷ್ಟ ಸಂಬಂಧಿತ ಸಿಂಡ್ರೋಮ್ (ಉದಾ: ಡೌನ್ ಸಿಂಡ್ರೋಮ್) ಇದೆಯೇ?',
//               'mr': 'बाळामध्ये श्रवणदोषाशी संबंधित काही सिंड्रोम (उदा. डाऊन सिंड्रोम) आहे का?',
//             },
//           ),
//           Question(
//             id: 's1_q10',
//             text: {
//               'en': 'Was there significant birth asphyxia (low Apgar score, lack of oxygen at birth)?',
//               'hi': 'क्या जन्म के समय ऑक्सीजन की कमी (बर्थ एस्फिक्सिया) हुई थी?',
//               'kn': 'ಜನ್ಮದ ಸಮಯದಲ್ಲಿ ಆಮ್ಲಜನಕದ ಕೊರತೆ (ಬರ್ತ್ ಅಸ್ಫಿಕ್ಸಿಯಾ) ಆಗಿತ್ತೇ?',
//               'mr': 'जन्माच्या वेळी ऑक्सिजनची कमतरता (बर्थ एस्फिक्सिया) झाली होती का?',
//             },
//           ),
//         ],
//       );

//   // ── Section 2: Auditory Behaviour (age-banded) ──────────────────────────────
//   static QuestionnaireSection _section2(int ageMonths) {
//     final allQuestions = <Question>[
//       const Question(
//         id: 's2_q1',
//         minAgeMonths: 0,
//         maxAgeMonths: 3,
//         text: {
//           'en': 'Does the baby startle or blink when there is a sudden loud sound?',
//           'hi': 'क्या बच्चा अचानक तेज आवाज सुनकर चौंकता या पलकें झपकाता है?',
//           'kn': 'ಇದ್ದಕ್ಕಿದ್ದಂತೆ ದೊಡ್ಡ ಶಬ್ದ ಕೇಳಿದಾಗ ಮಗು ಬೆಚ್ಚಿಬೀಳುತ್ತದೆ ಅಥವಾ ಕಣ್ಣು ಮಿಟುಕಿಸುತ್ತದೆಯೇ?',
//           'mr': 'अचानक मोठा आवाज आल्यावर बाळ दचकते किंवा डोळे मिचकावते का?',
//         },
//       ),
//       const Question(
//         id: 's2_q2',
//         minAgeMonths: 0,
//         maxAgeMonths: 3,
//         text: {
//           'en': 'Does the baby seem to calm down or wake up in response to your voice?',
//           'hi': 'क्या बच्चा आपकी आवाज सुनकर शांत होता है या जागता है?',
//           'kn': 'ನಿಮ್ಮ ಧ್ವನಿ ಕೇಳಿ ಮಗು ಶಾಂತವಾಗುತ್ತದೆ ಅಥವಾ ಎಚ್ಚರಗೊಳ್ಳುತ್ತದೆಯೇ?',
//           'mr': 'तुमचा आवाज ऐकल्यावर बाळ शांत होते किंवा जागे होते असे वाटते का?',
//         },
//       ),
//       const Question(
//         id: 's2_q3',
//         minAgeMonths: 2,
//         maxAgeMonths: 5,
//         text: {
//           'en': 'Does the baby smile or show a reaction when you speak to them?',
//           'hi': 'क्या बच्चा आपसे बात करने पर मुस्कुराता है या प्रतिक्रिया देता है?',
//           'kn': 'ನೀವು ಮಾತನಾಡಿದಾಗ ಮಗು ನಗುತ್ತದೆ ಅಥವಾ ಪ್ರತಿಕ್ರಿಯಿಸುತ್ತದೆಯೇ?',
//           'mr': 'तुम्ही बाळाशी बोलता तेव्हा ते हसते किंवा काही प्रतिक्रिया देते का?',
//         },
//       ),
//       const Question(
//         id: 's2_q4',
//         minAgeMonths: 2,
//         maxAgeMonths: 5,
//         text: {
//           'en': 'Does the baby make cooing or gurgling sounds?',
//           'hi': 'क्या बच्चा गुनगुनाने या बुदबुदाने जैसी आवाजें निकालता है?',
//           'kn': 'ಮಗು ಗುರುಗುರು ಅಥವಾ ಕೊಕ್ಕರೆ ಶಬ್ದ ಮಾಡುತ್ತದೆಯೇ?',
//           'mr': 'बाळ कुई-कुई किंवा गुळण्या केल्यासारखे आवाज काढते का?',
//         },
//       ),
//       const Question(
//         id: 's2_q5',
//         minAgeMonths: 4,
//         maxAgeMonths: 7,
//         text: {
//           'en': 'Does the baby turn their eyes or head toward a sound source?',
//           'hi': 'क्या बच्चा आवाज की दिशा में आंखें या सिर घुमाता है?',
//           'kn': 'ಮಗು ಶಬ್ದ ಬರುವ ದಿಕ್ಕಿಗೆ ಕಣ್ಣು ಅಥವಾ ತಲೆ ತಿರುಗಿಸುತ್ತದೆಯೇ?',
//           'mr': 'बाळ डोळे किंवा डोके आवाजाच्या दिशेने वळवते का?',
//         },
//       ),
//       const Question(
//         id: 's2_q6',
//         minAgeMonths: 4,
//         maxAgeMonths: 7,
//         text: {
//           'en': 'Does the baby respond differently to happy versus angry voice tones?',
//           'hi': 'क्या बच्चा खुश और गुस्से वाली आवाज के बीच फर्क करता है?',
//           'kn': 'ಮಗು ಸಂತೋಷ ಮತ್ತು ಕೋಪದ ದನಿಗಳ ನಡುವೆ ವ್ಯತ್ಯಾಸ ತೋರಿಸುತ್ತದೆಯೇ?',
//           'mr': 'आनंदी विरुद्ध रागीट आवाजाच्या सुरांना बाळ वेगळ्या प्रकारे प्रतिसाद देते का?',
//         },
//       ),
//       const Question(
//         id: 's2_q7',
//         minAgeMonths: 6,
//         maxAgeMonths: 9,
//         text: {
//           'en': 'Does the baby babble (e.g., "ba-ba", "da-da", "ma-ma")?',
//           'hi': 'क्या बच्चा बड़बड़ाता है (जैसे "बा-बा", "मा-मा")?',
//           'kn': 'ಮಗು ಬಡ್ಬಡಿಸುತ್ತದೆಯೇ (ಉದಾ: "ಬಾ-ಬಾ", "ಮಾ-ಮಾ")?',
//           'mr': 'बाळ "बा-बा", "दा-दा", "मा-मा" असे बडबडते का?',
//         },
//       ),
//       const Question(
//         id: 's2_q8',
//         minAgeMonths: 6,
//         maxAgeMonths: 9,
//         text: {
//           'en': 'Does the baby respond to their own name when called?',
//           'hi': 'क्या बच्चा अपना नाम बुलाने पर प्रतिक्रिया देता है?',
//           'kn': 'ಮಗುವನ್ನು ಹೆಸರಿನಿಂದ ಕರೆದಾಗ ಪ್ರತಿಕ್ರಿಯಿಸುತ್ತದೆಯೇ?',
//           'mr': 'बाळाला त्याच्या नावाने हाक मारल्यास ते प्रतिसाद देते का?',
//         },
//       ),
//       const Question(
//         id: 's2_q9',
//         minAgeMonths: 9,
//         maxAgeMonths: 12,
//         text: {
//           'en': 'Does the baby imitate sounds or words they hear from you?',
//           'hi': 'क्या बच्चा आपसे सुनी आवाजें या शब्द दोहराता है?',
//           'kn': 'ಮಗು ನಿಮ್ಮಿಂದ ಕೇಳಿದ ಶಬ್ದಗಳನ್ನು ಅಥವಾ ಪದಗಳನ್ನು ಅನುಕರಿಸುತ್ತದೆಯೇ?',
//           'mr': 'बाळ तुम्ही काढलेले आवाज किंवा शब्दांचे अनुकरण करते का?',
//         },
//       ),
//       const Question(
//         id: 's2_q10',
//         minAgeMonths: 9,
//         maxAgeMonths: 12,
//         text: {
//           'en': 'Does the baby understand simple words like "no" or "bye-bye"?',
//           'hi': 'क्या बच्चा "नहीं" या "बाय-बाय" जैसे सरल शब्द समझता है?',
//           'kn': 'ಮಗು "ಬೇಡ" ಅಥವಾ "ಬಾಯ್-ಬಾಯ್" ಮುಂತಾದ ಸರಳ ಪದಗಳನ್ನು ಅರ್ಥ ಮಾಡಿಕೊಳ್ಳುತ್ತದೆಯೇ?',
//           'mr': 'बाळाला "नाही" किंवा "बाय-बाय" यांसारखे सोपे शब्द समजतात का?',
//         },
//       ),
//     ];

//     final filtered = allQuestions.where((q) {
//       if (q.minAgeMonths == null && q.maxAgeMonths == null) return true;
//       final min = q.minAgeMonths ?? 0;
//       final max = q.maxAgeMonths ?? 12;
//       return ageMonths >= min && ageMonths <= max;
//     }).toList();

//     final questions = filtered.isNotEmpty
//         ? filtered
//         : allQuestions.where((q) => (q.maxAgeMonths ?? 12) <= 3).toList();

//     return QuestionnaireSection(
//       index: 2,
//       title: {
//         'en': 'Auditory Behaviour',
//         'hi': 'श्रवण व्यवहार',
//         'kn': 'ಶ್ರವಣ ವರ್ತನೆ',
//         'mr': 'श्रवण वर्तणूक',
//       },
//       subtitle: {
//         'en': 'Observe and answer based on your baby\'s recent responses to sound.',
//         'hi': 'अपने बच्चे की आवाज के प्रति हालिया प्रतिक्रियाओं के आधार पर निरीक्षण करें और उत्तर दें।',
//         'kn': 'ಶಬ್ದಕ್ಕೆ ನಿಮ್ಮ ಮಗುವಿನ ಇತ್ತೀಚಿನ ಪ್ರತಿಕ್ರಿಯೆಗಳ ಆಧಾರದ ಮೇಲೆ ಗಮನಿಸಿ ಮತ್ತು ಉತ್ತರಿಸಿ.',
//         'mr': 'बाळाच्या आवाजाला मिळालेल्या अलीकडील प्रतिसादांच्या आधारावर निरीक्षण करा आणि उत्तरे द्या.',
//       },
//       questions: questions,
//     );
//   }

//   // ── Section 3: Advanced Behavioral Indicators ───────────────────────────────
//   static QuestionnaireSection _section3() => const QuestionnaireSection(
//         index: 3,
//         title: {
//           'en': 'Advanced Behavioural Indicators',
//           'hi': 'उन्नत व्यवहार संबंधी संकेतक',
//           'kn': 'ಸುಧಾರಿತ ವರ್ತನೆಯ ಸೂಚಕಗಳು',
//           'mr': 'प्रगत वर्तणूक निर्देशक',
//         },
//         subtitle: {
//           'en': 'These patterns can indicate problems with auditory processing.',
//           'hi': 'ये पैटर्न श्रवण प्रसंस्करण के साथ समस्याओं का संकेत दे सकते हैं।',
//           'kn': 'ಈ ಮಾದರಿಗಳು ಶ್ರವಣ ಸಂಸ್ಕರಣೆಯ ಸಮಸ್ಯೆಗಳನ್ನು ಸೂಚಿಸಬಹುದು.',
//           'mr': 'हे नमुने श्रवण प्रक्रियेतील समस्या दर्शवू शकतात.',
//         },
//         questions: [
//           Question(
//             id: 's3_q1',
//             text: {
//               'en': 'Does the baby seem unaware of sounds not in their direct line of sight?',
//               'hi': 'क्या बच्चा अपनी दृष्टि के बाहर की आवाजों से अनजान लगता है?',
//               'kn': 'ಮಗು ತನ್ನ ದೃಷ್ಟಿಯ ಹೊರಗಿನ ಶಬ್ದಗಳ ಬಗ್ಗೆ ಅರಿವಿಲ್ಲದಂತೆ ಕಾಣುತ್ತದೆಯೇ?',
//               'mr': 'बाळाच्या थेट नजरेत नसलेल्या आवाजांबाबत बाळ अनभिज्ञ वाटते का?',
//             },
//           ),
//           Question(
//             id: 's3_q2',
//             text: {
//               'en': 'Does the baby fail to locate the source of a sound by turning their head?',
//               'hi': 'क्या बच्चा सिर घुमाकर आवाज के स्रोत को पहचान पाने में असफल रहता है?',
//               'kn': 'ಮಗು ತಲೆ ತಿರುಗಿಸಿ ಶಬ್ದದ ಮೂಲವನ್ನು ಗುರುತಿಸಲು ವಿಫಲವಾಗುತ್ತದೆಯೇ?',
//               'mr': 'बाळ आपले डोके वळवून आवाजाचा स्रोत शोधण्यात अपयशी ठरते का?',
//             },
//           ),
//           Question(
//             id: 's3_q3',
//             text: {
//               'en': 'Is the baby\'s speech or sound production delayed compared to peers of the same age?',
//               'hi': 'क्या बच्चे की बोलने की क्षमता या आवाज समवयस्कों की तुलना में देर से विकसित हो रही है?',
//               'kn': 'ಅದೇ ವಯಸ್ಸಿನ ಮಕ್ಕಳಿಗೆ ಹೋಲಿಸಿದರೆ ಮಗುವಿನ ಮಾತು ಅಥವಾ ಶಬ್ದ ಉತ್ಪಾದನೆ ತಡವಾಗಿದೆಯೇ?',
//               'mr': 'बाळाचे बोलणे किंवा आवाज काढणे त्याच वयाच्या इतर मुलांच्या तुलनेत उशिरा होत आहे का?',
//             },
//           ),
//           Question(
//             id: 's3_q4',
//             text: {
//               'en': 'Does the baby rely on visual cues (lip-reading, gestures) more than hearing?',
//               'hi': 'क्या बच्चा सुनने से ज्यादा दृश्य संकेतों (होठों को पढ़ना, हाव-भाव) पर निर्भर करता है?',
//               'kn': 'ಮಗು ಶ್ರವಣಕ್ಕಿಂತ ದೃಶ್ಯ ಸೂಚನೆಗಳಿಗೆ (ತುಟಿ ಓದುವುದು, 身振り) ಹೆಚ್ಚು ಅವಲಂಬಿಸುತ್ತದೆಯೇ?',
//               'mr': 'बाळ ऐकण्यापेक्षा दृश्य संकेतांवर (ओठ वाचणे, हावभाव) जास्त अवलंबून आहे का?',
//             },
//           ),
//         ],
//       );

//   // ── Section 4: Parental Concerns ────────────────────────────────────────────
//   static QuestionnaireSection _section4() => const QuestionnaireSection(
//         index: 4,
//         title: {
//           'en': 'Parental Concerns',
//           'hi': 'माता-पिता की चिंताएं',
//           'kn': 'ಪೋಷಕರ ಕಳವಳಗಳು',
//           'mr': 'पालकांच्या चिंता',
//         },
//         subtitle: {
//           'en': 'Your observations as a parent are clinically valuable.',
//           'hi': 'एक माता-पिता के रूप में आपके अवलोकन चिकित्सकीय रूप से मूल्यवान हैं।',
//           'kn': 'ಪೋಷಕರಾಗಿ ನಿಮ್ಮ ಅವಲೋಕನಗಳು ವೈದ್ಯಕೀಯವಾಗಿ ಮೌಲ್ಯಯುತವಾಗಿವೆ.',
//           'mr': 'पालक म्हणून तुमची निरीक्षणे वैद्यकीयदृष्ट्या मौल्यवान आहेत.',
//         },
//         questions: [
//           Question(
//             id: 's4_q1',
//             text: {
//               'en': 'Do you feel your baby does not hear as well as expected?',
//               'hi': 'क्या आपको लगता है कि आपका बच्चा उतना नहीं सुनता जितना सुनना चाहिए?',
//               'kn': 'ನಿಮ್ಮ ಮಗು ನಿರೀಕ್ಷಿತಷ್ಟು ಚೆನ್ನಾಗಿ ಕೇಳುತ್ತಿಲ್ಲ ಎಂದು ನಿಮಗೆ ಅನಿಸುತ್ತದೆಯೇ?',
//               'mr': 'तुमच्या बाळाला अपेक्षेप्रमाणे ऐकू येत नाही असे तुम्हाला वाटते का?',
//             },
//           ),
//           Question(
//             id: 's4_q2',
//             text: {
//               'en': 'Have others (family, doctor) expressed concern about your baby\'s hearing?',
//               'hi': 'क्या परिवार या डॉक्टर ने बच्चे की सुनने की क्षमता को लेकर चिंता जताई है?',
//               'kn': 'ಕುಟುಂಬ ಅಥವಾ ವೈದ್ಯರು ಮಗುವಿನ ಶ್ರವಣದ ಬಗ್ಗೆ ಕಳವಳ ವ್ಯಕ್ತಪಡಿಸಿದ್ದಾರೆಯೇ?',
//               'mr': 'इतरांनी (कुटुंब, डॉक्टर) तुमच्या बाळाच्या श्रवणक्षमतेबद्दल चिंता व्यक्त केली आहे का?',
//             },
//           ),
//           Question(
//             id: 's4_q3',
//             text: {
//               'en': 'Do you need to speak louder than usual to get a reaction from your baby?',
//               'hi': 'क्या बच्चे से प्रतिक्रिया पाने के लिए आपको सामान्य से ज्यादा जोर से बोलना पड़ता है?',
//               'kn': 'ಮಗುವಿನಿಂದ ಪ್ರತಿಕ್ರಿಯೆ ಪಡೆಯಲು ನೀವು ಸಾಮಾನ್ಯಕ್ಕಿಂತ ಜೋರಾಗಿ ಮಾತನಾಡಬೇಕಾಗುತ್ತದೆಯೇ?',
//               'mr': 'बाळाकडून प्रतिसाद मिळवण्यासाठी तुम्हाला नेहमीपेक्षा मोठ्याने बोलावे लागते का?',
//             },
//           ),
//           Question(
//             id: 's4_q4',
//             text: {
//               'en': 'Has your baby been unusually quiet or less vocal than other babies of the same age?',
//               'hi': 'क्या आपका बच्चा समान उम्र के अन्य बच्चों की तुलना में असामान्य रूप से शांत है?',
//               'kn': 'ನಿಮ್ಮ ಮಗು ಅದೇ ವಯಸ್ಸಿನ ಇತರ ಮಕ್ಕಳಿಗಿಂತ ಅಸಾಮಾನ್ಯವಾಗಿ ಶಾಂತ ಅಥವಾ ಕಡಿಮೆ ಮಾತನಾಡುತ್ತಿದೆಯೇ?',
//               'mr': 'तुमचे बाळ त्याच वयाच्या इतर बाळांच्या तुलनेत असामान्यपणे शांत किंवा कमी बोलके आहे का?',
//             },
//           ),
//         ],
//       );

//   // ── Section 5: Screening History ────────────────────────────────────────────
//   static QuestionnaireSection _section5() => const QuestionnaireSection(
//         index: 5,
//         title: {
//           'en': 'Screening History',
//           'hi': 'स्क्रीनिंग का इतिहास',
//           'kn': 'ಸ್ಕ್ರೀನಿಂಗ್ ಇತಿಹಾಸ',
//           'mr': 'तपासणीचा इतिहास',
//         },
//         subtitle: {
//           'en': 'Previous newborn hearing screening results (if available).',
//           'hi': 'पिछली नवजात श्रवण स्क्रीनिंग के परिणाम (यदि उपलब्ध हों)।',
//           'kn': 'ಹಿಂದಿನ ನವಜಾತ ಶ್ರವಣ ಸ್ಕ್ರೀನಿಂಗ್ ಫಲಿತಾಂಶಗಳು (ಲಭ್ಯವಿದ್ದರೆ).',
//           'mr': 'मागील नवजात श्रवण तपासणी निकाल (उपलब्ध असल्यास).',
//         },
//         questions: [
//           Question(
//             id: 's5_q1',
//             text: {
//               'en': 'Did the baby fail or receive an inconclusive OAE newborn hearing screen?',
//               'hi': 'क्या बच्चे की नवजात OAE सुनवाई स्क्रीनिंग असफल या अनिश्चित रही?',
//               'kn': 'ಮಗುವಿನ ನವಜಾತ OAE ಶ್ರವಣ ಪರೀಕ್ಷೆ ವಿಫಲ ಅಥವಾ ಅನಿಶ್ಚಿತ ಫಲಿತಾಂಶ ಬಂತೇ?',
//               'mr': 'बाळाची नवजात OAE श्रवण तपासणी अयशस्वी किंवा अनिर्णित ठरली का?',
//             },
//           ),
//           Question(
//             id: 's5_q2',
//             text: {
//               'en': 'Has the baby had a formal hearing test (ABR/ASSR) before?',
//               'hi': 'क्या बच्चे की पहले कोई औपचारिक सुनवाई जांच (ABR/ASSR) हुई है?',
//               'kn': 'ಮಗುವಿಗೆ ಮೊದಲು ಔಪಚಾರಿಕ ಶ್ರವಣ ಪರೀಕ್ಷೆ (ABR/ASSR) ಆಗಿದೆಯೇ?',
//               'mr': 'बाळाची यापूर्वी औपचारिक श्रवण चाचणी (ABR/ASSR) झाली आहे का?',
//             },
//           ),
//           Question(
//             id: 's5_q3',
//             text: {
//               'en': 'Was the result of any previous formal hearing test abnormal or inconclusive?',
//               'hi': 'क्या पिछली किसी औपचारिक सुनवाई जांच का परिणाम असामान्य या अनिश्चित था?',
//               'kn': 'ಯಾವುದೇ ಹಿಂದಿನ ಔಪಚಾರಿಕ ಶ್ರವಣ ಪರೀಕ್ಷೆಯ ಫಲಿತಾಂಶ ಅಸ್ವಾಭಾವಿಕ ಅಥವಾ ಅನಿಶ್ಚಿತ ಆಗಿತ್ತೇ?',
//               'mr': 'मागील कोणत्याही औपचारिक श्रवण चाचणीचा निकाल असामान्य किंवा अनिर्णित होता का?',
//             },
//           ),
//         ],
//       );
// }

// features/questionnaire/models/questionnaire_data.dart
//
// Latest Baalshravya age-grouped infant hearing questionnaire.
// This file is compatible with the existing QuestionnaireSection and Question
// models used by the previous questionnaire_data.dart implementation.

import 'questionnaire_models.dart';

enum QuestionnaireRespondent { parent, ashaWorker }

class QuestionnaireData {
  /// Returns the questions appropriate to [babyAgeMonths] and [respondent].
  ///
  /// The questionnaire is defined for infants aged 0-12 months. Ages outside
  /// that range are clamped to the nearest supported age group.
  static List<QuestionnaireSection> getSections({
    int babyAgeMonths = 0,
    QuestionnaireRespondent respondent = QuestionnaireRespondent.parent,
  }) {
    final age = babyAgeMonths.clamp(0, 12).toInt();

    return [
      _basicInformation(respondent),
      _medicalRiskFactors(respondent),
      _ageGroupedAuditoryBehaviour(age, respondent),
      _additionalHearingConcerns(respondent),
    ];
  }

  // Basic history is retained as unscored contextual information, matching the
  // behaviour of the former questionnaire's basic-information section.
  static QuestionnaireSection _basicInformation(
    QuestionnaireRespondent respondent,
  ) =>
      QuestionnaireSection(
        index: 0,
        title: const {'en': 'Basic Information'},
        subtitle: const {
          'en': 'Birth details that may affect hearing-risk assessment.',
        },
        questions: respondent == QuestionnaireRespondent.parent
            ? const [
                Question(
                  id: 'basic_gestational_age',
                  scored: false,
                  text: {
                    'en':
                        'B1. Gestational age: Was your baby born before completing 37 weeks of pregnancy?',
                  },
                ),
                Question(
                  id: 'basic_birth_weight',
                  scored: false,
                  text: {
                    'en':
                        'B2. Birth weight: Was your baby\'s birth weight below 2.5 kg?',
                  },
                ),
                Question(
                  id: 'basic_birth_complications',
                  scored: false,
                  text: {
                    'en':
                        'B3. Birth complications: Were there major complications during birth?',
                  },
                ),
              ]
            : const [
                Question(
                  id: 'basic_gestational_age',
                  scored: false,
                  text: {
                    'en':
                        'B1. Gestational age: Was the infant born before 37 completed weeks of gestation?',
                  },
                ),
                Question(
                  id: 'basic_birth_weight',
                  scored: false,
                  text: {
                    'en':
                        'B2. Birth weight: Was the infant\'s birth weight below 2,500 grams?',
                  },
                ),
                Question(
                  id: 'basic_birth_complications',
                  scored: false,
                  text: {
                    'en':
                        'B3. Birth complications: Were significant perinatal complications documented?',
                  },
                ),
              ],
      );

  static QuestionnaireSection _medicalRiskFactors(
    QuestionnaireRespondent respondent,
  ) =>
      QuestionnaireSection(
        index: 1,
        title: const {'en': 'Medical and Family Risk Factors'},
        subtitle: const {
          'en':
              'Answer yes when a hearing-loss risk factor is present or documented.',
        },
        questions: respondent == QuestionnaireRespondent.parent
            ? const [
                Question(id: 'risk_family_history', text: {
                  'en':
                      'M1. Family history of hearing loss: Has anyone in your family had permanent hearing loss that started during childhood?'
                }),
                Question(id: 'risk_nicu_stay', text: {
                  'en':
                      'M2. NICU or special-care stay: Did your baby stay in the NICU or special newborn-care unit for more than 5 days?'
                }),
                Question(id: 'risk_severe_jaundice', text: {
                  'en':
                      'M3. Severe jaundice: Was your baby\'s jaundice so severe that doctors needed to exchange the baby\'s blood?'
                }),
                Question(id: 'risk_ototoxic_medication', text: {
                  'en':
                      'M4. Potentially ototoxic medication: Did your baby receive medicines such as gentamicin for more than 5 days?'
                }),
                Question(id: 'risk_birth_asphyxia', text: {
                  'en':
                      'M5. Lack of oxygen around birth: Did doctors say your baby had a serious lack of oxygen around the time of birth or a related brain injury?'
                }),
                Question(id: 'risk_ecmo', text: {
                  'en':
                      'M6. ECMO treatment: Did your baby receive a special life-support treatment called ECMO?'
                }),
                Question(id: 'risk_in_utero_infection', text: {
                  'en':
                      'M7. Infection during pregnancy: During pregnancy, were you diagnosed with an infection such as CMV, rubella, herpes, syphilis, or toxoplasmosis?'
                }),
                Question(id: 'risk_craniofacial_difference', text: {
                  'en':
                      'M8. Differences in ears, face, or head: Was your baby born with a difference in the shape or structure of the ears, face, or head that a doctor identified?'
                }),
                Question(id: 'risk_syndrome', text: {
                  'en':
                      'M9. Syndrome associated with hearing loss: Has a doctor diagnosed your baby with a syndrome or genetic condition that may affect hearing?'
                }),
                Question(id: 'risk_neurological_condition', text: {
                  'en':
                      'M10. Neurological or progressive condition: Has your baby been diagnosed with a condition that affects the nerves or nervous system and may get worse over time?'
                }),
                Question(id: 'risk_serious_illness_or_injury', text: {
                  'en':
                      'M11. Serious infection, head injury, or chemotherapy: Has your baby had meningitis or encephalitis, a serious head injury, or chemotherapy treatment?'
                }),
                Question(id: 'risk_ventilator_history', text: {
                  'en':
                      'M12. Ventilator use (supplementary history): Did your baby need a breathing machine for more than 5 days?'
                }),
              ]
            : const [
                Question(id: 'risk_family_history', text: {
                  'en':
                      'M1. Family history of hearing loss: Is there a family history of permanent childhood-onset hearing loss, including progressive or delayed-onset hearing loss?'
                }),
                Question(id: 'risk_nicu_stay', text: {
                  'en':
                      'M2. NICU or special-care stay: Did the infant require NICU or special-care nursery admission for more than 5 days?'
                }),
                Question(id: 'risk_severe_jaundice', text: {
                  'en':
                      'M3. Severe jaundice: Did the infant have hyperbilirubinemia requiring exchange transfusion?'
                }),
                Question(id: 'risk_ototoxic_medication', text: {
                  'en':
                      'M4. Potentially ototoxic medication: Did the infant receive aminoglycoside medication for more than 5 days, or is there documented exposure to another potentially ototoxic medication requiring clinical review?'
                }),
                Question(id: 'risk_birth_asphyxia', text: {
                  'en':
                      'M5. Lack of oxygen around birth: Was significant perinatal asphyxia or hypoxic-ischaemic encephalopathy documented?'
                }),
                Question(id: 'risk_ecmo', text: {
                  'en':
                      'M6. ECMO treatment: Did the infant require extracorporeal membrane oxygenation (ECMO)?'
                }),
                Question(id: 'risk_in_utero_infection', text: {
                  'en':
                      'M7. Infection during pregnancy: Was a relevant in-utero infection documented, including cytomegalovirus, rubella, herpes, syphilis, or toxoplasmosis?'
                }),
                Question(id: 'risk_craniofacial_difference', text: {
                  'en':
                      'M8. Differences in ears, face, or head: Were craniofacial malformations documented that may be associated with hearing loss?'
                }),
                Question(id: 'risk_syndrome', text: {
                  'en':
                      'M9. Syndrome associated with hearing loss: Has the infant been diagnosed with a syndrome associated with sensorineural or permanent conductive hearing loss?'
                }),
                Question(id: 'risk_neurological_condition', text: {
                  'en':
                      'M10. Neurological or progressive condition: Is there a diagnosed neurodegenerative disorder or sensory-motor neuropathy associated with hearing-loss risk?'
                }),
                Question(id: 'risk_serious_illness_or_injury', text: {
                  'en':
                      'M11. Serious infection, head injury, or chemotherapy: Is there a history of confirmed bacterial or viral meningitis/encephalitis, significant head trauma, or chemotherapy?'
                }),
                Question(id: 'risk_ventilator_history', text: {
                  'en':
                      'M12. Ventilator use (supplementary history): Did the infant require mechanical ventilation for more than 5 days? Record as supplementary medical history, not a separate JCIH category.'
                }),
              ],
      );

  static QuestionnaireSection _ageGroupedAuditoryBehaviour(
    int ageMonths,
    QuestionnaireRespondent respondent,
  ) {
    final group = _AgeGroup.forMonths(ageMonths);
    final parentQuestions = _parentAgeQuestions[group]!;
    final ashaQuestions = _ashaAgeQuestions[group]!;

    return QuestionnaireSection(
      index: 2,
      title: {'en': 'Auditory Behaviour (${group.label})'},
      subtitle: {
        'en':
            'Choose yes if the concerning behaviour is often present or is clinically observed.',
      },
      questions: respondent == QuestionnaireRespondent.parent
          ? parentQuestions
          : ashaQuestions,
    );
  }

  static QuestionnaireSection _additionalHearingConcerns(
    QuestionnaireRespondent respondent,
  ) =>
      QuestionnaireSection(
        index: 3,
        title: const {'en': 'Additional Hearing Concerns'},
        subtitle: const {
          'en':
              'These concerns warrant further hearing assessment when present.',
        },
        questions: respondent == QuestionnaireRespondent.parent
            ? const [
                Question(id: 'concern_visual_cues', text: {
                  'en':
                      'A1. Reliance on visual cues: Does your baby seem to respond better when they can see your face than when they can only hear your voice?'
                }),
                Question(id: 'concern_skill_regression', text: {
                  'en':
                      'A2. Loss of previously observed skills: Has your baby stopped reacting to sounds or stopped making sounds they used to make?'
                }),
                Question(id: 'concern_inconsistent_response', text: {
                  'en':
                      'A3. Inconsistent responses: Does your baby often seem to hear you in one situation but not in another, without an obvious reason?'
                }),
              ]
            : const [
                Question(id: 'concern_visual_cues', text: {
                  'en':
                      'A1. Reliance on visual cues: Does the infant appear to rely disproportionately on visual cues rather than auditory information?'
                }),
                Question(id: 'concern_skill_regression', text: {
                  'en':
                      'A2. Loss of previously observed skills: Has there been regression in auditory responsiveness or vocal/communication behaviours?'
                }),
                Question(id: 'concern_inconsistent_response', text: {
                  'en':
                      'A3. Inconsistent responses: Is there a caregiver-reported pattern of inconsistent auditory responsiveness requiring further assessment?'
                }),
              ],
      );
}

enum _AgeGroup {
  zeroToThree('0-3 months'),
  fourToSix('4-6 months'),
  sevenToNine('7-9 months'),
  tenToTwelve('10-12 months');

  const _AgeGroup(this.label);
  final String label;

  static _AgeGroup forMonths(int months) {
    if (months <= 3) return _AgeGroup.zeroToThree;
    if (months <= 6) return _AgeGroup.fourToSix;
    if (months <= 9) return _AgeGroup.sevenToNine;
    return _AgeGroup.tenToTwelve;
  }
}

const Map<_AgeGroup, List<Question>> _parentAgeQuestions = {
  _AgeGroup.zeroToThree: [
    Question(id: 'age_0_3_loud_sound', text: {
      'en':
          'Q1. Response to loud sounds: Does your baby often not blink, startle, or otherwise react when there is a sudden loud sound?'
    }),
    Question(id: 'age_0_3_familiar_voice', text: {
      'en':
          'Q2. Response to a familiar voice: When you speak to your baby, do they often not become calmer or show any noticeable response?'
    }),
    Question(id: 'age_0_3_voice_orientation', text: {
      'en':
          'Q3. Orientation toward voices: When someone speaks nearby, does your baby often not look or turn toward the person\'s voice?'
    }),
    Question(id: 'age_0_3_vocal_interaction', text: {
      'en':
          'Q4. Early vocal interaction: When you talk to your baby, do they often not make sounds back, such as soft coos or "oo" sounds?'
    }),
  ],
  _AgeGroup.fourToSix: [
    Question(id: 'age_4_6_locating_sound', text: {
      'en':
          'Q1. Locating sounds: When your baby hears a sound they cannot see, do they often not look toward where it came from?'
    }),
    Question(id: 'age_4_6_voice_tone', text: {
      'en':
          'Q2. Response to voice tone: Does your baby often seem not to notice changes in your voice, such as a cheerful or soothing tone?'
    }),
    Question(id: 'age_4_6_sound_toys', text: {
      'en':
          'Q3. Response to sound-producing toys: When a nearby toy makes a sound, does your baby often show no noticeable reaction?'
    }),
    Question(id: 'age_4_6_vocal_response', text: {
      'en':
          'Q4. Vocal responses: Does your baby rarely make sounds back when you talk, sing, or play together?'
    }),
  ],
  _AgeGroup.sevenToNine: [
    Question(id: 'age_7_9_turning_sounds', text: {
      'en':
          'Q1. Turning toward sounds: When your baby hears a familiar sound from the side or behind them, do they often not turn to look for it?'
    }),
    Question(id: 'age_7_9_name_response', text: {
      'en':
          'Q2. Response to name: When you call your baby\'s name while they are calm and not distracted, do they often not respond?'
    }),
    Question(id: 'age_7_9_babbling', text: {
      'en':
          'Q3. Babbling: Does your baby rarely make repeated sounds such as "ba-ba," "ma-ma," or "da-da"?'
    }),
    Question(id: 'age_7_9_imitation', text: {
      'en':
          'Q4. Imitating sounds: Does your baby often not try to copy sounds you make during play?'
    }),
  ],
  _AgeGroup.tenToTwelve: [
    Question(id: 'age_10_12_familiar_words', text: {
      'en':
          'Q1. Response to familiar words: When you say familiar words such as "no" or "bye-bye" without showing a gesture, does your baby often not respond?'
    }),
    Question(id: 'age_10_12_familiar_sounds', text: {
      'en':
          'Q2. Attention to familiar sounds: Does your baby often not seem to notice familiar sounds, such as a caregiver speaking from nearby?'
    }),
    Question(id: 'age_10_12_speech_imitation', text: {
      'en':
          'Q3. Imitating speech sounds: Does your baby rarely try to copy simple sounds or syllables that you say?'
    }),
    Question(id: 'age_10_12_spoken_requests', text: {
      'en':
          'Q4. Familiar spoken requests: When you say a familiar simple request, does your baby often not seem to understand it even when you are not using gestures?'
    }),
  ],
};

const Map<_AgeGroup, List<Question>> _ashaAgeQuestions = {
  _AgeGroup.zeroToThree: [
    Question(id: 'age_0_3_loud_sound', text: {
      'en':
          'Q1. Response to loud sounds: Does the infant show little or no observable response to sudden loud auditory stimuli?'
    }),
    Question(id: 'age_0_3_familiar_voice', text: {
      'en':
          'Q2. Response to a familiar voice: Does the infant show limited observable response to a familiar caregiver\'s voice under suitable listening conditions?'
    }),
    Question(id: 'age_0_3_voice_orientation', text: {
      'en':
          'Q3. Orientation toward voices: Does the infant show limited orientation toward a familiar voice when such a response would be expected?'
    }),
    Question(id: 'age_0_3_vocal_interaction', text: {
      'en':
          'Q4. Early vocal interaction: Does the infant show limited early vocal interaction, including cooing or vocal responses during caregiver interaction?'
    }),
  ],
  _AgeGroup.fourToSix: [
    Question(id: 'age_4_6_locating_sound', text: {
      'en':
          'Q1. Locating sounds: Does the infant show limited orientation toward an audible sound source when developmentally appropriate?'
    }),
    Question(id: 'age_4_6_voice_tone', text: {
      'en':
          'Q2. Response to voice tone: Does the infant show limited observable responses to changes in vocal tone or prosody?'
    }),
    Question(id: 'age_4_6_sound_toys', text: {
      'en':
          'Q3. Response to sound-producing toys: Does the infant show limited observable response to audible toys or other everyday sounds?'
    }),
    Question(id: 'age_4_6_vocal_response', text: {
      'en':
          'Q4. Vocal responses: Does the infant show limited vocal turn-taking or vocal responses during interaction?'
    }),
  ],
  _AgeGroup.sevenToNine: [
    Question(id: 'age_7_9_turning_sounds', text: {
      'en':
          'Q1. Turning toward sounds: Does the infant show limited orientation toward familiar sounds presented outside the visual field?'
    }),
    Question(id: 'age_7_9_name_response', text: {
      'en':
          'Q2. Response to name: Does the infant show limited response to their name under suitable listening and attention conditions?'
    }),
    Question(id: 'age_7_9_babbling', text: {
      'en':
          'Q3. Babbling: Is reduplicated babbling, such as repeated consonant-vowel syllables, limited or absent?'
    }),
    Question(id: 'age_7_9_imitation', text: {
      'en':
          'Q4. Imitating sounds: Does the infant show limited attempts to imitate familiar speech sounds or other vocal sounds?'
    }),
  ],
  _AgeGroup.tenToTwelve: [
    Question(id: 'age_10_12_familiar_words', text: {
      'en':
          'Q1. Response to familiar words: Does the infant show limited response to familiar spoken words or verbal routines without accompanying visual cues?'
    }),
    Question(id: 'age_10_12_familiar_sounds', text: {
      'en':
          'Q2. Attention to familiar sounds: Does the infant show limited attention to familiar auditory stimuli in everyday environments?'
    }),
    Question(id: 'age_10_12_speech_imitation', text: {
      'en':
          'Q3. Imitating speech sounds: Does the infant show limited attempts to imitate familiar speech sounds or syllable patterns?'
    }),
    Question(id: 'age_10_12_spoken_requests', text: {
      'en':
          'Q4. Familiar spoken requests: Does the infant show limited response to familiar verbal routines or simple spoken requests when visual cues are absent?'
    }),
  ],
};
