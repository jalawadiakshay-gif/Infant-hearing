// ─────────────────────────────────────────────────────────────────────────────
// models/questionnaire_data.dart
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
        title: 'Basic Information',
        subtitle: 'Confirm your baby\'s key details before we begin.',
        questions: [
          Question(
            id: 's0_q1',
            text: 'Was the baby born at term (≥37 weeks gestational age)?',
            audioKey: 's0_q1_audio',
            scored: false,
          ),
          Question(
            id: 's0_q2',
            text: 'Did the baby have a normal birth weight (≥2.5 kg)?',
            audioKey: 's0_q2_audio',
            scored: false,
          ),
          Question(
            id: 's0_q3',
            text: 'Was the delivery without major complications?',
            audioKey: 's0_q3_audio',
            scored: false,
          ),
        ],
      );

  // ── Section 1: High-Risk Medical Factors ────────────────────────────────────
  static QuestionnaireSection _section1() => const QuestionnaireSection(
        index: 1,
        title: 'High-Risk Medical Factors',
        subtitle:
            'These clinical factors are linked to a higher risk of hearing loss.',
        questions: [
          Question(
            id: 's1_q1',
            text: 'Does the family have a history of childhood hearing loss?',
            audioKey: 's1_q1_audio',
          ),
          Question(
            id: 's1_q2',
            text: 'Was the baby admitted to the NICU for more than 5 days?',
            audioKey: 's1_q2_audio',
          ),
          Question(
            id: 's1_q3',
            text:
                'Was the baby exposed to ototoxic medications (e.g., gentamicin, furosemide)?',
            audioKey: 's1_q3_audio',
          ),
          Question(
            id: 's1_q4',
            text:
                'Did the mother have a congenital infection during pregnancy (CMV, rubella, herpes, syphilis, toxoplasmosis)?',
            audioKey: 's1_q4_audio',
          ),
          Question(
            id: 's1_q5',
            text:
                'Did the baby have hyperbilirubinemia (jaundice) requiring exchange transfusion?',
            audioKey: 's1_q5_audio',
          ),
          Question(
            id: 's1_q6',
            text:
                'Does the baby have craniofacial abnormalities (ears, face, or head shape)?',
            audioKey: 's1_q6_audio',
          ),
          Question(
            id: 's1_q7',
            text: 'Was the baby diagnosed with bacterial meningitis?',
            audioKey: 's1_q7_audio',
          ),
          Question(
            id: 's1_q8',
            text:
                'Was the baby on a ventilator (mechanical ventilation) for more than 5 days?',
            audioKey: 's1_q8_audio',
          ),
          Question(
            id: 's1_q9',
            text:
                'Is the baby associated with a syndrome known to include hearing loss (e.g., Down, Waardenburg)?',
            audioKey: 's1_q9_audio',
          ),
          Question(
            id: 's1_q10',
            text:
                'Was there significant birth asphyxia (low Apgar score, lack of oxygen at birth)?',
            audioKey: 's1_q10_audio',
          ),
        ],
      );

  // ── Section 2: Auditory Behaviour (age-banded) ──────────────────────────────
  static QuestionnaireSection _section2(int ageMonths) {
    final allQuestions = <Question>[
      // 0–3 months
      const Question(
        id: 's2_q1',
        text: 'Does the baby startle or blink when there is a sudden loud sound?',
        audioKey: 's2_q1_audio',
        minAgeMonths: 0,
        maxAgeMonths: 3,
      ),
      const Question(
        id: 's2_q2',
        text: 'Does the baby seem to calm down or wake up in response to your voice?',
        audioKey: 's2_q2_audio',
        minAgeMonths: 0,
        maxAgeMonths: 3,
      ),
      // 2–5 months
      const Question(
        id: 's2_q3',
        text: 'Does the baby smile or show a reaction when you speak to them?',
        audioKey: 's2_q3_audio',
        minAgeMonths: 2,
        maxAgeMonths: 5,
      ),
      const Question(
        id: 's2_q4',
        text: 'Does the baby make cooing or gurgling sounds?',
        audioKey: 's2_q4_audio',
        minAgeMonths: 2,
        maxAgeMonths: 5,
      ),
      // 4–7 months
      const Question(
        id: 's2_q5',
        text: 'Does the baby turn their eyes or head toward a sound source?',
        audioKey: 's2_q5_audio',
        minAgeMonths: 4,
        maxAgeMonths: 7,
      ),
      const Question(
        id: 's2_q6',
        text: 'Does the baby respond differently to happy versus angry voice tones?',
        audioKey: 's2_q6_audio',
        minAgeMonths: 4,
        maxAgeMonths: 7,
      ),
      // 6–9 months
      const Question(
        id: 's2_q7',
        text: 'Does the baby babble (e.g., "ba-ba", "da-da", "ma-ma")?',
        audioKey: 's2_q7_audio',
        minAgeMonths: 6,
        maxAgeMonths: 9,
      ),
      const Question(
        id: 's2_q8',
        text: 'Does the baby respond to their own name when called?',
        audioKey: 's2_q8_audio',
        minAgeMonths: 6,
        maxAgeMonths: 9,
      ),
      // 9–12 months
      const Question(
        id: 's2_q9',
        text: 'Does the baby imitate sounds or words they hear from you?',
        audioKey: 's2_q9_audio',
        minAgeMonths: 9,
        maxAgeMonths: 12,
      ),
      const Question(
        id: 's2_q10',
        text: 'Does the baby understand simple words like "no" or "bye-bye"?',
        audioKey: 's2_q10_audio',
        minAgeMonths: 9,
        maxAgeMonths: 12,
      ),
    ];

    // Filter by age band — include question if age falls within range, or if
    // no age restriction set. Always include at least the 0–3 band as fallback.
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
      title: 'Auditory Behaviour',
      subtitle:
          'Observe and answer based on your baby\'s recent responses to sound.',
      questions: questions,
    );
  }

  // ── Section 3: Advanced Behavioral Indicators ───────────────────────────────
  static QuestionnaireSection _section3() => const QuestionnaireSection(
        index: 3,
        title: 'Advanced Behavioural Indicators',
        subtitle:
            'These patterns can indicate problems with auditory processing.',
        questions: [
          Question(
            id: 's3_q1',
            text:
                'Does the baby seem unaware of sounds that are not in their direct line of sight?',
            audioKey: 's3_q1_audio',
          ),
          Question(
            id: 's3_q2',
            text:
                'Does the baby fail to locate the source of a sound by turning their head?',
            audioKey: 's3_q2_audio',
          ),
          Question(
            id: 's3_q3',
            text:
                'Is the baby\'s speech or sound production delayed compared to peers of the same age?',
            audioKey: 's3_q3_audio',
          ),
          Question(
            id: 's3_q4',
            text:
                'Does the baby appear to rely on visual cues (lip-reading, gestures) more than hearing?',
            audioKey: 's3_q4_audio',
          ),
        ],
      );

  // ── Section 4: Parental Concerns ────────────────────────────────────────────
  static QuestionnaireSection _section4() => const QuestionnaireSection(
        index: 4,
        title: 'Parental Concerns',
        subtitle: 'Your observations as a parent are clinically valuable.',
        questions: [
          Question(
            id: 's4_q1',
            text: 'Do you feel your baby does not hear as well as expected?',
            audioKey: 's4_q1_audio',
          ),
          Question(
            id: 's4_q2',
            text:
                'Have others (family, doctor) expressed concern about your baby\'s hearing?',
            audioKey: 's4_q2_audio',
          ),
          Question(
            id: 's4_q3',
            text:
                'Do you need to speak louder than usual to get a reaction from your baby?',
            audioKey: 's4_q3_audio',
          ),
          Question(
            id: 's4_q4',
            text:
                'Has your baby been unusually quiet or less vocal than other babies of the same age?',
            audioKey: 's4_q4_audio',
          ),
        ],
      );

  // ── Section 5: Screening History ────────────────────────────────────────────
  static QuestionnaireSection _section5() => const QuestionnaireSection(
        index: 5,
        title: 'Screening History',
        subtitle: 'Previous newborn hearing screening results (if available).',
        questions: [
          Question(
            id: 's5_q1',
            text:
                'Did the baby fail or receive an inconclusive result on a newborn OAE hearing screen?',
            audioKey: 's5_q1_audio',
          ),
          Question(
            id: 's5_q2',
            text: 'Has the baby had a formal hearing test (ABR/ASSR) before?',
            audioKey: 's5_q2_audio',
          ),
          Question(
            id: 's5_q3',
            text:
                'Was the result of any previous formal hearing test abnormal or inconclusive?',
            audioKey: 's5_q3_audio',
          ),
        ],
      );
}
