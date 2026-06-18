import 'package:infant_hearing_app/core/localization/app_localizations.dart';

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

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case AnswerValue.yes:
        return l10n.yes;
      case AnswerValue.partial:
        return l10n.pdfPartialLabel;
      case AnswerValue.no:
        return l10n.no;
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

// ── Question model — multilingual ──────────────────────────────────────────────
class Question {
  final String id;

  /// Multilingual text map. Keys: 'en', 'hi', 'kn'
  final Map<String, String> text;

  final bool scored;
  final int? minAgeMonths;
  final int? maxAgeMonths;

  const Question({
    required this.id,
    required this.text,
    this.scored = true,
    this.minAgeMonths,
    this.maxAgeMonths,
  });

  /// Returns text for [languageCode], falls back to English.
  String localizedText(String languageCode) {
    return text[languageCode] ?? text['en'] ?? '';
  }
}

// ── Section model ──────────────────────────────────────────────────────────────
class QuestionnaireSection {
  final int index;
  final Map<String, String> title;
  final Map<String, String> subtitle;
  final List<Question> questions;

  const QuestionnaireSection({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.questions,
  });

  String localizedTitle(String langCode) => title[langCode] ?? title['en'] ?? '';
  String localizedSubtitle(String langCode) => subtitle[langCode] ?? subtitle['en'] ?? '';
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
  final Map<int, double> sectionScores;

  const ScoringResult({
    required this.totalScore,
    required this.maxScore,
    required this.riskPercentage,
    required this.result,
    required this.sectionScores,
  });
}
