import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class BoaApiService {
  final ApiClient apiClient;

  BoaApiService(this.apiClient);

  Future<void> submitResult(Map<String, dynamic> result) async {
    await apiClient.post(
      ApiEndpoints.submitBoa,
      body: result,
    );
  }

  Future<Map<String, dynamic>> getResult() async {
    final response = await apiClient.get(
      ApiEndpoints.getBoaResult,
    );

    return response['data'];
  }
}
