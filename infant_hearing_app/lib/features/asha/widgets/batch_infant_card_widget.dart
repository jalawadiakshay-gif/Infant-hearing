import 'package:flutter/material.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/shared/widgets/app_text_field.dart';

class BatchInfantCardWidget extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final String selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onRemove;

  const BatchInfantCardWidget({
    super.key,
    required this.index,
    required this.nameController,
    required this.ageController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Infant ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (index > 0)
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.close,
                      size: 18, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Name
          AppTextField(
            controller: nameController,
            label: 'Infant Name',
            hint: 'Full name',
            prefixIcon: Icons.child_care,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),

          // Age + Gender row
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: ageController,
                  label: 'Age (months)',
                  hint: '0–36',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.calendar_today_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final age = int.tryParse(v.trim());
                    if (age == null || age < 0 || age > 36) {
                      return '0–36 months';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedGender.isEmpty ? null : selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: onGenderChanged,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}