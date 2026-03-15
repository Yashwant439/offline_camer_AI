import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/runanywhere_service.dart';
import '../ai/speech_service.dart';
import '../ai/vision_engine.dart';
import '../data/local_data_source.dart';
import '../data/repositories_impl.dart';
import '../domain/repositories.dart';
import '../features/session_state.dart';
import 'security/secure_key_service.dart';
import 'storage/hive_store.dart';

final runAnywhereServiceProvider = Provider<RunAnywhereService>((ref) {
  return RunAnywhereService();
});

final secureKeyServiceProvider = Provider<SecureKeyService>((ref) {
  return SecureKeyService();
});

final hiveStoreProvider = Provider<HiveStore>((ref) {
  return HiveStore(ref.read(secureKeyServiceProvider));
});

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource(ref.read(hiveStoreProvider));
});

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) {
  return KnowledgeRepositoryImpl(ref.read(localDataSourceProvider));
});

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepositoryImpl(ref.read(localDataSourceProvider));
});

final visionEngineProvider = Provider<VisionEngine>((ref) {
  return MockVisionEngine();
});

final visionRepositoryProvider = Provider<VisionRepository>((ref) {
  return VisionRepositoryImpl(
    ref.read(visionEngineProvider),
    ref.read(knowledgeRepositoryProvider),
  );
});

final llmRepositoryProvider = Provider<LlmRepository>((ref) {
  return LlmRepositoryImpl(ref.read(runAnywhereServiceProvider));
});

final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService(ref.read(runAnywhereServiceProvider));
});

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController(
    ref.read(visionRepositoryProvider),
    ref.read(knowledgeRepositoryProvider),
    ref.read(conversationRepositoryProvider),
    ref.read(llmRepositoryProvider),
    ref.read(speechServiceProvider),
  );
});

class AppBootstrap {
  static Future<void> preload() async {
    final secureKeyService = SecureKeyService();
    await secureKeyService.ensureKey();

    final hiveStore = HiveStore(secureKeyService);
    await hiveStore.init();
    final localDataSource = LocalDataSource(hiveStore);
    await localDataSource.seedKnowledgeIfEmpty();

    await RunAnywhereService.initializeRuntime();
    await RunAnywhereService.registerModels();
  }
}