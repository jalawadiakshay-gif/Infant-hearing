import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/asha_provider.dart';
import '../widgets/asha_id_badge_widget.dart';
import '../widgets/village_tile_widget.dart';
import '../widgets/asha_stats_card.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';

class AshaDashboardScreen extends StatelessWidget {
  const AshaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AshaProvider>(
      builder: (context, provider, _) {
        final asha = provider.asha;
        if (asha == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Medical Header ───────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.fromLTRB(AppSpacing.l, 60, AppSpacing.l, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  asha.name,
                                  style: AppTextStyles.h2,
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                              onPressed: () {
                                provider.logout();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.l),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── ID Badge ─────────────────────────────────────
                    AshaIdBadgeWidget(asha: asha).animate().fadeIn().slideY(begin: 0.1),
                    
                    const SizedBox(height: AppSpacing.xl),

                    // ── Quick Stats Grid ──────────────────────────────
                    Text(
                      'SCREENING SUMMARY',
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.m,
                      mainAxisSpacing: AppSpacing.m,
                      childAspectRatio: 1.6,
                      children: [
                        AshaStatsCard(
                          label: 'Total Babies',
                          value: provider.stats['total'].toString(),
                          icon: Icons.child_care_rounded,
                          color: AppColors.primary,
                        ),
                        AshaStatsCard(
                          label: 'Completed',
                          value: provider.stats['completed'].toString(),
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                        AshaStatsCard(
                          label: 'Pending',
                          value: provider.stats['pending'].toString(),
                          icon: Icons.pending_actions_rounded,
                          color: AppColors.warning,
                        ),
                        AshaStatsCard(
                          label: 'Referrals',
                          value: provider.stats['referrals'].toString(),
                          icon: Icons.error_outline_rounded,
                          color: AppColors.error,
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Quick Actions ────────────────────────────────
                    Text(
                      'QUICK ACTIONS',
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.person_add_alt_1_rounded,
                            label: 'Register Baby',
                            onTap: () => context.push(RouteConstants.ashaBatchRegistration),
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.sync_rounded,
                            label: 'Sync Data',
                            onTap: () {},
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Pending Screenings ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PENDING SCREENINGS',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    if (provider.pendingScreenings.isEmpty)
                      _buildEmptyState('No pending screenings')
                    else
                      ...provider.pendingScreenings.take(3).map((infant) => _PendingInfantCard(infant: infant)),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Village List ──────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ASSIGNED VILLAGES',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
                        ),
                        Text(
                          '${asha.assignedVillages.length} Total',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),
                    ...asha.assignedVillages.map((village) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: VillageTileWidget(
                            villageName: village,
                            infantCount: provider.infantCountForVillage(village),
                            onTap: () => context.push(
                              RouteConstants.ashaVillage,
                              extra: {'village': village},
                            ),
                          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.05),
                        )),

                    const SizedBox(height: AppSpacing.xxxxl),
                  ]),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            label: const Text('Emergency Referral'),
            icon: const Icon(Icons.emergency_rounded),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_rounded, color: AppColors.textHint, size: 32),
            const SizedBox(height: AppSpacing.s),
            Text(message, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusL),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.s),
            Text(
              label,
              style: AppTextStyles.subheading2.copyWith(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingInfantCard extends StatelessWidget {
  final Map<String, dynamic> infant;
  const _PendingInfantCard({required this.infant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(infant['name'][0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(infant['name'], style: AppTextStyles.subheading1),
                Text('Age: ${infant['ageMonths']} months • ${infant['gender']}', style: AppTextStyles.caption),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push( 
              RouteConstants.ashaInfantDetail,
              extra: {'infant': infant},
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 36),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            ),
            child: const Text('Start', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
