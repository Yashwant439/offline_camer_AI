import '../ai/runanywhere_service.dart';
import '../ai/vision_engine.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'local_data_source.dart';

class KnowledgeRepositoryImpl implements KnowledgeRepository {
  KnowledgeRepositoryImpl(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  Future<KnowledgeEntry?> findByName(String name) {
    return _localDataSource.getKnowledgeByName(name);
  }

  @override
  Future<List<KnowledgeEntry>> search(String query) {
    return _localDataSource.search(query);
  }
}

class ConversationRepositoryImpl implements ConversationRepository {
  ConversationRepositoryImpl(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  Future<void> saveSession(DetectionSession session) {
    return _localDataSource.saveSession(session);
  }

  @override
  Future<List<DetectionSession>> loadSessions() {
    return _localDataSource.loadSessions();
  }

  @override
  Future<void> saveMessage(ChatMessage message) {
    return _localDataSource.saveMessage(message);
  }

  @override
  Future<List<ChatMessage>> loadMessages(String sessionId) {
    return _localDataSource.loadMessages(sessionId);
  }
}

class VisionRepositoryImpl implements VisionRepository {
  VisionRepositoryImpl(this._visionEngine, this._knowledgeRepository);

  final VisionEngine _visionEngine;
  final KnowledgeRepository _knowledgeRepository;
  static final Map<String, List<DetectedObject>> _cache = {};

  @override
  Future<List<DetectedObject>> detectObjects(String imagePath) async {
    final cached = _cache[imagePath];
    if (cached != null) {
      return cached;
    }
    final detections = await _visionEngine.detectObjects(imagePath);
    final enriched = <DetectedObject>[];
    for (final detection in detections) {
      final knowledge = await _knowledgeRepository.findByName(detection.name);
      enriched.add(detection.copyWith(knowledge: knowledge));
    }
    _cache[imagePath] = enriched;
    return enriched;
  }
}

class LlmRepositoryImpl implements LlmRepository {
  LlmRepositoryImpl(this._runAnywhereService);

  final RunAnywhereService _runAnywhereService;

  @override
  Future<String> answerQuestion({
    required ConversationContext context,
    required String question,
  }) {
    return _runAnywhereService.generateAnswer(
      context: context,
      question: question,
    );
  }
}
