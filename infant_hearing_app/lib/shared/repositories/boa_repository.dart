import '../../features/boa/services/boa_api_service.dart';
import '../../core/constants/env.dart';

class BoaRepository {
  final BoaApiService boaApiService;

  BoaRepository({required this.boaApiService});

  Future<void> submitResult(Map<String, dynamic> result) async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    await boaApiService.submitResult(result);
  }

  Future<Map<String, dynamic>> getResult() async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(milliseconds: 800));
      return {
        'outcome': 'favorableHearingResponse',
        'trials': [],
      };
    }
    return await boaApiService.getResult();
  }
}
