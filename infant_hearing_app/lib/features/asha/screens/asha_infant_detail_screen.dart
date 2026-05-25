import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asha_provider.dart';
import '../models/boa_result_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_constants.dart';

class AshaInfantDetailScreen extends StatelessWidget {
  const AshaInfantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final infant = args?['infant'] as Map<String, dynamic>? ?? {};

    final name = infant['name'] as String? ?? 'Unnamed';
    final ageMonths = infant['ageMonths'] as int? ?? 0;
    final gender = infant['gender'] as String? ?? '';
    final infantId = infant['id'] as String? ?? '';

    return Consumer<AshaProvider>(
      builder: (context, provider, _) {
        final hasQuestionnaire =
            provider.questionnaireResultForInfant(infantId) != null;
        final hasBoaResult =
            provider.boaResultForInfant(infantId) != null;
        final boaResult = provider.boaResultForInfant(infantId);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: IconThemeData(color: AppColors.textPrimary),
          ),
          body: ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Infant info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: Text(
                        name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('$ageMonths months  •  $gender',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Actions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Fill Questionnaire action
              _ActionCard(
                icon: Icons.assignment_outlined,
                title: 'Fill Questionnaire',
                subtitle: hasQuestionnaire
                    ? 'Already filled — tap to review or redo'
                    : 'Admin-guided hearing risk questionnaire',
                isDone: hasQuestionnaire,
                onTap: () {
                  // Navigate to the existing questionnaire screen,
                  // passing context so the provider knows it's ASHA-filled
                  Navigator.pushNamed(
                    context,
                    RouteConstants.questionnaire,
                    arguments: {
                      'ageMonths': ageMonths,
                      'infantId': infantId,
                      'infantName': name,
                      'filledByAsha': true,
                    },
                  );
                },
              ),
              const SizedBox(height: 12),

              // BOA Test action
              _ActionCard(
                icon: Icons.hearing,
                title: 'BOA Test',
                subtitle: hasBoaResult
                    ? 'Result recorded — tap to view'
                    : 'Worker-operated behavioural observation audiometry',
                isDone: hasBoaResult,
                onTap: () => Navigator.pushNamed(
                  context,
                  RouteConstants.ashaBoaTest,
                  arguments: {
                    'infant': infant,
                  },
                ),
              ),

              // Show BOA result summary if done
              if (hasBoaResult && boaResult != null) ...[
                const SizedBox(height: 20),
                Text(
                  'BOA Result',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _EarRow(
                          ear: 'Left ear', response: boaResult.leftEar.label),
                      const Divider(height: 20),
                      _EarRow(
                          ear: 'Right ear',
                          response: boaResult.rightEar.label),
                      if (boaResult.notes != null &&
                          boaResult.notes!.isNotEmpty) ...[
                        const Divider(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Notes: ${boaResult.notes}',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDone;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone
                ? Colors.green.withOpacity(0.4)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDone
                    ? Colors.green.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDone ? Colors.green : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      if (isDone) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 15),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _EarRow extends StatelessWidget {
  final String ear;
  final String response;

  const _EarRow({required this.ear, required this.response});

  @override
  Widget build(BuildContext context) {
    final color = response == 'Present'
        ? Colors.green
        : response == 'Absent'
            ? Colors.red
            : Colors.orange;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(ear, style: const TextStyle(fontSize: 14)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(response,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ],
    );
  }
}