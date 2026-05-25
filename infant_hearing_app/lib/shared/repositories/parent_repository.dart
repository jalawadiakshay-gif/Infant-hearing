import '../../features/parent/models/parent_model.dart';
import '../../features/parent/services/parent_api_service.dart';
import '../../core/constants/env.dart';

class ParentRepository {
  final ParentApiService parentApiService;

  ParentRepository({required this.parentApiService});

  Future<ParentModel> createParent(ParentModel parent) async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(seconds: 1));
      return parent;
    }
    await parentApiService.createParent(parent);
    return parent;
  }

  Future<ParentModel?> getParent() async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(milliseconds: 800));
      // In Mock mode, we return null to force the Parent Profile creation flow
      // for the purpose of demonstrating the UI.
      return null;
    }
    
    final response = await parentApiService.getParent();
    if (response['data'] != null) {
      return _fromMap(response['data']);
    }
    return null;
  }

  ParentModel _fromMap(Map<String, dynamic> map) {
    return ParentModel(
      id:                  map['id'] ?? '',
      name:                map['name'] ?? '',
      phone:               map['phone'] ?? '',
      email:               map['email'],
      address:             map['address'] ?? '',
      city:                map['city'] ?? '',
      state:               map['state'] ?? '',
      emergencyContact:    map['emergencyContact'] ?? '',
      relationship:        map['relationship'] ?? 'Mother',
      bloodGroup:          map['bloodGroup'],
      preferredHospital:   map['preferredHospital'],
      isVerified:          map['isVerified'] ?? false,
    );
  }
}
