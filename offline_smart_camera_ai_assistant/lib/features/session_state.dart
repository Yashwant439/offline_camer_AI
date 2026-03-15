import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/image_utils.dart';
import '../ai/speech_service.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';

class SessionState {
  const SessionState({
    this.session,
    this.detections = const [],
    this.messages = const [],
    this.isBusy = false,
    this.error,
  });

  final DetectionSession? session;
  final List<DetectedObject> detections;
  final List<ChatMessage> messages;
  final bool isBusy;
  final String? error;

  SessionState copyWith({
    DetectionSession? session,
    List<DetectedObject>? detections,
    List<ChatMessage>? messages,
    bool? isBusy,
    String? error,
  }) {
    return SessionState(
      session: session ?? this.session,
      detections: detections ?? this.detections,
      messages: messages ?? this.messages,
      isBusy: isBusy ?? this.isBusy,
      error: error,
    );
  }
}

class SessionController extends StateNotifier<SessionState> {
  SessionController(
    this._visionRepository,
    this._knowledgeRepository,
    this._conversationRepository,
    this._llmRepository,
    this._speechService,
  ) : super(const SessionState());

  final VisionRepository _visionRepository;
  final KnowledgeRepository _knowledgeRepository;
  final ConversationRepository _conversationRepository;
  final LlmRepository _llmRepository;
  final SpeechService _speechService;

  final _uuid = const Uuid();

  Future<void> detectImage(String imagePath) async {
    state = state.copyWith(isBusy: true, error: null);
    try {
      await ImageUtils.validateImageFile(imagePath);
      final detections = await _visionRepository.detectObjects(imagePath);
      final top = detections.isNotEmpty
          ? detections.first
          : DetectedObject(
              name: 'Unknown Object',
              confidence: 0,
              boundingBox: BoundingBox.full(),
            );

      final session = DetectionSession(
        id: _uuid.v4(),
        imagePath: imagePath,
        objectName: top.name,
        confidence: top.confidence,
        createdAt: DateTime.now(),
      );
      await _conversationRepository.saveSession(session);

      state = state.copyWith(
        session: session,
        detections: detections,
        messages: const [],
        isBusy: false,
      );
    } catch (error) {
      state = state.copyWith(isBusy: false, error: error.toString());
    }
  }

  Future<void> askQuestion(String question) async {
    final session = state.session;
    if (session == null) return;
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      sessionId: session.id,
      role: ChatRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );
    await _conversationRepository.saveMessage(userMessage);
    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(messages: updatedMessages, isBusy: true, error: null);

    try {
      final knowledge =
          await _knowledgeRepository.findByName(state.session?.objectName ?? '');
      final context = ConversationContext(
        objectName: session.objectName,
        knowledge: knowledge,
        messages: updatedMessages,
      );
      final answer =
          await _llmRepository.answerQuestion(context: context, question: trimmed);

      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        sessionId: session.id,
        role: ChatRole.assistant,
        content: answer,
        createdAt: DateTime.now(),
      );
      await _conversationRepository.saveMessage(assistantMessage);
      state = state.copyWith(
        messages: [...updatedMessages, assistantMessage],
        isBusy: false,
      );

      if (_speechService.autoSpeak) {
        await _speechService.speak(answer);
      }
    } catch (error) {
      state = state.copyWith(isBusy: false, error: error.toString());
    }
  }

  Future<void> loadSession(DetectionSession session) async {
    final messages = await _conversationRepository.loadMessages(session.id);
    final knowledge = await _knowledgeRepository.findByName(session.objectName);
    final detection = DetectedObject(
      name: session.objectName,
      confidence: session.confidence,
      boundingBox: BoundingBox.full(),
      knowledge: knowledge,
    );
    state = state.copyWith(
      session: session,
      detections: [detection],
      messages: messages,
      isBusy: false,
      error: null,
    );
  }

  void reset() {
    state = const SessionState();
  }
}
