import 'entities.dart';

abstract class VisionRepository {
  Future<List<DetectedObject>> detectObjects(String imagePath);
}

abstract class KnowledgeRepository {
  Future<KnowledgeEntry?> findByName(String name);
  Future<List<KnowledgeEntry>> search(String query);
}

abstract class ConversationRepository {
  Future<void> saveSession(DetectionSession session);
  Future<List<DetectionSession>> loadSessions();
  Future<void> saveMessage(ChatMessage message);
  Future<List<ChatMessage>> loadMessages(String sessionId);
}

abstract class LlmRepository {
  Future<String> answerQuestion({
    required ConversationContext context,
    required String question,
  });
}
