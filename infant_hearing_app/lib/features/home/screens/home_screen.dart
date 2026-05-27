import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/features/baby/providers/baby_provider.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:infant_hearing_app/features/home/widgets/quick_action_tile.dart';
import 'package:infant_hearing_app/features/home/widgets/infant_card.dart';
import 'package:infant_hearing_app/features/home/widgets/awareness_carousel.dart';
import 'package:infant_hearing_app/shared/widgets/language_switcher.dart';
import 'package:infant_hearing_app/shared/widgets/app_logo.dart';

import 'package:infant_hearing_app/features/questionnaire/providers/questionnaire_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context);
    final parent = context.watch<ParentProvider>().parent;
    final baby   = context.watch<BabyProvider>().baby;
    final qProvider = context.watch<QuestionnaireProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(AppSpacing.l, 50, AppSpacing.l, 0),
                child: Row(
                  children: [
                    const AppLogo(size: 40),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getGreeting(l10n),
                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.textHint),
                          ),
                          Row(
                            children: [
                              Text(
                                parent?.name ?? l10n.appName,
                                style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: AppSpacing.s),
                              _buildClinicalBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const LanguagePopupButton(),
                    const SizedBox(width: AppSpacing.s),
                    _buildProfileAvatar(context, parent),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.l),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Child Profile Card ─────────────────────────────────────
                baby != null
                    ? InfantCard(baby: baby)
                    : _buildWelcomeHero(context, l10n),

                const SizedBox(height: AppSpacing.xl),

                // ── Screening Progress ──────────────────────────────────────
                _buildProgressSection(context, l10n, qProvider),

                const SizedBox(height: AppSpacing.xl),

                // ── Clinical Quick Actions ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.quickActions.toUpperCase(), 
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.m,
                  mainAxisSpacing: AppSpacing.m,
                  childAspectRatio: 1.3,
                  children: [
                    QuickActionTile(
                      icon: Icons.biotech_rounded,
                      label: 'Screening',
                      subtitle: 'Start Phase 1',
                      color: AppColors.primary,
                      onTap: () => context.push(RouteConstants.questionnaire),
                    ),
                    QuickActionTile(
                      icon: Icons.analytics_rounded,
                      label: 'History',
                      subtitle: 'Past Records',
                      color: AppColors.secondary,
                      onTap: () => context.push(RouteConstants.history),
                    ),
                    QuickActionTile(
                      icon: Icons.psychology_rounded,
                      label: 'AI Assistant',
                      subtitle: 'Chat Support',
                      color: AppColors.accent,
                      onTap: () => context.push(RouteConstants.chatbot),
                    ),
                    QuickActionTile(
                      icon: Icons.menu_book_rounded,
                      label: 'Insights',
                      subtitle: 'Resources',
                      color: AppColors.warning,
                      onTap: () => context.push(RouteConstants.medicalInsights),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Medical Insights Carousel ────────────────────────────────
                Text('LATEST CLINICAL INSIGHTS', 
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
                const SizedBox(height: AppSpacing.m),
                const AwarenessCarousel(),

                const SizedBox(height: AppSpacing.xxxxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Text(
        'CLINICAL',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.success,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, parent) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.profile),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            parent?.name.isNotEmpty == true ? parent!.name[0].toUpperCase() : 'P',
            style: AppTextStyles.badge.copyWith(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, AppLocalizations l10n, QuestionnaireProvider qProvider) {
    final progress = qProvider.overallProgress;
    final isComplete = qProvider.isCompleted;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Screening Status', style: AppTextStyles.subheading1.copyWith(fontWeight: FontWeight.bold)),
              if (isComplete)
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20)
              else
                Text('${(progress * 100).toInt()}%', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            isComplete 
              ? 'Phase 1 Complete. Review your results below.' 
              : 'Complete the questionnaire to assess your baby\'s hearing health.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  Widget _buildWelcomeHero(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 40),
          const SizedBox(height: AppSpacing.l),
          Text(l10n.registerInfant, style: AppTextStyles.h2.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.s),
          Text(l10n.welcomeDescription, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9))),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: () => context.push(RouteConstants.babyProfile),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(140, 44),
            ),
            child: Text(l10n.continueButton),
          ),
        ],
      ),
    );
  }
}
