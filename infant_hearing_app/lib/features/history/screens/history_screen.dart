import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import '../../asha/providers/asha_provider.dart';
import '../../../core/constants/route_constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Clinical History', style: AppTextStyles.h3),
      ),
      body: Consumer<AshaProvider>(
        builder: (context, provider, _) {
          final infants = provider.allInfants.where((i) => i['status'] == 'Completed').toList();

          if (infants.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: infants.length,
            itemBuilder: (context, index) {
              final infant = infants[index];
              return _HistoryCard(infant: infant);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('No Records Found', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Completed screening records and BOA results will appear here.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> infant;
  const _HistoryCard({required this.infant});

  @override
  Widget build(BuildContext context) {
    final name = (infant['name'] as String?) ?? 'Unknown';
    final initial = name.isNotEmpty ? name[0] : '?';
    final registeredAtRaw = infant['registeredAt'] as String?;
    final screenedDate = registeredAtRaw != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(registeredAtRaw))
        : 'Date unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(initial, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.subheading1),
                    Text('Screened on $screenedDate',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('PASS', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ResultIcon(label: 'Questionnaire', icon: Icons.assignment_turned_in_rounded, color: Colors.blue),
              _ResultIcon(label: 'BOA Test', icon: Icons.hearing_rounded, color: Colors.purple),
              TextButton(
                onPressed: () => context.push(
                  RouteConstants.ashaInfantDetail,
                  extra: {'infant': infant},
                ),
                child: const Text('View Report'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ResultIcon({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}
