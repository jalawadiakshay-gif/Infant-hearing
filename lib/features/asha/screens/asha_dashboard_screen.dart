import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asha_provider.dart';
import '../widgets/asha_id_badge_widget.dart';
import '../widgets/village_tile_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_constants.dart';

class AshaDashboardScreen extends StatelessWidget {
  const AshaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AshaProvider>(
      builder: (context, provider, _) {
        final asha = provider.asha;
        if (asha == null) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              'My Dashboard',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: AppColors.textSecondary),
                onPressed: () {
                  provider.logout();
                  Navigator.pushReplacementNamed(
                      context, RouteConstants.ashaLogin);
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              // ID Badge
              AshaIdBadgeWidget(asha: asha),
              const SizedBox(height: 28),

              // Villages header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assigned Villages',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${asha.assignedVillages.length} total',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Village list
              ...asha.assignedVillages.map((village) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: VillageTileWidget(
                      villageName: village,
                      infantCount: provider.infantCountForVillage(village),
                      onTap: () => Navigator.pushNamed(
                        context,
                        RouteConstants.ashaVillage,
                        arguments: {'village': village},
                      ),
                    ),
                  )),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}