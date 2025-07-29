import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Exemple d'utilisation de l'authentification Firebase OTP
class AuthExample extends ConsumerWidget {
  const AuthExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentification Firebase'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // État de l'authentification
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'État de l\'authentification',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Connecté: ${authState.isAuthenticated}'),
                    Text('Chargement: ${authState.isLoading}'),
                    if (authState.errorMessage != null)
                      Text('Erreur: ${authState.errorMessage}'),
                    if (authState.currentUser != null) ...[
                      const SizedBox(height: 8),
                      Text('Utilisateur: ${authState.currentUser!['name']}'),
                      Text(
                          'Téléphone: ${authState.currentUser!['phoneNumber']}'),
                      Text('Rôle: ${authState.currentUser!['role']}'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            if (!authState.isAuthenticated) ...[
              ElevatedButton(
                onPressed: () {
                  // Naviguer vers la page d'authentification
                  Navigator.pushNamed(context, '/auth');
                },
                child: const Text('Se connecter'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                },
                child: const Text('Se déconnecter'),
              ),

              const SizedBox(height: 16),

              // Exemple de mise à jour des informations utilisateur
              ElevatedButton(
                onPressed: () async {
                  final success =
                      await ref.read(authProvider.notifier).updateUserInfo({
                    'name': 'Nouveau nom',
                    'lastname': 'Nouveau prénom',
                  });

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Informations mises à jour')),
                    );
                  }
                },
                child: const Text('Mettre à jour les infos'),
              ),
            ],

            const SizedBox(height: 24),

            // Informations sur l'implémentation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fonctionnalités implémentées',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Authentification Firebase avec OTP'),
                    const Text('✅ Gestion des tokens FCM'),
                    const Text('✅ Synchronisation avec Firestore'),
                    const Text('✅ Gestion multi-appareils'),
                    const Text('✅ Persistance locale'),
                    const Text('✅ Gestion des erreurs'),
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
