import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:liya/core/services/account_management_service.dart';

class TestAccountDeletion extends StatefulWidget {
  const TestAccountDeletion({super.key});

  @override
  State<TestAccountDeletion> createState() => _TestAccountDeletionState();
}

class _TestAccountDeletionState extends State<TestAccountDeletion> {
  String _statusMessage = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Suppression Compte'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informations utilisateur actuel
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👤 Utilisateur actuel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildUserInfo(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bouton de test de suppression
            ElevatedButton(
              onPressed: _isLoading ? null : _testAccountDeletion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '🧪 Tester la suppression de compte',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 16),

            // Message de statut
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('✅')
                      ? Colors.green.shade100
                      : _statusMessage.contains('❌')
                          ? Colors.red.shade100
                          : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage.contains('✅')
                        ? Colors.green
                        : _statusMessage.contains('❌')
                            ? Colors.red
                            : Colors.blue,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('✅')
                        ? Colors.green.shade800
                        : _statusMessage.contains('❌')
                            ? Colors.red.shade800
                            : Colors.blue.shade800,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Informations sur le processus
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ Comment ça fonctionne',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Récupération du numéro de téléphone\n'
                      '2. Suppression des données Firestore\n'
                      '3. Suppression du compte Firebase Auth\n'
                      '4. Nettoyage du stockage local\n'
                      '5. Redirection vers la page de connexion',
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

  Widget _buildUserInfo() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Text(
        '❌ Aucun utilisateur connecté',
        style: TextStyle(color: Colors.red),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📱 UID: ${user.uid}'),
        Text('📞 Téléphone: ${user.phoneNumber ?? 'Non défini'}'),
        Text('📧 Email: ${user.email ?? 'Non défini'}'),
        Text('🕒 Créé: ${user.metadata.creationTime?.toLocal()}'),
        Text(
            '🔄 Dernière connexion: ${user.metadata.lastSignInTime?.toLocal()}'),
      ],
    );
  }

  Future<void> _testAccountDeletion() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '🔄 Test en cours...';
    });

    try {
      // Vérifier que l'utilisateur est connecté
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _statusMessage = '❌ Aucun utilisateur connecté pour le test';
        });
        return;
      }

      // Vérifier que le numéro de téléphone est disponible
      if (user.phoneNumber == null) {
        setState(() {
          _statusMessage = '❌ Numéro de téléphone non disponible pour le test';
        });
        return;
      }

      setState(() {
        _statusMessage = '✅ Utilisateur connecté et prêt pour le test\n'
            '📱 Numéro: ${user.phoneNumber}\n'
            '🆔 UID: ${user.uid}';
      });

      // Attendre un peu pour que l'utilisateur puisse lire le message
      await Future.delayed(const Duration(seconds: 3));

      // Afficher le dialogue de suppression de compte
      await AccountManagementService.showDeleteAccountDialog(context);
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Erreur lors du test: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
