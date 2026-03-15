import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../core/app_providers.dart';
import '../domain/entities.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  bool _isRecording = false;
  String? _recordPath;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _createRecordPath() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav');
    _recordPath = file.path;
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionControllerProvider);
    final session = state.session;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Voice Chat')),
        body: const Center(child: Text('No active session.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ask about ${session.objectName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          if (state.isBusy)
            const LinearProgressIndicator(minHeight: 2),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _controller.text;
                    _controller.clear();
                    await ref
                        .read(sessionControllerProvider.notifier)
                        .askQuestion(text);
                  },
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () async {
                    final speechService = ref.read(speechServiceProvider);
                    if (!_isRecording) {
                      final path = await _createRecordPath();
                      final started =
                          await speechService.startRecording(path: path);
                      if (!started) return;
                      setState(() => _isRecording = true);
                    } else {
                      setState(() => _isRecording = false);
                      if (_recordPath == null) return;
                      final text = await speechService.stopAndTranscribe(_recordPath!);
                      if (text.isNotEmpty) {
                        await ref
                            .read(sessionControllerProvider.notifier)
                            .askQuestion(text);
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? const Color(0xFF0B6B6B)
                          : const Color(0xFFE6F4F1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF0B6B6B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
