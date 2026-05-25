import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/boa_models.dart';

/// Manages pre-test checklist. 
/// Using String IDs to allow UI-side localization without tight coupling.
class BoaChecklistController extends ChangeNotifier {
  late List<BoaChecklistItem> _items;

  BoaChecklistController() {
    _items = _buildChecklist();
  }

  List<BoaChecklistItem> get items => _items;
  bool get allChecked => _items.every((item) => item.isChecked);
  int get checkedCount => _items.where((i) => i.isChecked).length;

  void toggle(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _items[index].isChecked = !_items[index].isChecked;
    notifyListeners();
  }

  void reset() {
    for (final item in _items) {
      item.isChecked = false;
    }
    notifyListeners();
  }

  List<BoaChecklistItem> _buildChecklist() {
    return [
      BoaChecklistItem(
        id: 'preCheckQuiet',
        title: 'Environment',
        description: 'Quiet room requirement',
        icon: Icons.volume_off_rounded,
      ),
      BoaChecklistItem(
        id: 'preCheckInfantAlert',
        title: 'Infant State',
        description: 'Infant must be alert',
        icon: Icons.face_rounded,
      ),
      BoaChecklistItem(
        id: 'preCheckNoDistraction',
        title: 'Distractions',
        description: 'No visual distractions',
        icon: Icons.visibility_off_rounded,
      ),
      BoaChecklistItem(
        id: 'preCheckDeviceVolume',
        title: 'Volume',
        description: 'Max volume required',
        icon: Icons.volume_up_rounded,
      ),
      BoaChecklistItem(
        id: 'preCheckCaregiverFreeze',
        title: 'Stillness',
        description: 'Caregiver must remain still',
        icon: Icons.accessibility_new_rounded,
      ),
      BoaChecklistItem(
        id: 'preCheckCatchTrial',
        title: 'Catch Trial',
        description: 'Silent trials will be included',
        icon: Icons.biotech_rounded,
      ),
    ];
  }
}
