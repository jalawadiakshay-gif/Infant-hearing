import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/baby_model.dart';

class BabyApiService {
  final ApiClient apiClient;

  BabyApiService(this.apiClient);

  Future<Map<String, dynamic>> createBaby(BabyModel baby) async {
    return await apiClient.post(ApiEndpoints.createBaby, body: baby.toMap());
  }

  Future<List<dynamic>> getBabies() async {
    final response = await apiClient.get(ApiEndpoints.getBabies);
    return response as List<dynamic>;
  }
}