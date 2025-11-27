import 'dart:io';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';

class PdfService {
  static Future<String> extractText(File file, {int maxPages = 6}) async {
    final doc = await PDFDoc.fromFile(file);
    final pages = doc.length < maxPages ? doc.length : maxPages;
    var text = '';
    for (int i = 1; i <= pages; i++) {
      text += await doc.pageAt(i).text;
      text += '\n';
    }
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length > 6000) text = text.substring(0, 6000); // sanity cap
    return text;
  }
}
