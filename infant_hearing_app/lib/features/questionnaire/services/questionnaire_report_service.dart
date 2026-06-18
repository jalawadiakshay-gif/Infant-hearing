import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/questionnaire_models.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';

enum ReportType { parent, clinical }

class QuestionnaireReportService {
  late pw.Font _fontRegular;
  late pw.Font _fontBold;
  late List<pw.Font> _fontFallbacks;

  Future<void> _initFonts() async {
    _fontRegular = await PdfGoogleFonts.notoSansRegular();
    _fontBold = await PdfGoogleFonts.notoSansBold();
    _fontFallbacks = [
      await PdfGoogleFonts.notoSansDevanagariRegular(),
      await PdfGoogleFonts.notoSansKannadaRegular(),
    ];
  }

  pw.TextStyle _textStyle({
    bool isBold = false,
    double fontSize = 10,
    PdfColor color = PdfColors.black,
  }) {
    return pw.TextStyle(
      font: isBold ? _fontBold : _fontRegular,
      fontFallback: _fontFallbacks,
      fontSize: fontSize,
      color: color,
    );
  }

  Future<pw.Document> _createDocument({
    required ReportType reportType,
    required String babyName,
    required String age,
    required String screeningId,
    required ScoringResult result,
    required List<QuestionnaireSection> sections,
    required Map<String, AnswerValue> answers,
    required String langCode,
    required AppLocalizations l10n,
  }) async {
    await _initFonts();
    final pdf = pw.Document();

    final theme = pw.ThemeData.withFont(
      base: _fontRegular,
      bold: _fontBold,
      fontFallback: _fontFallbacks,
    );

    final isClinical = reportType == ReportType.clinical;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(isClinical, l10n),
            pw.SizedBox(height: 20),
            _buildChildInfo(babyName, age, result.riskPercentage, screeningId, l10n),
            pw.SizedBox(height: 20),
            _buildOutcomeHeroCard(result.result, l10n),
            pw.SizedBox(height: 15),
            _buildRecommendation(result.result, l10n),
            pw.SizedBox(height: 20),
            _buildScreeningTimeline(l10n),
            pw.SizedBox(height: 20),
            _buildFollowUpActions(result.result, l10n),
            
            if (isClinical) ...[
              pw.SizedBox(height: 30),
              _buildClinicalSummary(result, sections, langCode, l10n),
              pw.SizedBox(height: 20),
              _buildDetailedResponses(sections, answers, langCode, l10n),
            ],

            pw.SizedBox(height: 30),
            _buildNoticeBox(l10n),
            pw.SizedBox(height: 20),
            _buildFooter(screeningId, isClinical, l10n),
          ];
        },
      ),
    );

    return pdf;
  }

  // _generateQrPayload removed

  pw.Widget _buildHeader(bool isClinical, AppLocalizations l10n) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Baalshravya', style: _textStyle(isBold: true, fontSize: 24, color: PdfColors.blue900)),
            pw.Text(l10n.pdfEarlyDetection, style: _textStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              isClinical ? l10n.pdfClinicalScreeningReport : l10n.pdfParentScreeningReport,
              style: _textStyle(isBold: true, fontSize: 14),
            ),
            pw.Text('${l10n.pdfGeneratedOn}: ${DateTime.now().toLocal().toString().split(' ')[0]}', style: _textStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildChildInfo(String name, String age, double riskPercentage, String screeningId, AppLocalizations l10n) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(l10n.pdfChildInformation, style: _textStyle(isBold: true, fontSize: 12, color: PdfColors.blue900)),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _infoRow(l10n.pdfChildName, name),
                  _infoRow(l10n.pdfAgeLabel, '$age ${l10n.pdfMonths}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _infoRow(l10n.pdfScreeningDate, DateTime.now().toLocal().toString().split(' ')[0]),
                  _infoRow(l10n.pdfScreeningId, screeningId),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 100, child: pw.Text(label, style: _textStyle(fontSize: 10, color: PdfColors.grey700))),
          pw.Text(': ', style: _textStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value, style: _textStyle(isBold: true, fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildOutcomeHeroCard(RiskResult result, AppLocalizations l10n) {
    PdfColor bgColor;
    PdfColor borderColor;
    PdfColor textColor;
    String title;

    switch (result) {
      case RiskResult.pass:
        bgColor = PdfColor.fromHex('#E8F5E9');
        borderColor = PdfColor.fromHex('#4CAF50');
        textColor = PdfColor.fromHex('#2E7D32');
        title = l10n.pdfScreeningPassed;
        break;
      case RiskResult.monitor:
        bgColor = PdfColor.fromHex('#FFF3E0');
        borderColor = PdfColor.fromHex('#FF9800');
        textColor = PdfColor.fromHex('#E65100');
        title = l10n.pdfMonitorFollowUp;
        break;
      case RiskResult.refer:
        bgColor = PdfColor.fromHex('#FFEBEE');
        borderColor = PdfColor.fromHex('#F44336');
        textColor = PdfColor.fromHex('#C62828');
        title = l10n.pdfFurtherEvaluation;
        break;
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: borderColor, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(l10n.pdfOverallResult.toUpperCase(), style: _textStyle(fontSize: 10, color: textColor)),
          pw.SizedBox(height: 5),
          pw.Text(title, style: _textStyle(isBold: true, fontSize: 18, color: textColor)),
        ],
      ),
    );
  }

  pw.Widget _buildRecommendation(RiskResult result, AppLocalizations l10n) {
    String text;
    switch (result) {
      case RiskResult.pass:
        text = l10n.pdfPassRecommendation;
        break;
      case RiskResult.monitor:
        text = '${l10n.pdfMonitorRecommendation1} ${l10n.pdfMonitorRecommendation2}';
        break;
      case RiskResult.refer:
        text = l10n.pdfReferRecommendation;
        break;
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(l10n.pdfRecommendation, style: _textStyle(isBold: true, fontSize: 12, color: PdfColors.blue900)),
          pw.SizedBox(height: 5),
          pw.Text(text, style: _textStyle(fontSize: 11)),
        ],
      ),
    );
  }

  pw.Widget _buildScreeningTimeline(AppLocalizations l10n) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(l10n.pdfScreeningTimeline, style: _textStyle(isBold: true, fontSize: 12, color: PdfColors.blue900)),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 5),
          _timelineRow(l10n.pdfPhase1Questionnaire, l10n.pdfTimelineCompleted, true),
          _timelineRow(l10n.pdfPhase2Boa, l10n.pdfTimelineNotStarted, false),
        ],
      ),
    );
  }

  pw.Widget _timelineRow(String title, String status, bool isCompleted) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: isCompleted ? PdfColors.green : PdfColors.grey400,
            ),
            child: pw.Center(
              child: isCompleted ? pw.Text('✓', style: _textStyle(fontSize: 8, color: PdfColors.white)) : pw.SizedBox(),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(title, style: _textStyle(fontSize: 10, isBold: isCompleted)),
          pw.Spacer(),
          pw.Text(status, style: _textStyle(fontSize: 10, color: isCompleted ? PdfColors.green700 : PdfColors.grey600)),
        ],
      ),
    );
  }

  pw.Widget _buildFollowUpActions(RiskResult result, AppLocalizations l10n) {
    List<String> actions = [];
    switch (result) {
      case RiskResult.pass:
        actions = [l10n.pdfContinueMonitoring];
        break;
      case RiskResult.monitor:
        actions = [l10n.pdfRepeatScreening1Month, l10n.pdfContinueMonitoring];
        break;
      case RiskResult.refer:
        actions = [l10n.pdfScheduleAudiology, l10n.pdfVisitJNMC];
        break;
    }

    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(l10n.pdfFollowUpActions, style: _textStyle(isBold: true, fontSize: 12, color: PdfColors.blue900)),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 5),
          ...actions.map((action) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Row(
              children: [
                pw.Text('• ', style: _textStyle(isBold: true, fontSize: 12, color: PdfColors.blue700)),
                pw.Text(action, style: _textStyle(fontSize: 11)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  pw.Widget _buildNoticeBox(AppLocalizations l10n) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFFDE7'),
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColor.fromHex('#FBC02D')),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('⚠ ', style: _textStyle(fontSize: 14, color: PdfColor.fromHex('#F57F17'))),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(l10n.pdfImportantNotice, style: _textStyle(isBold: true, fontSize: 10, color: PdfColor.fromHex('#F57F17'))),
                pw.SizedBox(height: 2),
                pw.Text(l10n.pdfDisclaimerText, style: _textStyle(fontSize: 9, color: PdfColors.grey800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(String screeningId, bool isClinical, AppLocalizations l10n) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Baalshravya ${l10n.appLabel}', style: _textStyle(isBold: true, fontSize: 9, color: PdfColors.grey600)),
            pw.Text('${l10n.pdfVersion} 1.0', style: _textStyle(fontSize: 8, color: PdfColors.grey500)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildClinicalSummary(ScoringResult result, List<QuestionnaireSection> sections, String langCode, AppLocalizations l10n) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(l10n.pdfClinicalSummary, style: _textStyle(isBold: true, fontSize: 14, color: PdfColors.blue900)),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(l10n.pdfRiskScoreLabel, style: _textStyle(fontSize: 11)),
            pw.Text('${result.riskPercentage.toStringAsFixed(1)}%', style: _textStyle(isBold: true, fontSize: 11)),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text(l10n.pdfCategoryBreakdown, style: _textStyle(isBold: true, fontSize: 12)),
        pw.SizedBox(height: 5),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(l10n.sectionLabel, style: _textStyle(isBold: true, fontSize: 10))),
                pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(l10n.pdfScorePercent, style: _textStyle(isBold: true, fontSize: 10), textAlign: pw.TextAlign.center)),
              ],
            ),
            ...sections.map((s) {
              final pct = result.sectionScores[s.index] ?? 0.0;
              return pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(s.localizedTitle(langCode), style: _textStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${pct.toStringAsFixed(0)}%', style: _textStyle(fontSize: 9), textAlign: pw.TextAlign.center)),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildDetailedResponses(List<QuestionnaireSection> sections, Map<String, AnswerValue> answers, String langCode, AppLocalizations l10n) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(l10n.pdfDetailedResponses, style: _textStyle(isBold: true, fontSize: 14, color: PdfColors.blue900)),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 10),
        ...sections.map((s) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                child: pw.Text(s.localizedTitle(langCode), style: _textStyle(isBold: true, fontSize: 10)),
              ),
              pw.SizedBox(height: 4),
              ...s.questions.map((q) {
                final answer = answers[q.id];
                final ansText = answer != null ? answer.localizedLabel(l10n) : 'N/A';
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(child: pw.Text(q.localizedText(langCode), style: _textStyle(fontSize: 9))),
                      pw.SizedBox(width: 10),
                      pw.SizedBox(width: 50, child: pw.Text(ansText, style: _textStyle(isBold: true, fontSize: 9), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 10),
            ],
          );
        }),
      ],
    );
  }

  Future<void> generateAndShareReport({
    required ReportType reportType,
    required String babyName,
    required String age,
    required String screeningId,
    required ScoringResult result,
    required List<QuestionnaireSection> sections,
    required Map<String, AnswerValue> answers,
    required String langCode,
    required AppLocalizations l10n,
  }) async {
    final pdf = await _createDocument(
      reportType: reportType,
      babyName: babyName,
      age: age,
      screeningId: screeningId,
      result: result,
      sections: sections,
      answers: answers,
      langCode: langCode,
      l10n: l10n,
    );

    final typeStr = reportType == ReportType.clinical ? 'Clinical' : 'Parent';
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Baalshravya_${typeStr}_Report_$babyName.pdf');
  }
}
