import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asha_provider.dart';
import '../widgets/batch_infant_card_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';

class BatchRegistrationScreen extends StatefulWidget {
  const BatchRegistrationScreen({super.key});

  @override
  State<BatchRegistrationScreen> createState() =>
      _BatchRegistrationScreenState();
}

class _BatchRegistrationScreenState extends State<BatchRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Each infant = { nameCtrl, ageCtrl, gender }
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _ageControllers = [];
  final List<String> _genders = [];

  @override
  void initState() {
    super.initState();
    _addInfant(); // start with one card
  }

  void _addInfant() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _ageControllers.add(TextEditingController());
      _genders.add('');
    });
  }

  void _removeInfant(int index) {
    setState(() {
      _nameControllers[index].dispose();
      _ageControllers[index].dispose();
      _nameControllers.removeAt(index);
      _ageControllers.removeAt(index);
      _genders.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _ageControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit(String village) async {
    if (!_formKey.currentState!.validate()) return;

    final infants = List.generate(_nameControllers.length, (i) {
      final id =
          'infant_${DateTime.now().millisecondsSinceEpoch}_$i';
      return {
        'id': id,
        'name': _nameControllers[i].text.trim(),
        'ageMonths': int.tryParse(_ageControllers[i].text.trim()) ?? 0,
        'gender': _genders[i],
        'village': village,
        'registeredAt': DateTime.now().toIso8601String(),
      };
    });

    await context.read<AshaProvider>().registerInfants(
          village: village,
          infants: infants,
        );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${infants.length} infant${infants.length == 1 ? '' : 's'} registered successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final village = args?['village'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Register Infants — $village',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            // Cards
            ...List.generate(
              _nameControllers.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: BatchInfantCardWidget(
                  index: i,
                  nameController: _nameControllers[i],
                  ageController: _ageControllers[i],
                  selectedGender: _genders[i],
                  onGenderChanged: (val) =>
                      setState(() => _genders[i] = val ?? ''),
                  onRemove: () => _removeInfant(i),
                ),
              ),
            ),

            // Add another button
            GestureDetector(
              onTap: _addInfant,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary.withOpacity(0.04),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Add Another Infant',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Fixed bottom submit button
      bottomNavigationBar: Consumer<AshaProvider>(
        builder: (context, provider, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: AppPrimaryButton(
              label:
                  'Save ${_nameControllers.length} Infant${_nameControllers.length == 1 ? '' : 's'}',
              isLoading: provider.status == AshaStatus.loading,
              onPressed: () => _handleSubmit(village),
            ),
          ),
        ),
      ),
    );
  }
}