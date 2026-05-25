import '../../features/baby/models/baby_model.dart';
import '../../features/baby/services/baby_api_service.dart';
import '../../core/constants/env.dart';

class BabyRepository {
  final BabyApiService babyApiService;

  BabyRepository({required this.babyApiService});

  Future<BabyModel> createBaby(BabyModel baby) async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(seconds: 1));
      return baby;
    }
    await babyApiService.createBaby(baby);
    return baby; 
  }

  Future<List<BabyModel>> getBabies() async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(milliseconds: 800));
      // In Mock mode, return empty list to force Baby Profile creation flow
      return [];
    }
    final list = await babyApiService.getBabies();
    return list.map((e) => _fromMap(e as Map<String, dynamic>)).toList();
  }

  BabyModel _fromMap(Map<String, dynamic> map) {
    return BabyModel(
      name:           map['name'] ?? '',
      gender:         map['gender'] ?? 'Other',
      birthWeight:    (map['birthWeight'] as num?)?.toDouble() ?? 0.0,
      gestationalAge: (map['gestationalAge'] as num?)?.toInt() ?? 0,
      nicuAdmission:  map['nicuAdmission'] ?? false,
      deliveryMode:   map['deliveryMode'] ?? '',
      medicalNotes:   map['medicalNotes'],
      dob:            map['dob'] != null ? DateTime.parse(map['dob']) : DateTime.now(),
    );
  }
}
