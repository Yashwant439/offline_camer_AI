import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_providers.dart';
import '../core/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _status = 'Initializing on-device AI...';
  String? _error;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await ref.read(runAnywhereServiceProvider).ensureModelsReady();
      await ref.read(speechServiceProvider).init();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (error) {
      setState(() {
        _error = error.toString();
        _status = 'Offline mode ready, but models are not downloaded.';
      });
    }
  }

  Future<void> _downloadModels() async {
    setState(() {
      _downloading = true;
      _status = 'Downloading models...';
      _error = null;
    });

    try {
      await ref.read(runAnywhereServiceProvider).ensureModelsReady();
      await ref.read(speechServiceProvider).init();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (error) {
      setState(() {
        _error = error.toString();
        _status = 'Download failed. Tap retry to try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F6F2), Color(0xFFE6F4F1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFF0B6B6B),
                child: Icon(Icons.camera_alt, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'OFFLINE SMART CAMERA AI',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(_status, style: Theme.of(context).textTheme.bodyMedium),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _error!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                if (_downloading)
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (!_downloading) ...[
                  ElevatedButton(
                    onPressed: _downloadModels,
                    child: const Text('Download Models'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                    child: const Text('Continue Offline'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
