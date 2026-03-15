import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';

import '../security/secure_key_service.dart';

class HiveStore {
  HiveStore(this._secureKeyService);

  final SecureKeyService _secureKeyService;

  late Box<Map> knowledgeBox;
  late Box<Map> sessionBox;
  late Box<Map> messageBox;

  Future<void> init() async {
    await Hive.initFlutter();
    final key = await _secureKeyService.ensureKey();
    final cipher = HiveAesCipher(Uint8List.fromList(key));

    knowledgeBox = await Hive.openBox<Map>('knowledge', encryptionCipher: cipher);
    sessionBox = await Hive.openBox<Map>('sessions', encryptionCipher: cipher);
    messageBox = await Hive.openBox<Map>('messages', encryptionCipher: cipher);
  }
}
