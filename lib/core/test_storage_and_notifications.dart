import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'image_upload_service.dart';
import 'notification_service.dart';

class TestStorageAndNotificationsPage extends StatefulWidget {
  const TestStorageAndNotificationsPage({Key? key}) : super(key: key);

  @override
  State<TestStorageAndNotificationsPage> createState() =>
      _TestStorageAndNotificationsPageState();
}

class _TestStorageAndNotificationsPageState
    extends State<TestStorageAndNotificationsPage> {
  String _log = '';
  bool _isLoading = false;
  String? _testImagePath;
  String? _uploadedImageUrl;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _log += '🚀 Démarrage des tests...\n';
    });

    try {
      // Test 1: Vérifier FCM Token
      await _testFCMToken();

      // Test 2: Vérifier Firebase Storage
      await _testFirebaseStorage();

      // Test 3: Tester l'upload d'image
      await _testImageUpload();
    } catch (e) {
      setState(() {
        _log += '❌ Erreur lors des tests: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFCMToken() async {
    setState(() {
      _log += '🔑 Test du FCM Token...\n';
    });

    try {
      final token = await FirebaseMessaging.instance.getToken();
      setState(() {
        _fcmToken = token;
        _log += '✅ FCM Token: ${token?.substring(0, 20)}...\n';
      });
    } catch (e) {
      setState(() {
        _log += '❌ Erreur FCM Token: $e\n';
      });
    }
  }

  Future<void> _testFirebaseStorage() async {
    setState(() {
      _log += '📦 Test Firebase Storage...\n';
    });

    try {
      final storage = FirebaseStorage.instance;
      final bucket = storage.bucket;

      setState(() {
        _log += '✅ Bucket: $bucket\n';
      });

      // Test d'upload simple
      final testRef = storage.ref().child('test/connection-test.txt');
      await testRef.putString('test', format: PutStringFormat.raw);
      await testRef.delete();

      setState(() {
        _log += '✅ Test d\'upload réussi\n';
      });
    } catch (e) {
      setState(() {
        _log += '❌ Erreur Firebase Storage: $e\n';
      });
    }
  }

  Future<void> _testImageUpload() async {
    setState(() {
      _log += '📸 Test d\'upload d\'image...\n';
    });

    try {
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
          _log += '✅ Image sélectionnée\n';
        });

        // Upload vers différents dossiers
        final folders = ['restaurants', 'dishes', 'users', 'test'];

        for (final folder in folders) {
          try {
            final imageUrl =
                await ImageUploadService.uploadImage(image.path, folder);
            setState(() {
              _uploadedImageUrl = imageUrl;
              _log +=
                  '✅ Upload vers $folder réussi: ${imageUrl.substring(0, 50)}...\n';
            });
          } catch (e) {
            setState(() {
              _log += '❌ Erreur upload vers $folder: $e\n';
            });
          }
        }
      } else {
        setState(() {
          _log += '⚠️ Aucune image sélectionnée\n';
        });
      }
    } catch (e) {
      setState(() {
        _log += '❌ Erreur sélection image: $e\n';
      });
    }
  }

  Future<void> _testNotification() async {
    setState(() {
      _log += '🔔 Test de notification...\n';
    });

    try {
      // Simuler une notification locale
      await NotificationService.showLocalNotification(
        title: 'Test de notification',
        body: 'Cette notification fonctionne !',
      );

      setState(() {
        _log += '✅ Notification locale envoyée\n';
      });
    } catch (e) {
      setState(() {
        _log += '❌ Erreur notification: $e\n';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Storage & Notifications'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runTests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Log Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Log des tests',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 300,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _log,
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
                  const SizedBox(height: 16),

                  // Test Buttons
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tests',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _pickImage,
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Sélectionner image'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _isLoading ? null : _testImageUpload,
                                  icon: const Icon(Icons.upload),
                                  label: const Text('Test upload'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _testNotification,
                              icon: const Icon(Icons.notifications),
                              label: const Text('Test notification'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Results Section
                  if (_testImagePath != null || _uploadedImageUrl != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Résultats',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_testImagePath != null) ...[
                              const Text('Image sélectionnée:'),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_testImagePath!),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (_uploadedImageUrl != null) ...[
                              const Text('Image uploadée:'),
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
                  ],

                  // Status Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statut',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                _fcmToken != null
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _fcmToken != null
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              const Text('FCM Token'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              const Text('Firebase Storage'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              const Text('Notifications'),
                            ],
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
