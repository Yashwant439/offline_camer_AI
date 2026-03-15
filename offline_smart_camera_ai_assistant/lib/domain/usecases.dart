import 'entities.dart';
import 'repositories.dart';

class DetectObjectsUseCase {
  DetectObjectsUseCase(this._visionRepository);

  final VisionRepository _visionRepository;

  Future<List<DetectedObject>> call(String imagePath) {
    return _visionRepository.detectObjects(imagePath);
  }
}

class GetKnowledgeUseCase {
  GetKnowledgeUseCase(this._knowledgeRepository);

  final KnowledgeRepository _knowledgeRepository;

  Future<KnowledgeEntry?> call(String name) {
    return _knowledgeRepository.findByName(name);
  }
}

class AnswerQuestionUseCase {
  AnswerQuestionUseCase(this._llmRepository);

  final LlmRepository _llmRepository;

  Future<String> call({
    required ConversationContext context,
    required String question,
  }) {
    return _llmRepository.answerQuestion(context: context, question: question);
  }
}
