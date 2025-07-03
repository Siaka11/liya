import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/home_delivery_provider.dart';
import '../../domain/entities/delivery_user.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DeliveryProfilePage extends ConsumerWidget {
  const DeliveryProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(homeDeliveryProvider);
    final currentUser = deliveryState.currentUser;

    if (deliveryState.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF3ED),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF3ED),
        body: Center(
          child: Text('Erreur: Utilisateur non trouvé'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: const Text('Mon Profil', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // TODO: Naviguer vers la page de modification du profil
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            // Photo de profil
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFF24E1E).withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: const Color(0xFFF24E1E),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentUser.fullName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF24E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Livreur',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statut de disponibilité
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      currentUser.isAvailable
                          ? Icons.check_circle
                          : Icons.cancel,
                      color:
                          currentUser.isAvailable ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.isAvailable
                                ? 'Disponible'
                                : 'Indisponible',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: currentUser.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          Text(
                            currentUser.isAvailable
                                ? 'Prêt pour les livraisons'
                                : 'Non disponible pour les livraisons',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistiques
            const Text(
              'Mes Statistiques',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Livraisons',
                    currentUser.completedDeliveries.toString(),
                    Icons.local_shipping,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Gains Totaux',
                    '${currentUser.totalEarnings.toStringAsFixed(0)} FCFA',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Note Moyenne',
                    currentUser.averageRating.toStringAsFixed(1),
                    Icons.star,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Évaluations',
                    currentUser.totalRatings.toString(),
                    Icons.rate_review,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Informations personnelles
            const Text(
              'Informations Personnelles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Column(
                children: [
                  _buildInfoTile(
                    Icons.phone,
                    'Téléphone',
                    currentUser.phoneNumber,
                    isPhone: true,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    Icons.email,
                    'Email',
                    currentUser.email,
                    isEmail: true,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    Icons.location_on,
                    'Adresse',
                    currentUser.address,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    Icons.calendar_today,
                    'Membre depuis',
                    DateFormat('dd/MM/yyyy').format(currentUser.createdAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Naviguer vers la page de modification du profil
                },
                icon: const Icon(Icons.edit),
                label: const Text('Modifier mon profil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF24E1E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implémenter la déconnexion
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value,
      {bool isPhone = false, bool isEmail = false}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF24E1E)),
      title: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(label),
      trailing: isPhone || isEmail
          ? IconButton(
              icon: Icon(
                isPhone ? Icons.call : Icons.email,
                color: const Color(0xFFF24E1E),
              ),
              onPressed: () {
                // TODO: Implémenter l'action (appel ou email)
              },
            )
          : null,
    );
  }
}
