import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class QuestionnaireApiService {
  final ApiClient apiClient;

  QuestionnaireApiService(this.apiClient);

  Future<void> submitAnswers(Map<String, dynamic> answers) async {
    await apiClient.post(
      ApiEndpoints.submitQuestionnaire,
      body: answers,
    );
  }

  Future<Map<String, dynamic>> getResult() async {
    final response = await apiClient.get(
      ApiEndpoints.getQuestionnaireResult,
    );

    return response['data'];
  }
}