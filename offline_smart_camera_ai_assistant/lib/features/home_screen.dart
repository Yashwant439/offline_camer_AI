import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_providers.dart';
import '../core/app_routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F6F2), Color(0xFFE6F4F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Offline Smart Camera',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Capture objects, ask questions, and learn offline.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            _ActionButton(
              icon: Icons.camera_alt,
              label: 'Open Camera',
              onTap: () => Navigator.pushNamed(context, AppRoutes.camera),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.photo_library,
              label: 'Pick from Gallery',
              onTap: () async {
                final picker = ImagePicker();
                final file = await picker.pickImage(source: ImageSource.gallery);
                if (file == null) return;
                await ref
                    .read(sessionControllerProvider.notifier)
                    .detectImage(file.path);
                if (context.mounted) {
                  Navigator.pushNamed(context, AppRoutes.result);
                }
              },
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.history,
              label: 'History',
              onTap: () => Navigator.pushNamed(context, AppRoutes.history),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(label),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B6B6B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
