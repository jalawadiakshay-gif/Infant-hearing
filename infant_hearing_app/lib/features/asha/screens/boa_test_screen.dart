import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/boa_result_model.dart';
import '../providers/asha_provider.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';

class BoaTestScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const BoaTestScreen({super.key, this.arguments});

  @override
  State<BoaTestScreen> createState() => _BoaTestScreenState();
}

class _BoaTestScreenState extends State<BoaTestScreen> {
  BoaResponse? _leftEar;
  BoaResponse? _rightEar;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(
      Map<String, dynamic> infant, AshaProvider provider) async {
    if (_leftEar == null || _rightEar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please record a response for both ears'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = BoaResultModel(
      infantId: infant['id'] as String? ?? '',
      infantName: infant['name'] as String? ?? '',
      ashaId: provider.asha?.ashaId ?? '',
      leftEar: _leftEar!,
      rightEar: _rightEar!,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      testedAt: DateTime.now(),
    );

    await provider.saveBoaResult(result);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('BOA test result saved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final infant = widget.arguments?['infant'] as Map<String, dynamic>? ?? {};
    final name = infant['name'] as String? ?? 'Infant';

    return Consumer<AshaProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              'BOA Test — $name',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            iconTheme: IconThemeData(color: AppColors.textPrimary),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue.shade700, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'BOA Test Instructions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Position the infant facing away from you.\n'
                      '2. Make a sound (rattle/clap) on each side.\n'
                      '3. Observe if infant turns head or shows startle response.\n'
                      '4. Record your observation for each ear below.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.blue.shade800, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Left ear
              Text('Left Ear Response',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              _ResponseSelector(
                selected: _leftEar,
                onSelected: (val) => setState(() => _leftEar = val),
              ),
              const SizedBox(height: 24),

              // Right ear
              Text('Right Ear Response',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              _ResponseSelector(
                selected: _rightEar,
                onSelected: (val) => setState(() => _rightEar = val),
              ),
              const SizedBox(height: 24),

              // Notes
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Notes (optional)',
                  hintText: 'e.g. infant was crying, repeated test...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),

          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: AppPrimaryButton(
                label: 'Save BOA Result',
                isLoading: provider.status == AshaStatus.loading,
                onPressed: () => _handleSave(infant, provider),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResponseSelector extends StatelessWidget {
  final BoaResponse? selected;
  final ValueChanged<BoaResponse> onSelected;

  const _ResponseSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: BoaResponse.values.map((response) {
        final isSelected = selected == response;
        final color = response == BoaResponse.present
            ? Colors.green
            : response == BoaResponse.absent
                ? Colors.red
                : Colors.orange;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(response),
            child: Container(
              margin: EdgeInsets.only(
                  right: response != BoaResponse.inconclusive ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    response == BoaResponse.present
                        ? Icons.check_circle_outline
                        : response == BoaResponse.absent
                            ? Icons.cancel_outlined
                            : Icons.help_outline,
                    color: isSelected ? color : AppColors.textSecondary,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    response.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}