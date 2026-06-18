import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import '../../asha/providers/asha_provider.dart';
import '../../../core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';

import 'package:infant_hearing_app/data/models/v2/child.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.clinicalHistory, style: AppTextStyles.h3),
      ),
      body: Consumer<AshaProvider>(
        builder: (context, provider, _) {
          final infants = provider.children;

          if (infants.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: infants.length,
            itemBuilder: (context, index) {
              final infant = infants[index];
              return _HistoryCard(infant: infant, l10n: l10n);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.noRecordsFound, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.s),
            Text(
              l10n.completedRecordsAppear,
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
  final Child infant;
  final AppLocalizations l10n;
  const _HistoryCard({required this.infant, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final name = infant.name.isNotEmpty ? infant.name : l10n.unknownLabel;
    final initial = name.isNotEmpty ? name[0] : '?';
    final screenedDate = infant.createdAt != null
        ? DateFormat('dd MMM yyyy').format(infant.createdAt!)
        : l10n.dateUnknown;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(initial, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.subheading1),
                    Text(l10n.screenedOn(screenedDate),
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(l10n.passLabel, style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ResultIcon(label: l10n.questionnaire, icon: Icons.assignment_turned_in_rounded, color: Colors.blue),
              _ResultIcon(label: l10n.boaTest, icon: Icons.hearing_rounded, color: Colors.purple),
              TextButton(
                onPressed: () => context.push(
                  RouteConstants.ashaInfantDetail,
                  extra: {'infant': infant},
                ),
                child: Text(l10n.viewReport),
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
