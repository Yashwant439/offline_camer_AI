import 'dart:typed_data';

import 'package:runanywhere/runanywhere.dart';
import 'package:runanywhere_llamacpp/runanywhere_llamacpp.dart';
import 'package:runanywhere_onnx/runanywhere_onnx.dart';

import '../core/security/integrity_service.dart';
import '../core/storage/model_storage.dart';
import '../domain/entities.dart';

class ModelConfig {
  const ModelConfig({
    required this.id,
    required this.name,
    required this.url,
    this.memoryRequirement,
    this.modality,
    this.localFileName,
    this.sha256,
  });

  final String id;
  final String name;
  final String url;
  final int? memoryRequirement;
  final ModelCategory? modality;
  final String? localFileName;
  final String? sha256;
}

class RunAnywhereService {
  static bool _initialized = false;
  static bool _modelsRegistered = false;

  static const ModelConfig llmModel = ModelConfig(
    id: 'tinyllama-q4',
    name: 'TinyLlama Q4',
    url: 'https://example.com/models/tinyllama-q4.gguf',
    memoryRequirement: 760,
    localFileName: 'tinyllama-q4.gguf',
    sha256: '',
  );

  static const ModelConfig sttModel = ModelConfig(
    id: 'whisper-tiny',
    name: 'Whisper Tiny ONNX',
    url: 'https://example.com/models/whisper-tiny.onnx',
    modality: ModelCategory.speechRecognition,
    localFileName: 'whisper-tiny.onnx',
    sha256: '',
  );

  static Future<void> initializeRuntime() async {
    if (_initialized) return;
    await RunAnywhere.initialize();
    await Onnx.register();
    await LlamaCpp.register();
    _initialized = true;
  }

  static Future<void> registerModels() async {
    if (_modelsRegistered) return;
    LlamaCpp.addModel(
      id: llmModel.id,
      name: llmModel.name,
      url: llmModel.url,
      memoryRequirement: llmModel.memoryRequirement ?? 760,
    );
    Onnx.addModel(
      sttModel.id,
      sttModel.url,
      modality: sttModel.modality ?? ModelCategory.speechRecognition,
    );
    _modelsRegistered = true;
  }

  Future<void> ensureModelsReady() async {
    await _verifyLocalModelIfConfigured(llmModel);
    await _verifyLocalModelIfConfigured(sttModel);
    await for (final _ in RunAnywhere.downloadModel(llmModel.id)) {}
    await RunAnywhere.loadModel(llmModel.id);
    await for (final _ in RunAnywhere.downloadModel(sttModel.id)) {}
    await RunAnywhere.loadModel(sttModel.id);
  }

  Future<String> generateAnswer({
    required ConversationContext context,
    required String question,
  }) async {
    final knowledge = context.knowledge;
    final knowledgeText = knowledge == null
        ? 'No local knowledge available.'
        : '''
Description: ${knowledge.description}
Category: ${knowledge.category}
Nutrition: ${knowledge.nutrition}
Growth tips: ${knowledge.growthTips}
Health info: ${knowledge.healthInfo}
Season: ${knowledge.season}
''';

    final history = context.messages.take(6).map((message) {
      final prefix = message.role == ChatRole.user ? 'User' : 'Assistant';
      return '$prefix: ${message.content}';
    }).join('\n');

    const systemPrompt = '''
You are an offline smart camera assistant. Use the detected object and local knowledge.
Be concise, practical, and honest about uncertainty. If you do not know, say so.
''';

    final prompt = '''
Detected object: ${context.objectName}
$knowledgeText
Conversation:
$history
User: $question
Assistant:
''';

    final options = LLMGenerationOptions(
      maxTokens: 240,
      temperature: 0.2,
      topP: 0.9,
      systemPrompt: systemPrompt,
    );

    final stream = RunAnywhere.generateStream(prompt, options: options);
    final buffer = StringBuffer();
    await for (final token in stream) {
      buffer.write(token);
    }
    return buffer.toString().trim();
  }

  Future<String> transcribe(Uint8List audioData) async {
    final result = await RunAnywhere.transcribe(audioData);
    return result.text.trim();
  }

  Future<void> _verifyLocalModelIfConfigured(ModelConfig config) async {
    if (config.localFileName == null || config.sha256 == null) return;
    if (config.sha256!.isEmpty) return;
    final file = await ModelStorage().resolveModelFile(config.localFileName!);
    final ok = await IntegrityService().verifySha256(file, config.sha256!);
    if (!ok) {
      throw Exception('Model integrity check failed for ${config.name}.');
    }
  }
}
