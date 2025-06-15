import 'dart:io';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/dish_model.dart';
import '../providers/dish_provider.dart';

@RoutePage()
class DishImageEditorPage extends ConsumerStatefulWidget {
  final DishModel dish;
  const DishImageEditorPage({super.key, required this.dish});

  @override
  ConsumerState<DishImageEditorPage> createState() =>
      _DishImageEditorPageState();
}

class _DishImageEditorPageState extends ConsumerState<DishImageEditorPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (image != null) {
      await ref.read(dishProvider.notifier).selectImage(File(image.path));
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (photo != null) {
      await ref.read(dishProvider.notifier).selectImage(File(photo.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dishProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier l'image du plat"),
        actions: [
          if (state.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                await ref
                    .read(dishProvider.notifier)
                    .uploadImage(widget.dish.id);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        state.selectedImage!,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (widget.dish.imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.dish.imageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(dishProvider.notifier)
                            .deleteImage(widget.dish.id, widget.dish.imageUrl);
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Supprimer l'image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galerie'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Appareil photo'),
                        ),
                      ),
                    ],
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
