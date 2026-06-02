import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/memory.dart';

/// Renders the bonding memories into a warm, printable keepsake PDF — entirely
/// on-device (the `pdf` package builds bytes; nothing leaves). Sorted
/// oldest-first so it reads as a journey.
///
/// Pass [fontData] (the bundled Plus Jakarta Sans) to embed a Unicode font so
/// names/notes with accents or smart quotes render; without it, the built-in
/// Helvetica is used (ASCII only). The template itself stays ASCII either way.
abstract final class KeepsakePdf {
  static const _rose = PdfColor.fromInt(0xFFB0506A);

  static Future<Uint8List> build(
    List<Memory> memories, {
    String? babyName,
    ByteData? fontData,
  }) async {
    final sorted = [...memories]
      ..sort((a, b) => a.occurredOn.compareTo(b.occurredOn));
    final fmt = DateFormat.yMMMMd();
    final doc = pw.Document();

    final theme = fontData != null
        ? pw.ThemeData.withFont(base: pw.Font.ttf(fontData))
        : null;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: theme,
        build: (context) => [
          pw.Text(
            babyName == null ? 'Our journey' : 'Our journey with $babyName',
            style: pw.TextStyle(
              fontSize: 28,
              color: _rose,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(color: _rose, thickness: 1),
          pw.SizedBox(height: 12),
          if (sorted.isEmpty)
            pw.Text('No memories saved yet.')
          else
            for (final m in sorted) _entry(m, fmt),
          pw.SizedBox(height: 24),
          pw.Text(
            'Made with Linnet. Kept private, just for you.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _entry(Memory m, DateFormat fmt) {
    final isLetter = m.kind == MemoryKind.letter;
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${fmt.format(m.occurredOn)}  -  ${m.title}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          if (m.body != null && m.body!.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text(
                m.body!.trim(),
                style: pw.TextStyle(
                  fontSize: 11,
                  fontStyle: isLetter
                      ? pw.FontStyle.italic
                      : pw.FontStyle.normal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
