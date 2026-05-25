import '../../features/questionnaire/services/questionnaire_api_service.dart';
import '../../core/constants/env.dart';

class QuestionnaireRepository {
  final QuestionnaireApiService questionnaireApiService;

  QuestionnaireRepository({required this.questionnaireApiService});

  Future<void> submitAnswers(Map<String, dynamic> answers) async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    await questionnaireApiService.submitAnswers(answers);
  }

  Future<Map<String, dynamic>> getResult() async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(milliseconds: 800));
      // TEMP MOCK: Simulated scoring result
      return {
        'totalScore': 45.0,
        'maxScore': 100.0,
        'riskPercentage': 45.0,
        'result': 'monitor', // pass, monitor, refer
        'sectionScores': {
          '0': 20.0,
          '1': 50.0,
          '2': 10.0,
        }
      };
    }
    return await questionnaireApiService.getResult();
  }
}
