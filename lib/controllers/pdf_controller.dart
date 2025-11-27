import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';

class PdfController extends GetxController {
  final cards = <Map<String, String>>[].obs;
  final loading = false.obs;

  Future<void> pickAndSummarize() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (picked == null) return;

    loading.value = true;

    final file = File(picked.files.single.path!);
    final name = picked.files.single.name;

    // Upload
    final url = await StorageService.uploadPdf(file, 'user_$userId/$name');

    // Extract first 5-6 pages
    final text = await PdfService.extractText(file, maxPages: 6);

    // TODO: Call your Edge Function / AI API with `text` for real summaries.
    // Demo placeholders:
    final demo = [
      {
        'title': 'Key Concepts',
        'summary':
            'This PDF covers core ideas summarised into concise bullets for quick revision.',
      },
      {
        'title': 'Important Points',
        'summary':
            'Remember definitions, trade-offs, and typical examples used in interviews.',
      },
      {
        'title': 'Action Items',
        'summary': 'Revisit tricky areas and test yourself with flashcards.',
      },
    ];
    cards.assignAll(demo);

    await client.from('summaries').insert({
      'user_id': userId,
      'pdf_name': name,
      'pdf_url': url,
      'summary_json': demo,
    });

    loading.value = false;
  }
}
