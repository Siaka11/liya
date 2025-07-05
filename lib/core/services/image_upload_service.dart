import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload une image et retourne l'URL de téléchargement
  static Future<String> uploadImage(String imagePath, String folder) async {
    try {
      // Vérifier que le fichier existe
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Le fichier image n\'existe pas: $imagePath');
      }

      // Vérifier que le fichier n'est pas vide
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Le fichier image est vide');
      }

      // Générer un nom de fichier unique
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      // Créer la référence avec le bucket explicite
      final ref = _storage.ref().child('$folder/$fileName');

      // Vérifier que Firebase Storage est initialisé
      if (_storage.app == null) {
        throw Exception('Firebase Storage n\'est pas initialisé');
      }

      print('Début de l\'upload vers: $folder/$fileName');

      // Upload du fichier avec métadonnées
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_at': DateTime.now().toIso8601String(),
          'folder': folder,
        },
      );

      final uploadTask = ref.putFile(file, metadata);

      // Surveiller le progrès
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Progrès upload: ${(progress * 100).toStringAsFixed(1)}%');
      });

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('Upload réussi: $downloadUrl');
        return downloadUrl;
      } else {
        throw Exception('Échec de l\'upload: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      String errorMessage = 'Erreur Firebase Storage: ';

      switch (e.code) {
        case 'storage/unauthorized':
          errorMessage +=
              'Accès non autorisé. Vérifiez les règles de sécurité.';
          break;
        case 'storage/canceled':
          errorMessage += 'Upload annulé.';
          break;
        case 'storage/unknown':
          errorMessage += 'Erreur inconnue: ${e.message}';
          break;
        case 'storage/invalid-argument':
          errorMessage += 'Argument invalide: ${e.message}';
          break;
        case 'storage/no-default-bucket':
          errorMessage += 'Aucun bucket par défaut configuré.';
          break;
        case 'storage/cannot-slice-blob':
          errorMessage += 'Impossible de traiter le fichier.';
          break;
        case 'storage/server-file-wrong-size':
          errorMessage += 'Taille de fichier incorrecte sur le serveur.';
          break;
        case 'storage/quota-exceeded':
          errorMessage += 'Quota de stockage dépassé.';
          break;
        case 'storage/unauthenticated':
          errorMessage += 'Utilisateur non authentifié.';
          break;
        case 'storage/retry-limit-exceeded':
          errorMessage += 'Limite de tentatives dépassée.';
          break;
        case 'storage/invalid-checksum':
          errorMessage += 'Checksum invalide.';
          break;
        case 'storage/canceled':
          errorMessage += 'Opération annulée.';
          break;
        case 'storage/invalid-event-name':
          errorMessage += 'Nom d\'événement invalide.';
          break;
        case 'storage/invalid-url':
          errorMessage += 'URL invalide.';
          break;
        case 'storage/invalid-upload-url':
          errorMessage += 'URL d\'upload invalide.';
          break;
        case 'storage/invalid-format':
          errorMessage += 'Format invalide.';
          break;
        case 'storage/invalid-default-bucket':
          errorMessage += 'Bucket par défaut invalide.';
          break;
        case 'storage/cannot-delete-default-bucket':
          errorMessage += 'Impossible de supprimer le bucket par défaut.';
          break;
        case 'storage/bucket-not-found':
          errorMessage += 'Bucket non trouvé.';
          break;
        case 'storage/object-not-found':
          errorMessage +=
              'Objet non trouvé. Vérifiez que le bucket existe et que les règles de sécurité permettent l\'écriture.';
          break;
        default:
          errorMessage += 'Code: ${e.code}, Message: ${e.message}';
      }

      print('Erreur lors de l\'upload de l\'image: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      rethrow;
    }
  }

  /// Sélectionne une image depuis la galerie et l'upload
  static Future<String?> pickAndUploadImage(String folder) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await uploadImage(image.path, folder);
      }

      return null;
    } catch (e) {
      print('Erreur lors de la sélection et upload de l\'image: $e');
      rethrow;
    }
  }

  /// Supprime une image de Firebase Storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
        print('Image supprimée avec succès: $imageUrl');
      }
    } on FirebaseException catch (e) {
      print(
          'Erreur Firebase lors de la suppression de l\'image: ${e.code} - ${e.message}');
      // Ne pas rethrow car ce n'est pas critique
    } catch (e) {
      print('Erreur lors de la suppression de l\'image: $e');
      // Ne pas rethrow car ce n'est pas critique
    }
  }

  /// Vérifie si Firebase Storage est configuré correctement
  static Future<bool> isStorageConfigured() async {
    try {
      final ref = _storage.ref().child('test/connection-test.txt');
      await ref.putString('test', format: PutStringFormat.raw);
      await ref.delete();
      return true;
    } catch (e) {
      print('Firebase Storage non configuré: $e');
      return false;
    }
  }
}
