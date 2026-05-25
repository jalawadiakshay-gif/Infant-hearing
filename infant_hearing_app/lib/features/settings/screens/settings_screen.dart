import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusL)),
        title: Text('Logout', style: AppTextStyles.h3),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout', style: AppTextStyles.button.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<ParentProvider>().clearParent();
    await context.read<BabyProvider>().clearBaby();
    await context.read<AuthProvider>().logout();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteConstants.phoneLogin,
      (route) => false,
    );
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
            'PREFERENCES',
            [
              const LanguageSettingsWidget(),
              SwitchListTile(
                title: Text('Notifications', style: AppTextStyles.subheading2),
                secondary: const Icon(Icons.notifications_none_outlined, color: AppColors.primary, size: 22),
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          _buildSettingsGroup(
            'ACCOUNT',
            [
              _SettingsTile(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () => Navigator.pushNamed(context, RouteConstants.profile),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          _buildSettingsGroup(
            'ABOUT',
            [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.m),
                child: Column(
                  children: [
                    _InfoRow(label: 'App',     value: 'Baalshravya'),
                    _InfoRow(label: 'Partner', value: 'JNMC Audiology'),
                    _InfoRow(label: 'Version', value: '1.0.0'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          TextButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: Text('Logout', style: AppTextStyles.button.copyWith(color: AppColors.error)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              backgroundColor: AppColors.error.withOpacity(0.05),
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
