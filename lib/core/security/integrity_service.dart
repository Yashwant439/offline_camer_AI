import 'dart:io';

import 'package:crypto/crypto.dart';

class IntegrityService {
  Future<String> sha256File(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  Future<bool> verifySha256(File file, String expected) async {
    if (!await file.exists()) {
      return false;
    }
    final digest = await sha256File(file);
    return digest.toLowerCase() == expected.toLowerCase();
  }
}