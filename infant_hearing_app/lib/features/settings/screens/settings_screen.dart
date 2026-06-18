import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:infant_hearing_app/features/baby/providers/baby_provider.dart';
import 'package:infant_hearing_app/features/auth/widgets/language_settings_widget.dart';
import 'package:infant_hearing_app/shared/widgets/app_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusL)),
        title: Text(l10n.logout, style: AppTextStyles.h3),
        content: Text(l10n.areYouSureLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.logout, style: AppTextStyles.button.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final parentProvider = context.read<ParentProvider>();
    final babyProvider = context.read<BabyProvider>();
    final authProvider = context.read<AuthProvider>();

    await parentProvider.clearParent();
    await babyProvider.clearBaby();
    await authProvider.logout();

    if (mounted) {
      context.go(RouteConstants.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          _buildSettingsGroup(
            l10n.preferences.toUpperCase(),
            [
              const LanguageSettingsWidget(),
              SwitchListTile(
                title: Text(l10n.notifications, style: AppTextStyles.subheading2),
                secondary: const Icon(Icons.notifications_none_outlined, color: AppColors.primary, size: 22),
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          _buildSettingsGroup(
            l10n.accountLabel.toUpperCase(),
            [
              _SettingsTile(
                icon: Icons.person_outline,
                label: l10n.editProfile,
                onTap: () => context.push(RouteConstants.profile),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          _buildSettingsGroup(
            l10n.aboutLabel.toUpperCase(),
            [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  children: [
                    _InfoRow(label: l10n.appLabel,     value: l10n.appName),
                    _InfoRow(label: l10n.partnerLabel, value: 'JNMC Audiology'),
                    _InfoRow(label: l10n.versionLabel, value: '1.0.0'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          TextButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: Text(l10n.logout, style: AppTextStyles.button.copyWith(color: AppColors.error)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              backgroundColor: AppColors.error.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusM)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.s),
          child: Text(
            title,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: AppTextStyles.subheading2),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
      onTap: onTap,
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.subheading2.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
