import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:infant_hearing_app/features/baby/providers/baby_provider.dart';
import 'package:infant_hearing_app/shared/widgets/app_card.dart';

import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/data/models/v2/child.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parent = context.watch<ParentProvider>().parent;
    final babyProvider = context.watch<BabyProvider>();
    final babies = babyProvider.babies;
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.accountSettings, style: AppTextStyles.h3),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            // ── Parent Header ───────────────────────────────────────────
            _buildParentHeader(parent, l10n),
            const SizedBox(height: AppSpacing.xl),

            // ── Baby Profiles ───────────────────────────────────────────
            _buildBabyList(context, babies, l10n),
            const SizedBox(height: AppSpacing.xl),

            // ── App Settings ───────────────────────────────────────────
            _buildSettingsSection(context, authProvider, l10n),
            const SizedBox(height: AppSpacing.xxxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildParentHeader(parent, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              parent?.name.isNotEmpty == true ? parent!.name[0].toUpperCase() : 'P',
              style: AppTextStyles.h2.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parent?.name ?? l10n.guardian, style: AppTextStyles.h3.copyWith(color: Colors.white)),
                Text(parent?.phone ?? l10n.noPhoneLinked, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                Text(parent?.email ?? l10n.noEmailLinked, style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {}, // Navigate to edit
          ),
        ],
      ),
    );
  }

  Widget _buildBabyList(BuildContext context, List<Child> babies, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.childProfiles, style: AppTextStyles.subheading1.copyWith(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => context.push(RouteConstants.babyProfile),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addNew),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        if (babies.isEmpty)
          Center(child: Text(l10n.noChildrenYet))
        else
          ...babies.map((baby) => _buildBabyCard(context, baby, l10n)),
      ],
    );
  }

  Widget _buildBabyCard(BuildContext context, Child baby, AppLocalizations l10n) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
        leading: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.child_care_rounded, color: AppColors.primary),
        ),
        title: Text(baby.name, style: AppTextStyles.subheading2.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(l10n.ageMonths(baby.ageMonths), style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push(RouteConstants.childDetail),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthProvider auth, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.appSettingsLabel, style: AppTextStyles.subheading1.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.s),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildSettingTile(Icons.language_rounded, l10n.languagePreference, l10n.changeAppLanguage),
              const Divider(height: 1),
              _buildSettingTile(Icons.notifications_outlined, l10n.notifications, l10n.manageAlerts),
              const Divider(height: 1),
              _buildSettingTile(Icons.security_rounded, l10n.privacySecurity, l10n.manageData),
              const Divider(height: 1),
              _buildSettingTile(
                Icons.logout_rounded, 
                l10n.logout, 
                l10n.signOutAccount, 
                color: AppColors.error,
                onTap: () async {
                  await auth.logout();
                  if (context.mounted) {
                    context.go(RouteConstants.roleSelection);
                  }
                }
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(title, style: AppTextStyles.bodyLarge.copyWith(color: color, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}
