import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_storage_helper.dart';
import 'image_upload_service.dart';

class FirebaseStorageTestPage extends StatefulWidget {
  const FirebaseStorageTestPage({Key? key}) : super(key: key);

  @override
  State<FirebaseStorageTestPage> createState() =>
      _FirebaseStorageTestPageState();
}

class _FirebaseStorageTestPageState extends State<FirebaseStorageTestPage> {
  Map<String, dynamic> _diagnostics = {};
  bool _isLoading = false;
  String? _testImagePath;
  String? _uploadedImageUrl;
  String _log = '';

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _log += '🔍 Démarrage du diagnostic...\n';
    });

    try {
      final diagnostics = await FirebaseStorageHelper.diagnoseStorageIssues();
      setState(() {
        _diagnostics = diagnostics;
        _log += '✅ Diagnostic terminé\n';
      });
    } catch (e) {
      setState(() {
        _log += '❌ Erreur lors du diagnostic: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _testImagePath = image.path;
        _log += '📸 Image sélectionnée: ${image.path}\n';
      });
    }
  }

  Future<void> _testUpload() async {
    if (_testImagePath == null) {
      setState(() {
        _log += '❌ Aucune image sélectionnée\n';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _log += '📤 Début de l\'upload de test...\n';
    });

    try {
      final imageUrl =
          await ImageUploadService.uploadImage(_testImagePath!, 'test');
      setState(() {
        _uploadedImageUrl = imageUrl;
        _log += '✅ Upload réussi: $imageUrl\n';
      });
    } catch (e) {
      setState(() {
        _log += '❌ Erreur upload: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanupTest() async {
    setState(() {
      _isLoading = true;
      _log += '🧹 Nettoyage des fichiers de test...\n';
    });

    try {
      await FirebaseStorageHelper.cleanupTempFiles();
      setState(() {
        _log += '✅ Nettoyage terminé\n';
      });
    } catch (e) {
      setState(() {
        _log += '❌ Erreur nettoyage: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firebase Storage'),
        backgroundColor: const Color(0xFFF24E1E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Diagnostic Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Diagnostic Firebase Storage',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._diagnostics.entries.map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  '${entry.key}:',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value.toString(),
                                  style: TextStyle(
                                    color: entry.value == true
                                        ? Colors.green
                                        : entry.value == false
                                            ? Colors.red
                                            : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _runDiagnostics,
                      child: const Text('Relancer le diagnostic'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Upload Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test d\'Upload',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_testImagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_testImagePath!),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Sélectionner une image'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading || _testImagePath == null
                                ? null
                                : _testUpload,
                            icon: const Icon(Icons.upload),
                            label: const Text('Tester l\'upload'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_uploadedImageUrl != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Image uploadée:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _uploadedImageUrl!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error,
                                  size: 50, color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cleanup Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nettoyage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _cleanupTest,
                      icon: const Icon(Icons.cleaning_services),
                      label: const Text('Nettoyer les fichiers de test'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Log Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Log',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _log.isEmpty ? 'Aucun log disponible' : _log,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
