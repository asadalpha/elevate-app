import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static Future<String> uploadPdf(File file, String path) async {
    final client = Supabase.instance.client;
    await client.storage.from('pdfs').upload(path, file, fileOptions: const FileOptions(upsert: true));
    return client.storage.from('pdfs').getPublicUrl(path);
  }
}
