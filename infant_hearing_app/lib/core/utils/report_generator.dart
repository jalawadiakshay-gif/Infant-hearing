import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/asha/models/boa_result_model.dart';

class ReportGenerator {
  static Future<Uint8List> generateBoaReport(BoaResultModel result) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('BAALSHRAVYA — Clinical Report', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                    pw.Text('Date: ${result.testedAt.toString().split(' ')[0]}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Infant Name: ${result.infantName}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('ASHA ID: ${result.ashaId}'),
              pw.SizedBox(height: 20),
              pw.Text('BOA Screening Results', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildResultRow('Left Ear', result.leftEar.label),
              _buildResultRow('Right Ear', result.rightEar.label),
              pw.SizedBox(height: 20),
              if (result.notes != null) ...[
                pw.Text('Clinical Notes:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(result.notes!),
              ],
              pw.Spacer(),
              pw.Divider(),
              pw.Text('This is a computer-generated screening report. Further diagnostic evaluation (OAE/ABR) is recommended if responses are absent.',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildResultRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: value == 'Present' ? PdfColors.green : PdfColors.red)),
        ],
      ),
    );
  }
}
