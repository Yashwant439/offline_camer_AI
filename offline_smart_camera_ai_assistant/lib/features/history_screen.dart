import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_providers.dart';
import '../core/app_routes.dart';
import '../domain/entities.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(conversationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder<List<DetectionSession>>(
        future: repository.loadSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const Center(child: Text('No history yet.'));
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ListTile(
                title: Text(session.objectName),
                subtitle: Text(
                  'Confidence ${(session.confidence * 100).toStringAsFixed(1)}% - ${session.createdAt.toLocal()}',
                ),
                onTap: () async {
                  await ref
                      .read(sessionControllerProvider.notifier)
                      .loadSession(session);
                  if (context.mounted) {
                    Navigator.pushNamed(context, AppRoutes.result);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
