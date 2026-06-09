import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../application/baby_photo_providers.dart';
import '../domain/baby_photo.dart';

/// An encrypted keepsake gallery for the baby. Images are stored as BLOBs in the
/// encrypted database, so they never touch an unencrypted file and are wiped
/// with everything else by "Delete all data".
class BabyPhotoGalleryScreen extends ConsumerWidget {
  const BabyPhotoGalleryScreen({required this.childId, super.key});

  final int childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(babyPhotosProvider(childId)).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Photos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add'),
      ),
      body: photos.isEmpty
          ? const _EmptyGallery()
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: photos.length,
              itemBuilder: (context, i) => _PhotoTile(photo: photos[i]),
            ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      await ref.read(babyPhotoRepositoryProvider).add(childId, bytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not add photo: $e')));
      }
    }
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library_outlined, size: 40),
            const SizedBox(height: 12),
            Text(
              'Keep your favourite photos here. They’re stored encrypted on this '
              'device only — never uploaded.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends ConsumerWidget {
  const _PhotoTile({required this.photo});

  final BabyPhoto photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _view(context, ref),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(photo.bytes, fit: BoxFit.cover),
      ),
    );
  }

  Future<void> _view(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: InteractiveViewer(child: Image.memory(photo.bytes)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    onPressed: () {
                      ref.read(babyPhotoRepositoryProvider).delete(photo.id!);
                      Navigator.of(ctx).pop();
                    },
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
