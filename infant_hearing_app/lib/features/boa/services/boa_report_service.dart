import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/boa_models.dart';

class BoaReportService {
  Future<void> generateAndShareReport({
    required String babyName,
    required String age,
    required String screeningId,
    required BoaOutcome outcome,
    required List<BoaTrial> trials,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Baalshravya', style: pw.TextStyle(font: fontBold, fontSize: 24, color: PdfColors.blue900)),
                      pw.Text('Early Infant Hearing Detection System', style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('SCREENING REPORT', style: pw.TextStyle(font: fontBold, fontSize: 14)),
                      pw.Text('Date: ${DateTime.now().toLocal().toString().split(' ')[0]}', style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.blue900),
              pw.SizedBox(height: 20),

              // Patient Info
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  children: [
                    _buildReportRow('Infant Name', babyName, font, fontBold),
                    _buildReportRow('Age', age, font, fontBold),
                    _buildReportRow('Screening ID', screeningId, font, fontBold),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),

              // Outcome
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: _getOutcomeColor(outcome),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                  ),
                  child: pw.Text(
                    outcome.label.toUpperCase(),
                    style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColors.white),
                  ),
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Text('Clinical Summary:', style: pw.TextStyle(font: fontBold, fontSize: 12)),
              pw.Text(outcome.explanation, style: pw.TextStyle(font: font, fontSize: 11)),
              pw.SizedBox(height: 25),

              // Trials Table
              pw.Text('Audio Response Details:', style: pw.TextStyle(font: fontBold, fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Stimulus (dB HL)', fontBold),
                      _buildTableCell('Frequency', fontBold),
                      _buildTableCell('Response', fontBold),
                      _buildTableCell('Type', fontBold),
                    ],
                  ),
                  ...trials.map((t) => pw.TableRow(
                    children: [
                      _buildTableCell(t.dbLevel.label, font),
                      _buildTableCell(t.frequency.label, font),
                      _buildTableCell(t.response.label, font),
                      _buildTableCell(t.isCatchTrial ? 'Catch Trial' : 'Clinical Trial', font),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 30),

              // Recommendations
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Recommended Action:', style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.blue900)),
                    pw.SizedBox(height: 5),
                    pw.Text(outcome.recommendation, style: pw.TextStyle(font: font, fontSize: 11)),
                  ],
                ),
              ),

              pw.Spacer(),
              pw.Divider(color: PdfColors.grey300),
              pw.Center(
                child: pw.Text(
                  'This is an AI-assisted screening report. Please consult a qualified audiologist for formal diagnosis.',
                  style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Baalshravya_Report_$babyName.pdf');
  }

  pw.Widget _buildReportRow(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 100, child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700))),
          pw.Text(': ', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9)),
    );
  }

  PdfColor _getOutcomeColor(BoaOutcome outcome) {
    switch (outcome) {
      case BoaOutcome.favorableHearingResponse: return PdfColors.green700;
      case BoaOutcome.monitor: return PdfColors.orange700;
      case BoaOutcome.suspectedHearingLoss: return PdfColors.red700;
    }
  }
}
