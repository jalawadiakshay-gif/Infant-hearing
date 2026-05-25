class AshaModel {
  final String ashaId;
  final String name;
  final String pin;
  final String phoneNumber;
  final List<String> assignedVillages;
  final List<String> assignedInfantIds;

  const AshaModel({
    required this.ashaId,
    required this.name,
    required this.pin,
    required this.phoneNumber,
    required this.assignedVillages,
    required this.assignedInfantIds,
  });

  AshaModel copyWith({
    String? ashaId,
    String? name,
    String? pin,
    String? phoneNumber,
    List<String>? assignedVillages,
    List<String>? assignedInfantIds,
  }) {
    return AshaModel(
      ashaId: ashaId ?? this.ashaId,
      name: name ?? this.name,
      pin: pin ?? this.pin,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      assignedVillages: assignedVillages ?? this.assignedVillages,
      assignedInfantIds: assignedInfantIds ?? this.assignedInfantIds,
    );
  }

  Map<String, dynamic> toMap() => {
        'ashaId': ashaId,
        'name': name,
        'pin': pin,
        'phoneNumber': phoneNumber,
        'assignedVillages': assignedVillages,
        'assignedInfantIds': assignedInfantIds,
      };

  @override
  String toString() =>
      'AshaModel(ashaId: $ashaId, name: $name, villages: $assignedVillages)';
}