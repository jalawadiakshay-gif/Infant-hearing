import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/v2/screening.dart';
import '../../data/models/v2/child.dart';

class ReportGenerator {
  static Future<Uint8List> generateBoaReport(Child child, Screening screening) async {
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
                    pw.Text('Date: ${screening.date.toString().split(' ')[0]}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Infant Name: ${child.name}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('Conducted By: ${screening.conductedBy}'),
              pw.SizedBox(height: 20),
              pw.Text('BOA Screening Results', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildResultRow('Outcome', screening.boaOutcome ?? 'Unknown'),
              pw.SizedBox(height: 20),
              pw.Spacer(),
              pw.Divider(),
              pw.Text('This is a computer-generated screening report. Further diagnostic evaluation (OAE/ABR) is recommended if responses are absent.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
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
