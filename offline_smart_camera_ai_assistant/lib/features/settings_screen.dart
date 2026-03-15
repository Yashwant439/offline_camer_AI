import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/runanywhere_service.dart';
import '../core/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _downloading = false;
  String? _status;

  @override
  Widget build(BuildContext context) {
    final speechService = ref.read(speechServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: speechService.autoSpeak,
            onChanged: (value) {
              setState(() => speechService.autoSpeak = value);
            },
            title: const Text('Auto speak responses'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Download models'),
            subtitle: Text(_status ?? 'Ensure models are cached for offline use.'),
            trailing: _downloading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            onTap: _downloading
                ? null
                : () async {
                    setState(() {
                      _downloading = true;
                      _status = 'Downloading...';
                    });
                    try {
                      await ref.read(runAnywhereServiceProvider).ensureModelsReady();
                      setState(() => _status = 'Models ready for offline use.');
                    } catch (error) {
                      setState(() => _status = 'Download failed: $error');
                    } finally {
                      if (mounted) {
                        setState(() => _downloading = false);
                      }
                    }
                  },
          ),
          const Divider(),
          ListTile(
            title: const Text('LLM model'),
            subtitle: Text(RunAnywhereService.llmModel.name),
          ),
        ],
      ),
    );
  }
}
