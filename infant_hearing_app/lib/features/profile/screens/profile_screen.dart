import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:infant_hearing_app/features/baby/providers/baby_provider.dart';
import 'package:infant_hearing_app/shared/widgets/app_card.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/data/models/v2/child.dart';
import 'package:infant_hearing_app/data/models/v2/app_user.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';
import 'package:infant_hearing_app/data/services/v2/app_firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ── Edit Profile ─────────────────────────────────────────────────────────────

  static Future<void> _showEditProfileSheet(
    BuildContext context,
    AppUser? user,
    AppFirestoreService firestore,
  ) async {
    if (user == null) return;
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final emailCtrl = TextEditingController(text: user.email ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Edit Profile', style: AppTextStyles.h3),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      prefixText: '+91 ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email (optional)',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() => saving = true);
                              try {
                                final updated = user.copyWith(
                                  name: nameCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                  email: emailCtrl.text.trim().isEmpty
                                      ? null
                                      : emailCtrl.text.trim(),
                                );
                                await firestore.saveUser(updated);
                                if (ctx.mounted) Navigator.pop(ctx, true);
                              } catch (e) {
                                setModalState(() => saving = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(content: Text('Save failed: $e'), backgroundColor: AppColors.error),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Language Picker ───────────────────────────────────────────────────────────

  static Future<void> _showLanguagePicker(BuildContext context) async {
    const langs = {
      'en': 'English',
      'hi': 'हिन्दी (Hindi)',
      'mr': 'मराठी (Marathi)',
      'kn': 'ಕನ್ನಡ (Kannada)',
    };
    final prefs = await SharedPreferences.getInstance();
    final currentLang = prefs.getString('lang') ?? 'en';

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Language / भाषा'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: langs.entries.map((e) => RadioListTile<String>(
            value: e.key,
            // ignore: deprecated_member_use
            groupValue: currentLang,
            title: Text(e.value),
            // ignore: deprecated_member_use
            onChanged: (v) async {
              if (v != null) {
                await prefs.setString('lang', v);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language saved. Restart the app to apply.'), duration: Duration(seconds: 3)),
                  );
                }
              }
            },
          )).toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      ),
    );
  }

  // ── Notifications Toggle ───────────────────────────────────────────────────────

  static Future<void> _showNotificationsDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool notifEnabled = prefs.getBool('notifications_enabled') ?? true;
    bool reminderEnabled = prefs.getBool('notifications_reminder') ?? true;

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Notification Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                value: notifEnabled,
                title: const Text('Push Notifications'),
                subtitle: const Text('Screening alerts & updates'),
                onChanged: (v) async {
                  setDialogState(() => notifEnabled = v);
                  await prefs.setBool('notifications_enabled', v);
                },
              ),
              SwitchListTile(
                value: reminderEnabled,
                title: const Text('Follow-up Reminders'),
                subtitle: const Text('Reminders for upcoming screenings'),
                onChanged: (v) async {
                  setDialogState(() => reminderEnabled = v);
                  await prefs.setBool('notifications_reminder', v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            )
          ],
        ),
      ),
    );
  }

  // ── Privacy & Security ────────────────────────────────────────────────────────

  static void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data Storage', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('All infant data is stored securely in Firebase Firestore with end-to-end encryption. Data is never shared with third parties.'),
              SizedBox(height: 14),
              Text('Recording Policy', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('BOA test videos are stored locally on your device under Documents/BaalshravyaVideos/ and optionally uploaded to Firebase Storage for ML training. You can delete local recordings at any time.'),
              SizedBox(height: 14),
              Text('Account Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('To delete your account and all associated data, contact support at baalshravya@jnmc.in.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parent = context.watch<ParentProvider>().parent;
    final babyProvider = context.watch<BabyProvider>();
    final babies = babyProvider.babies;
    final authProvider = context.read<AuthProvider>();
    final firestoreService = authProvider.firestoreService;
    final currentUser = authProvider.currentUserProfile;

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
            // ── Parent Header ─────────────────────────────────────────────────
            _buildParentHeader(context, parent, currentUser, firestoreService, l10n),
            const SizedBox(height: AppSpacing.xl),

            // ── Baby Profiles ─────────────────────────────────────────────────
            _buildBabyList(context, babies, l10n),
            const SizedBox(height: AppSpacing.xl),

            // ── App Settings ──────────────────────────────────────────────────
            _buildSettingsSection(context, authProvider, l10n),
            const SizedBox(height: AppSpacing.xxxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildParentHeader(
    BuildContext context,
    parent,
    AppUser? currentUser,
    AppFirestoreService firestoreService,
    AppLocalizations l10n,
  ) {
    final displayName = currentUser?.name.isNotEmpty == true
        ? currentUser!.name
        : (parent?.name ?? l10n.guardian);
    final displayPhone = currentUser?.phone ?? parent?.phone ?? l10n.noPhoneLinked;
    final displayEmail = currentUser?.email ?? parent?.email ?? l10n.noEmailLinked;

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
              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
              style: AppTextStyles.h2.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(displayPhone,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white.withValues(alpha: 0.9))),
                Text(displayEmail,
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit Profile',
            onPressed: () => _showEditProfileSheet(context, currentUser, firestoreService),
          ),
        ],
      ),
    );
  }

  Widget _buildBabyList(
      BuildContext context, List<Child> babies, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.childProfiles,
                style: AppTextStyles.subheading1
                    .copyWith(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => context.push(RouteConstants.babyProfile),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addNew),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        if (babies.isEmpty)
          _EmptyChildren(l10n: l10n)
        else
          ...babies.asMap().entries
              .map((e) => _buildBabyCard(context, e.value, e.key, l10n)),
      ],
    );
  }

  Widget _buildBabyCard(
      BuildContext context, Child baby, int index, AppLocalizations l10n) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l, vertical: AppSpacing.s),
        leading: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.child_care_rounded, color: AppColors.primary),
        ),
        title: Text(baby.name,
            style: AppTextStyles.subheading2.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ageMonths(baby.ageMonths), style: AppTextStyles.caption),
            // ── Human-readable child ID with copy button ──────────────────
            if (baby.childCode != null)
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      baby.childCode!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    color: AppColors.primary,
                    padding: const EdgeInsets.only(left: 6),
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy Child ID',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: baby.childCode!));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ID copied: ${baby.childCode}'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push(
          RouteConstants.childDetail,
          extra: {'childId': baby.childId, 'index': index},
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
      BuildContext context, AuthProvider auth, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.appSettingsLabel,
            style:
                AppTextStyles.subheading1.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.s),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildSettingTile(
                Icons.language_rounded,
                l10n.languagePreference,
                l10n.changeAppLanguage,
                onTap: () => _showLanguagePicker(context),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                Icons.notifications_outlined,
                l10n.notifications,
                l10n.manageAlerts,
                onTap: () => _showNotificationsDialog(context),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                Icons.security_rounded,
                l10n.privacySecurity,
                l10n.manageData,
                onTap: () => _showPrivacyDialog(context),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                Icons.logout_rounded,
                l10n.logout,
                l10n.signOutAccount,
                color: AppColors.error,
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out?'),
                      content: const Text('You will be signed out of your account.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: AppColors.error),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await auth.logout();
                    if (context.mounted) context.go(RouteConstants.roleSelection);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    String subtitle, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: AppTextStyles.bodyLarge
              .copyWith(color: color, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: Icon(Icons.chevron_right_rounded,
          size: 20, color: color ?? AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyChildren extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyChildren({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.child_care_rounded, size: 48, color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.s),
          Text(
            l10n.noChildrenYet,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s),
          TextButton.icon(
            onPressed: () => context.push(RouteConstants.babyProfile),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Child Profile'),
          ),
        ],
      ),
    );
  }
}
