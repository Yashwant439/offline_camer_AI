import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyService {
  static const _keyName = 'hive_aes_key';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Uint8List> ensureKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) {
      return base64Url.decode(existing);
    }
    final key = _generateKey();
    await _storage.write(key: _keyName, value: base64Url.encode(key));
    return key;
  }

  Uint8List _generateKey() {
    final rand = Random.secure();
    return Uint8List.fromList(List<int>.generate(32, (_) => rand.nextInt(256)));
  }
}
