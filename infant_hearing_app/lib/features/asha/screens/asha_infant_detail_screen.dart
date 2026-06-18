import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/v2/child.dart';
import '../../../data/models/v2/screening.dart';
import '../../../data/services/v2/app_firestore_service.dart';

class AshaInfantDetailScreen extends StatelessWidget {
  final Child infant;
  const AshaInfantDetailScreen({super.key, required this.infant});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<AppFirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(infant.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<Screening>>(
        stream: firestore.getScreeningsForChild(infant.childId),
        builder: (context, snapshot) {
          final screenings = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: _InfantHeader(infant: infant),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SCREENING ACTIONS',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: AppSpacing.m),
                      _ActionCard(
                        title: 'Questionnaire (Phase 1)',
                        subtitle: 'Developmental milestones & risk factors',
                        icon: Icons.quiz_outlined,
                        color: AppColors.primary,
                        onTap: () => context.push(RouteConstants.questionnaire, extra: {
                          'ageMonths': infant.ageMonths,
                          'filledByAsha': true,
                          'infantId': infant.childId,
                        }),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _ActionCard(
                        title: 'BOA Test (Phase 2)',
                        subtitle: 'Behavioral Observation Audiometry',
                        icon: Icons.hearing_rounded,
                        color: AppColors.secondary,
                        onTap: () => context.push(RouteConstants.boaIntro),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('HISTORY',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: AppSpacing.m),
                    ],
                  ),
                ),
              ),
              if (screenings.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No screening history')),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _HistoryTile(screening: screenings[index]),
                    childCount: screenings.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _InfantHeader extends StatelessWidget {
  final Child infant;
  const _InfantHeader({required this.infant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(infant.name[0], style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(infant.name, style: AppTextStyles.h3),
                    Text('ID: ${infant.childId.substring(0, 8).toUpperCase()}', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Badge(label: '${infant.ageMonths} mo', color: AppColors.secondary),
                        const SizedBox(width: 8),
                        _Badge(label: infant.gender, color: AppColors.info),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _InfoRow(label: 'Parent', value: infant.parentName),
          _InfoRow(label: 'Phone', value: infant.parentPhone),
          _InfoRow(label: 'Village', value: infant.village ?? 'N/A'),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subheading1.copyWith(color: color, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Screening screening;
  const _HistoryTile({required this.screening});

  @override
  Widget build(BuildContext context) {
    final isPass = screening.result == 'pass';
    final color = isPass ? AppColors.success : AppColors.error;

    return ListTile(
      leading: Icon(
        screening.type == 'q' ? Icons.description_outlined : Icons.hearing_rounded,
        color: AppColors.textSecondary,
      ),
      title: Text(screening.type == 'q' ? 'Questionnaire' : 'BOA Test'),
      subtitle: Text(screening.date.toString().split(' ')[0]),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          screening.result.toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
