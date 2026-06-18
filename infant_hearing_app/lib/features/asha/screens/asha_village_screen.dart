import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/asha_provider.dart';
import '../widgets/infant_list_tile_widget.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
 
class AshaVillageScreen extends StatelessWidget {
  final String village;
  const AshaVillageScreen({super.key, required this.village});
 
  @override
  Widget build(BuildContext context) {
    return Consumer<AshaProvider>(
      builder: (context, provider, _) {
        final infants = provider.infantsForVillage(village);
 
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(village),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push(
              RouteConstants.ashaBatchRegistration,
              extra: {'village': village},
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Register Infants'),
          ),
          body: infants.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, 100),
                  itemCount: infants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
                  itemBuilder: (context, index) {
                    final infant = infants[index];
                    final infantId = infant.childId;
                    return FutureBuilder(
                      // Placeholder for actual lookup if needed, keeping UI consistent
                      future: Future.wait([
                         provider.questionnaireResultForInfant(infantId),
                         provider.boaResultForInfant(infantId),
                      ]),
                      builder: (context, snapshot) {
                        final results = snapshot.data ?? [null, null];
                        return InfantListTileWidget(
                          infant: infant,
                          hasQuestionnaire: results[0] != null,
                          hasBoaResult: results[1] != null,
                          onTap: () => context.push(
                            RouteConstants.ashaInfantDetail,
                            extra: {
                              'infant': infant,
                              'village': village,
                            },
                          ),
                        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
                      }
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care_rounded, size: 64, color: AppColors.textHint.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.l),
          Text('No infants registered', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Tap "Register Infants" to start screening in this village.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
