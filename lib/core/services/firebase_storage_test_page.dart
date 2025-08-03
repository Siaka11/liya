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
      _log += '🔍 Démarrage du diagnostic Firebase Storage...\n';
    });

    try {
      final diagnostics = await FirebaseStorageHelper.diagnoseStorageIssues();
      setState(() {
        _diagnostics = diagnostics;
        _log += '✅ Diagnostic terminé\n';
      });

      // Tests supplémentaires
      await _testSpecificFolders();
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

  Future<void> _testSpecificFolders() async {
    final folders = ['restaurants', 'dishes', 'users', 'test'];

    for (final folder in folders) {
      setState(() {
        _log += '🧪 Test du dossier: $folder\n';
      });

      // Test des permissions
      final hasPermissions =
          await ImageUploadService.checkFolderPermissions(folder);
      setState(() {
        _log += hasPermissions
            ? '✅ Permissions OK\n'
            : '❌ Problème de permissions\n';
      });

      // Test d'upload
      final uploadSuccess = await ImageUploadService.testUploadToFolder(folder);
      setState(() {
        _log += uploadSuccess ? '✅ Upload OK\n' : '❌ Upload échoué\n';
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

  Future<void> _testRestaurantUpload() async {
    if (_testImagePath == null) {
      setState(() {
        _log += '❌ Aucune image sélectionnée\n';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _log += '🏪 Test upload restaurant...\n';
    });

    try {
      final imageUrl =
          await ImageUploadService.uploadImage(_testImagePath!, 'restaurants');
      setState(() {
        _uploadedImageUrl = imageUrl;
        _log += '✅ Upload restaurant réussi: $imageUrl\n';
      });
    } catch (e) {
      setState(() {
        _log += '❌ Erreur upload restaurant: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testBucketCreation() async {
    setState(() {
      _isLoading = true;
      _log += '🔍 Test de la création du bucket...\n';
    });

    try {
      // Vérifier si le bucket existe maintenant
      final bucketStatus = await FirebaseStorageHelper.checkBucketStatus();

      setState(() {
        _log += '📦 Statut du bucket:\n';
        for (final entry in bucketStatus.entries) {
          _log += '  ${entry.key}: ${entry.value}\n';
        }
      });

      if (bucketStatus['bucket_exists'] == true) {
        setState(() {
          _log += '✅ Bucket créé avec succès!\n';
        });

        // Tester l'upload
        await _testUpload();
      } else {
        setState(() {
          _log += '❌ Bucket non trouvé. Vérifiez la configuration.\n';
        });
      }
    } catch (e) {
      setState(() {
        _log += '❌ Erreur lors du test: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testOriginalBucket() async {
    setState(() {
      _isLoading = true;
      _log += '🔍 Test du bucket original: liya-a4a9f.firebasestorage.app\n';
    });

    try {
      // Vérifier si le bucket original existe maintenant
      final bucketStatus = await FirebaseStorageHelper.checkBucketStatus();

      setState(() {
        _log += '📦 Statut du bucket original:\n';
        for (final entry in bucketStatus.entries) {
          _log += '  ${entry.key}: ${entry.value}\n';
        }
      });

      if (bucketStatus['bucket_exists'] == true) {
        setState(() {
          _log += '✅ Bucket original créé avec succès!\n';
        });

        // Tester l'upload vers le bucket original
        if (_testImagePath != null) {
          try {
            final imageUrl =
                await ImageUploadService.uploadImage(_testImagePath!, 'test');
            setState(() {
              _uploadedImageUrl = imageUrl;
              _log += '✅ Upload vers le bucket original réussi: $imageUrl\n';
            });
          } catch (e) {
            setState(() {
              _log += '❌ Erreur upload vers le bucket original: $e\n';
            });
          }
        }
      } else {
        setState(() {
          _log += '❌ Bucket original non trouvé. Vérifiez la configuration.\n';
        });
      }
    } catch (e) {
      setState(() {
        _log += '❌ Erreur lors du test du bucket original: $e\n';
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
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runDiagnostics,
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
                  // Diagnostic Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Diagnostic Firebase Storage',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._diagnostics.entries.map((entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      entry.value == true
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: entry.value == true
                                          ? Colors.green
                                          : Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${entry.key}: ${entry.value}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
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
                            'Log des opérations',
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
                                  onPressed:
                                      _isLoading || _testImagePath == null
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
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isLoading ? null : _testBucketCreation,
                              icon: const Icon(Icons.storage),
                              label: const Text('Tester la création du bucket'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading || _testImagePath == null
                                  ? null
                                  : _testRestaurantUpload,
                              icon: const Icon(Icons.restaurant),
                              label: const Text('Test upload restaurant'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _cleanupTest,
                              icon: const Icon(Icons.cleaning_services),
                              label:
                                  const Text('Nettoyer les fichiers de test'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Solutions Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Solutions recommandées',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '1. Vérifiez que Firebase Storage est activé dans la console Firebase\n'
                            '2. Configurez les règles de sécurité dans Firebase Console > Storage > Rules\n'
                            '3. Vérifiez que votre compte de facturation est configuré\n'
                            '4. Assurez-vous que les fichiers de configuration sont à jour',
                            style: TextStyle(fontSize: 14),
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
