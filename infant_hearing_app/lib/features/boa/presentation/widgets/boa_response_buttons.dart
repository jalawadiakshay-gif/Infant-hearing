import 'package:flutter/material.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import '../../domain/boa_models.dart';

class BoaResponseButtons extends StatelessWidget {
  final Function(BoaResponse) onResponse;

  const BoaResponseButtons({super.key, required this.onResponse});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.boaResponse.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.m),
        _ResponseButton(
          label: l10n.yes,
          description: l10n.aiEyeBlink, // Using existing keys for descriptions
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.success,
          onTap: () => onResponse(BoaResponse.responseDetected),
        ),
        const SizedBox(height: AppSpacing.s),
        _ResponseButton(
          label: l10n.no,
          description: l10n.boaNoResponse,
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          onTap: () => onResponse(BoaResponse.noResponse),
        ),
        const SizedBox(height: AppSpacing.s),
        _ResponseButton(
          label: l10n.boaUncertain,
          description: '',
          icon: Icons.help_outline_rounded,
          color: AppColors.warning,
          onTap: () => onResponse(BoaResponse.uncertain),
        ),
      ],
    );
  }
}

class _ResponseButton extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ResponseButton({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Record infant response: $label',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTextStyles.subheading1.copyWith(color: color)),
                    if (description.isNotEmpty)
                      Text(description, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: color.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
