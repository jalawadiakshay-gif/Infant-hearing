import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/parent_model.dart';

class ParentApiService {
  final ApiClient apiClient;

  ParentApiService(this.apiClient);

  Future<Map<String, dynamic>> createParent(ParentModel parent) async {
    return await apiClient.post(ApiEndpoints.createParent, body: parent.toMap());
  }

  Future<Map<String, dynamic>> getParent() async {
    return await apiClient.get(ApiEndpoints.getParent);
  }
}