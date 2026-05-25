import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/localization/app_localizations.dart';

class AwarenessCarousel extends StatelessWidget {
  const AwarenessCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final items = [
      _AwarenessItem(
        icon: Icons.schedule_rounded,
        color: const Color(0xFF1565C0),
        title: l10n.earlyDetectionMatters,
        body: l10n.earlyDetectionDesc,
      ),
      _AwarenessItem(
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFED6C02),
        title: 'Know the Risk Factors',
        body: 'NICU admission, family history, and infections raise the risk.',
      ),
      _AwarenessItem(
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF2E7D32),
        title: 'Hearing Milestones',
        body: 'By 6 months babies turn toward voices. By 12 months they say simple words.',
      ),
      _AwarenessItem(
        icon: Icons.hearing_rounded,
        color: const Color(0xFF26A69A),
        title: 'OAE & ABR Tests',
        body: 'Painless tests that measure how the ear responds to sound.',
      ),
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.m),
        itemBuilder: (_, i) => _AwarenessCard(item: items[i]),
      ),
    );
  }
}

class _AwarenessCard extends StatelessWidget {
  final _AwarenessItem item;
  const _AwarenessCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.subheading1.copyWith(fontWeight: FontWeight.w800, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            item.body,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AwarenessItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _AwarenessItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}
