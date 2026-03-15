import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'runanywhere_service.dart';

class SpeechService {
  SpeechService(this._runAnywhereService);

  final RunAnywhereService _runAnywhereService;
  final AudioRecorder _record = AudioRecorder();
  final FlutterTts _tts = FlutterTts();

  bool autoSpeak = true;

  Future<void> init() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
  }

  Future<bool> startRecording({required String path}) async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return false;
    await _record.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
    return true;
  }

  Future<String> stopAndTranscribe(String path) async {
    final resultPath = await _record.stop();
    final audioPath = resultPath ?? path;
    final file = File(audioPath);
    if (!await file.exists()) {
      return '';
    }
    final bytes = await file.readAsBytes();
    return _runAnywhereService.transcribe(bytes);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }
}
