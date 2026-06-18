import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

enum ReportSelectionType { parent, clinical }

class ReportTypeSelectionDialog extends StatefulWidget {
  final bool isAshaDefault;
  const ReportTypeSelectionDialog({super.key, required this.isAshaDefault});

  static Future<ReportSelectionType?> show(BuildContext context, {required bool isAshaDefault}) {
    return showDialog<ReportSelectionType>(
      context: context,
      builder: (context) => ReportTypeSelectionDialog(isAshaDefault: isAshaDefault),
    );
  }

  @override
  State<ReportTypeSelectionDialog> createState() => _ReportTypeSelectionDialogState();
}

class _ReportTypeSelectionDialogState extends State<ReportTypeSelectionDialog> {
  late ReportSelectionType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.isAshaDefault ? ReportSelectionType.clinical : ReportSelectionType.parent;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.pdfSelectReportType, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      content: RadioGroup<ReportSelectionType>(
        groupValue: _selectedType,
        onChanged: (val) {
          if (val != null) setState(() => _selectedType = val);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ReportSelectionType>(
              title: Text('${l10n.pdfParentScreeningReport} (${l10n.pdfRecommendedLabel})', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(l10n.pdfParentReportDesc),
              value: ReportSelectionType.parent,
              activeColor: theme.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            RadioListTile<ReportSelectionType>(
              title: Text(l10n.pdfClinicalScreeningReport, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(l10n.pdfClinicalReportDesc),
              value: ReportSelectionType.clinical,
              activeColor: theme.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedType),
          child: Text(l10n.downloadReport),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
