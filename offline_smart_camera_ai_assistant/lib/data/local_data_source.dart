import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/storage/hive_store.dart';
import '../domain/entities.dart';

class LocalDataSource {
  LocalDataSource(this._store);

  final HiveStore _store;

  Future<void> seedKnowledgeIfEmpty() async {
    if (_store.knowledgeBox.isNotEmpty) {
      return;
    }
    final jsonString = await rootBundle.loadString('assets/db/objects_seed.json');
    final List<dynamic> data = json.decode(jsonString) as List<dynamic>;
    for (final item in data) {
      final map = Map<String, dynamic>.from(item as Map);
      final entry = KnowledgeEntry.fromMap(map);
      await _store.knowledgeBox.put(entry.name.toLowerCase(), entry.toMap());
    }
  }

  Future<KnowledgeEntry?> getKnowledgeByName(String name) async {
    final map = _store.knowledgeBox.get(name.toLowerCase());
    if (map == null) {
      return null;
    }
    return KnowledgeEntry.fromMap(Map<String, dynamic>.from(map));
  }

  Future<List<KnowledgeEntry>> search(String query) async {
    final lower = query.toLowerCase();
    final results = <KnowledgeEntry>[];
    for (final map in _store.knowledgeBox.values) {
      final entry = KnowledgeEntry.fromMap(Map<String, dynamic>.from(map));
      if (entry.name.toLowerCase().contains(lower) ||
          entry.category.toLowerCase().contains(lower)) {
        results.add(entry);
      }
    }
    return results;
  }

  Future<void> saveSession(DetectionSession session) async {
    await _store.sessionBox.put(session.id, session.toMap());
  }

  Future<List<DetectionSession>> loadSessions() async {
    return _store.sessionBox.values
        .map((map) => DetectionSession.fromMap(Map<String, dynamic>.from(map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveMessage(ChatMessage message) async {
    await _store.messageBox.put(message.id, message.toMap());
  }

  Future<List<ChatMessage>> loadMessages(String sessionId) async {
    final messages = _store.messageBox.values
        .map((map) => ChatMessage.fromMap(Map<String, dynamic>.from(map)))
        .where((message) => message.sessionId == sessionId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }
}
