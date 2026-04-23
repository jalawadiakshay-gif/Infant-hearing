import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class AwarenessCarousel extends StatelessWidget {
  const AwarenessCarousel({super.key});

  static const _items = [
    _AwarenessItem(
      icon: Icons.schedule_rounded,
      color: Color(0xFF4F8EF7),
      title: 'Early Detection Matters',
      body:
          'Babies identified before 6 months and given early support develop speech and language at the same rate as hearing peers.',
    ),
    _AwarenessItem(
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFFF8C42),
      title: 'Know the Risk Factors',
      body:
          'NICU admission, family history of hearing loss, ototoxic drug exposure and congenital infections all raise the risk.',
    ),
    _AwarenessItem(
      icon: Icons.check_circle_outline_rounded,
      color: Color(0xFF34C789),
      title: 'Normal Hearing Milestones',
      body:
          'By 3 months babies react to sound. By 6 months they turn toward voices. By 12 months they say simple words.',
    ),
    _AwarenessItem(
      icon: Icons.hearing_rounded,
      color: Color(0xFF7C5CFC),
      title: 'OAE & ABR Tests',
      body:
          'These painless tests measure how the ear responds to sound. They can be done while your baby sleeps and take only minutes.',
    ),
    _AwarenessItem(
      icon: Icons.lightbulb_outline_rounded,
      color: Color(0xFFE9445E),
      title: 'Busting a Common Myth',
      body:
          '"Crying babies can\'t be deaf." False — babies with hearing loss cry the same as other babies. Only a proper screen can tell.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _AwarenessCard(item: _items[i]),
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
      width: 240,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              item.body,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
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
