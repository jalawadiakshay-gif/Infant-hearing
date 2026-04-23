// ─────────────────────────────────────────────────────────────────────────────
// providers/questionnaire_provider.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import '../models/questionnaire_models.dart';
import '../models/questionnaire_data.dart';

class QuestionnaireProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  List<QuestionnaireSection> _sections = [];
  final Map<String, AnswerValue> _answers = {};
  int _currentSectionIndex = 0;
  bool _isCompleted = false;
  ScoringResult? _scoringResult;
  int _babyAgeMonths = 0;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<QuestionnaireSection> get sections => _sections;
  Map<String, AnswerValue> get answers => Map.unmodifiable(_answers);
  int get currentSectionIndex => _currentSectionIndex;
  bool get isCompleted => _isCompleted;
  ScoringResult? get scoringResult => _scoringResult;
  int get babyAgeMonths => _babyAgeMonths;

  QuestionnaireSection get currentSection => _sections[_currentSectionIndex];
  bool get isFirstSection => _currentSectionIndex == 0;
  bool get isLastSection => _currentSectionIndex == _sections.length - 1;

  double get overallProgress {
    if (_sections.isEmpty) return 0;
    final totalQuestions =
        _sections.fold<int>(0, (sum, s) => sum + s.questions.length);
    if (totalQuestions == 0) return 0;
    final answered = _answers.values
        .where((v) => v != AnswerValue.unanswered)
        .length;
    return answered / totalQuestions;
  }

  int get answeredInCurrentSection {
    if (_sections.isEmpty) return 0;
    return currentSection.questions
        .where((q) =>
            _answers[q.id] != null &&
            _answers[q.id] != AnswerValue.unanswered)
        .length;
  }

  bool get currentSectionComplete {
    if (_sections.isEmpty) return false;
    return currentSection.questions
        .every((q) => _answers[q.id] != null && _answers[q.id] != AnswerValue.unanswered);
  }

  // ── Initialise ─────────────────────────────────────────────────────────────
  void initialize(int babyAgeMonths) {
    _babyAgeMonths = babyAgeMonths;
    _sections = QuestionnaireData.getSections(babyAgeMonths: babyAgeMonths);
    _answers.clear();
    _currentSectionIndex = 0;
    _isCompleted = false;
    _scoringResult = null;
    notifyListeners();
  }

  // ── Answer a question ──────────────────────────────────────────────────────
  void answer(String questionId, AnswerValue value) {
    _answers[questionId] = value;
    notifyListeners();
  }

  AnswerValue getAnswer(String questionId) {
    return _answers[questionId] ?? AnswerValue.unanswered;
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void nextSection() {
    if (!isLastSection) {
      _currentSectionIndex++;
      notifyListeners();
    }
  }

  void previousSection() {
    if (!isFirstSection) {
      _currentSectionIndex--;
      notifyListeners();
    }
  }

  void goToSection(int index) {
    if (index >= 0 && index < _sections.length) {
      _currentSectionIndex = index;
      notifyListeners();
    }
  }

  // ── Submit & Score ─────────────────────────────────────────────────────────
  ScoringResult submit() {
    _scoringResult = _computeScore();
    _isCompleted = true;
    notifyListeners();
    return _scoringResult!;
  }

  ScoringResult _computeScore() {
    double totalScore = 0;
    double maxScore = 0;
    final Map<int, double> sectionScores = {};

    for (final section in _sections) {
      double sectionScore = 0;
      double sectionMax = 0;

      for (final question in section.questions) {
        if (!question.scored) continue;
        final answer = _answers[question.id] ?? AnswerValue.no;
        sectionScore += answer.score;
        sectionMax += 1.0;
      }

      sectionScores[section.index] = sectionMax > 0
          ? (sectionScore / sectionMax) * 100
          : 0;
      totalScore += sectionScore;
      maxScore += sectionMax;
    }

    final riskPct = maxScore > 0 ? (totalScore / maxScore) * 100 : 0.0;

    RiskResult result;
    if (riskPct <= 30) {
      result = RiskResult.pass;
    } else if (riskPct <= 60) {
      result = RiskResult.monitor;
    } else {
      result = RiskResult.refer;
    }

    return ScoringResult(
      totalScore: totalScore,
      maxScore: maxScore,
      riskPercentage: riskPct,
      result: result,
      sectionScores: sectionScores,
    );
  }

  // ── Reset ──────────────────────────────────────────────────────────────────
  void reset() {
    _answers.clear();
    _currentSectionIndex = 0;
    _isCompleted = false;
    _scoringResult = null;
    notifyListeners();
  }
}
