import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'firebase_users_init.dart';

@RoutePage()
class TestUsersManagementPage extends StatefulWidget {
  const TestUsersManagementPage({Key? key}) : super(key: key);

  @override
  State<TestUsersManagementPage> createState() =>
      _TestUsersManagementPageState();
}

class _TestUsersManagementPageState extends State<TestUsersManagementPage> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs Firestore'),
        backgroundColor: const Color(0xFFF24E1E),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFFFF3ED),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section d'information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestion des Utilisateurs Firestore',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF24E1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cette page permet de créer, lister et supprimer des utilisateurs dans Firestore.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Boutons d'action
            _buildActionButton(
              '🚀 Créer des Utilisateurs de Test',
              Icons.person_add,
              Colors.green,
              _createTestUsers,
            ),
            const SizedBox(height: 12),

            _buildActionButton(
              '📋 Lister Tous les Utilisateurs',
              Icons.list,
              Colors.blue,
              _listAllUsers,
            ),
            const SizedBox(height: 12),

            _buildActionButton(
              '👤 Créer un Utilisateur Spécifique',
              Icons.person_add_alt_1,
              Colors.orange,
              _createSpecificUser,
            ),
            const SizedBox(height: 12),

            _buildActionButton(
              '🗑️ Supprimer Tous les Utilisateurs',
              Icons.delete_forever,
              Colors.red,
              _deleteAllUsers,
            ),
            const SizedBox(height: 24),

            // Indicateur de chargement
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFFF24E1E)),
                    SizedBox(height: 8),
                    Text('Opération en cours...'),
                  ],
                ),
              ),

            // Message de statut
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('✅')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage.contains('✅')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('✅')
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _createTestUsers() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await FirebaseUsersInitializer.initializeTestUsers();
      setState(() {
        _statusMessage = '✅ 8 utilisateurs de test ont été créés avec succès !';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Erreur lors de la création des utilisateurs: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _listAllUsers() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await FirebaseUsersInitializer.listAllUsers();
      setState(() {
        _statusMessage = '✅ Liste des utilisateurs affichée dans la console !';
      });
    } catch (e) {
      setState(() {
        _statusMessage =
            '❌ Erreur lors de la récupération des utilisateurs: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createSpecificUser() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await FirebaseUsersInitializer.createSpecificUser(
        id: '0709999999',
        phoneNumber: '0709999999',
        name: 'Utilisateur',
        lastname: 'Test',
        email: 'test.user@example.com',
        address: 'Adresse de test, Côte d\'Ivoire',
        phone: '0709999999',
        createdAt: DateTime.now(),
        role: 'client',
      );
      setState(() {
        _statusMessage = '✅ Utilisateur spécifique créé avec succès !';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Erreur lors de la création de l\'utilisateur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAllUsers() async {
    // Demande de confirmation
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚠️ Confirmation'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer TOUS les utilisateurs ? '
            'Cette action est irréversible !',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await FirebaseUsersInitializer.deleteAllUsers();
      setState(() {
        _statusMessage = '✅ Tous les utilisateurs ont été supprimés !';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Erreur lors de la suppression des utilisateurs: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
