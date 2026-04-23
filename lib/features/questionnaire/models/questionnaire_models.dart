// ─────────────────────────────────────────────────────────────────────────────
// models/questionnaire_models.dart
// ─────────────────────────────────────────────────────────────────────────────

enum AnswerValue { yes, partial, no, unanswered }

extension AnswerValueExtension on AnswerValue {
  double get score {
    switch (this) {
      case AnswerValue.yes:
        return 1.0;
      case AnswerValue.partial:
        return 0.5;
      case AnswerValue.no:
        return 0.0;
      case AnswerValue.unanswered:
        return 0.0;
    }
  }

  String get label {
    switch (this) {
      case AnswerValue.yes:
        return 'Yes';
      case AnswerValue.partial:
        return 'Partial';
      case AnswerValue.no:
        return 'No';
      case AnswerValue.unanswered:
        return '';
    }
  }
}

enum RiskResult { pass, monitor, refer }

extension RiskResultExtension on RiskResult {
  String get label {
    switch (this) {
      case RiskResult.pass:
        return 'PASS';
      case RiskResult.monitor:
        return 'MONITOR';
      case RiskResult.refer:
        return 'REFER';
    }
  }

  String get explanation {
    switch (this) {
      case RiskResult.pass:
        return 'No significant risk factors were identified. Continue regular developmental monitoring and schedule the next screening in 3 months.';
      case RiskResult.monitor:
        return 'Some risk indicators were noted. Please repeat this questionnaire in 4 weeks and watch closely for any changes in your baby\'s hearing behaviour.';
      case RiskResult.refer:
        return 'Multiple risk factors identified. A formal hearing evaluation (OAE/ABR test) is strongly recommended. Please visit JNMC Audiology at the earliest.';
    }
  }
}

// ── Question model ─────────────────────────────────────────────────────────────
class Question {
  final String id;
  final String text;
  final String? audioKey; // placeholder for TTS
  final bool scored; // Section 0 questions are not scored
  final int? minAgeMonths; // age-band gating
  final int? maxAgeMonths;

  const Question({
    required this.id,
    required this.text,
    this.audioKey,
    this.scored = true,
    this.minAgeMonths,
    this.maxAgeMonths,
  });
}

// ── Section model ──────────────────────────────────────────────────────────────
class QuestionnaireSection {
  final int index;
  final String title;
  final String subtitle;
  final List<Question> questions;

  const QuestionnaireSection({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.questions,
  });
}

// ── Answer model ───────────────────────────────────────────────────────────────
class QuestionAnswer {
  final String questionId;
  final AnswerValue value;

  const QuestionAnswer({
    required this.questionId,
    required this.value,
  });

  QuestionAnswer copyWith({AnswerValue? value}) => QuestionAnswer(
        questionId: questionId,
        value: value ?? this.value,
      );
}

// ── Scoring result ─────────────────────────────────────────────────────────────
class ScoringResult {
  final double totalScore;
  final double maxScore;
  final double riskPercentage;
  final RiskResult result;
  final Map<int, double> sectionScores; // sectionIndex → score

  const ScoringResult({
    required this.totalScore,
    required this.maxScore,
    required this.riskPercentage,
    required this.result,
    required this.sectionScores,
  });
}
