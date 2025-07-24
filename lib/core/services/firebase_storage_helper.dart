import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseStorageHelper {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Vérifie la configuration de Firebase Storage
  static Future<Map<String, dynamic>> diagnoseStorageIssues() async {
    final diagnostics = <String, dynamic>{};

    try {
      // Vérifier si Firebase est initialisé
      diagnostics['firebase_initialized'] = Firebase.apps.isNotEmpty;

      if (Firebase.apps.isNotEmpty) {
        diagnostics['firebase_app_name'] = Firebase.app().name;
        diagnostics['firebase_options'] = Firebase.app().options;
      }

      // Vérifier si le bucket est accessible
      try {
        final bucket = _storage.bucket;
        diagnostics['storage_bucket'] = bucket;
        diagnostics['storage_bucket_accessible'] = bucket != null;

        // Vérifier si le bucket existe réellement
        if (bucket != null) {
          try {
            final bucketRef = _storage.ref();
            await bucketRef.listAll();
            diagnostics['bucket_exists'] = true;
          } catch (e) {
            diagnostics['bucket_exists'] = false;
            diagnostics['bucket_error'] = e.toString();
          }
        }
      } catch (e) {
        diagnostics['storage_bucket_error'] = e.toString();
        diagnostics['storage_bucket_accessible'] = false;
      }

      // Tester l'upload d'un petit fichier
      try {
        final testRef = _storage.ref().child('test/connection-test.txt');
        await testRef.putString('test', format: PutStringFormat.raw);
        await testRef.delete();
        diagnostics['test_upload_success'] = true;
      } catch (e) {
        diagnostics['test_upload_error'] = e.toString();
        diagnostics['test_upload_success'] = false;
      }

      // Vérifier les permissions
      try {
        final listRef = _storage.ref().child('test');
        await listRef.listAll();
        diagnostics['list_permissions'] = true;
      } catch (e) {
        diagnostics['list_permissions_error'] = e.toString();
        diagnostics['list_permissions'] = false;
      }
    } catch (e) {
      diagnostics['general_error'] = e.toString();
    }

    return diagnostics;
  }

  /// Affiche les diagnostics dans la console
  static Future<void> printDiagnostics() async {
    print('🔍 Diagnostic Firebase Storage...');
    final diagnostics = await diagnoseStorageIssues();

    print('📊 Résultats du diagnostic:');
    for (final entry in diagnostics.entries) {
      print('  ${entry.key}: ${entry.value}');
    }

    // Recommandations
    print('\n💡 Recommandations:');
    if (diagnostics['firebase_initialized'] != true) {
      print('  ❌ Firebase n\'est pas initialisé correctement');
    }
    if (diagnostics['storage_bucket_accessible'] != true) {
      print('  ❌ Le bucket de stockage n\'est pas accessible');
    }
    if (diagnostics['bucket_exists'] == false) {
      print('  ❌ Le bucket n\'existe pas. Créez-le dans Google Cloud Console');
      print(
          '  🔗 https://console.cloud.google.com/storage/browser?project=liya-a4a9f');
    }
    if (diagnostics['test_upload_success'] != true) {
      print('  ❌ L\'upload de test a échoué');
    }
    if (diagnostics['list_permissions'] != true) {
      print('  ❌ Problème de permissions');
    }

    if (diagnostics['firebase_initialized'] == true &&
        diagnostics['storage_bucket_accessible'] == true &&
        diagnostics['bucket_exists'] == true &&
        diagnostics['test_upload_success'] == true) {
      print('  ✅ Firebase Storage semble correctement configuré');
    }
  }

  /// Vérifie et crée les dossiers nécessaires
  static Future<void> ensureFoldersExist() async {
    final folders = ['restaurants', 'dishes', 'users', 'temp'];

    for (final folder in folders) {
      try {
        final folderRef = _storage.ref().child(folder);
        // Essayer de lister le contenu pour vérifier l'existence
        await folderRef.listAll();
        print('✅ Dossier $folder accessible');
      } catch (e) {
        print('⚠️ Dossier $folder non accessible: $e');
      }
    }
  }

  /// Nettoie les fichiers temporaires
  static Future<void> cleanupTempFiles() async {
    try {
      final testRef = _storage.ref().child('test');
      final result = await testRef.listAll();

      for (final item in result.items) {
        try {
          await item.delete();
          print('🗑️ Fichier supprimé: ${item.name}');
        } catch (e) {
          print('⚠️ Impossible de supprimer: ${item.name} - $e');
        }
      }

      print('✅ Nettoyage terminé');
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }

  /// Vérifie si le bucket existe et retourne des instructions
  static Future<Map<String, dynamic>> checkBucketStatus() async {
    final status = <String, dynamic>{};

    try {
      final bucket = _storage.bucket;
      status['bucket_name'] = bucket;

      if (bucket != null) {
        try {
          final bucketRef = _storage.ref();
          await bucketRef.listAll();
          status['bucket_exists'] = true;
          status['bucket_accessible'] = true;
        } catch (e) {
          status['bucket_exists'] = false;
          status['bucket_accessible'] = false;
          status['error'] = e.toString();
        }
      } else {
        status['bucket_exists'] = false;
        status['bucket_accessible'] = false;
        status['error'] = 'Bucket non défini';
      }
    } catch (e) {
      status['bucket_exists'] = false;
      status['bucket_accessible'] = false;
      status['error'] = e.toString();
    }

    return status;
  }

  /// Retourne les instructions pour créer le bucket
  static Map<String, dynamic> getBucketCreationInstructions() {
    return {
      'title': 'Bucket Firebase Storage créé avec succès',
      'bucket_name': 'liya-a4a9f-storage',
      'status': 'created',
      'next_steps': [
        '1. Aller dans Firebase Console > Storage > Rules',
        '2. Configurer les règles de sécurité',
        '3. Tester l\'upload d\'images dans l\'app',
        '4. Vérifier que les fichiers s\'affichent correctement'
      ],
      'url': 'https://console.firebase.google.com/project/liya-a4a9f/storage'
    };
  }
}
