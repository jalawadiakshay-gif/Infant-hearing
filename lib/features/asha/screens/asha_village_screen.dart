import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asha_provider.dart';
import '../widgets/infant_list_tile_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_constants.dart';
 
class AshaVillageScreen extends StatelessWidget {
  const AshaVillageScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final village = args?['village'] as String? ?? '';
 
    return Consumer<AshaProvider>(
      builder: (context, provider, _) {
        final infants = provider.infantsForVillage(village);
 
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              village,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: IconThemeData(color: AppColors.textPrimary),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(
              context,
              RouteConstants.ashaBatchRegistration,
              arguments: {'village': village},
            ),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Register Infants',
                style: TextStyle(color: Colors.white)),
          ),
          body: infants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.child_care,
                          size: 56, color: AppColors.textSecondary),
                      const SizedBox(height: 14),
                      Text(
                        'No infants registered yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap + to register infants from this village',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  itemCount: infants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final infant = infants[index];
                    final infantId = infant['id'] as String? ?? '$index';
                    return InfantListTileWidget(
                      infant: infant,
                      hasQuestionnaire:
                          provider.questionnaireResultForInfant(infantId) !=
                              null,
                      hasBoaResult:
                          provider.boaResultForInfant(infantId) != null,
                      onTap: () => Navigator.pushNamed(
                        context,
                        RouteConstants.ashaInfantDetail,
                        arguments: {
                          'infant': infant,
                          'village': village,
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}