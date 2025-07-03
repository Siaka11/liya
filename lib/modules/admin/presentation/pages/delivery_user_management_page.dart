import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@RoutePage()
class DeliveryUserManagementPage extends ConsumerStatefulWidget {
  const DeliveryUserManagementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DeliveryUserManagementPage> createState() =>
      _DeliveryUserManagementPageState();
}

class _DeliveryUserManagementPageState
    extends ConsumerState<DeliveryUserManagementPage> {
  List<Map<String, dynamic>> deliveryUsers = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadDeliveryUsers();
  }

  Future<void> _loadDeliveryUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('delivery_users').get();

      setState(() {
        deliveryUsers = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Nom inconnu',
            'phone': data['phone'] ?? 'Téléphone inconnu',
            'email': data['email'] ?? 'Email inconnu',
            'active': data['active'] ?? false,
            'currentLocation': data['currentLocation'] ?? null,
            'rating': data['rating']?.toDouble() ?? 0.0,
            'totalDeliveries': data['totalDeliveries'] ?? 0,
            'completedDeliveries': data['completedDeliveries'] ?? 0,
            'failedDeliveries': data['failedDeliveries'] ?? 0,
            'earnings': data['earnings']?.toDouble() ?? 0.0,
            'vehicleType': data['vehicleType'] ?? 'Non spécifié',
            'registrationDate': data['registrationDate'] != null
                ? (data['registrationDate'] as Timestamp).toDate()
                : DateTime.now(),
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredDeliveryUsers {
    return deliveryUsers.where((user) {
      final matchesSearch = searchQuery.isEmpty ||
          user['name']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          user['phone'].toString().contains(searchQuery) ||
          user['email']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      final matchesStatus = selectedStatus == 'all' ||
          (selectedStatus == 'active' && user['active']) ||
          (selectedStatus == 'inactive' && !user['active']);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> _toggleUserStatus(String userId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('delivery_users')
          .doc(userId)
          .update({'active': !currentStatus});

      await _loadDeliveryUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut du livreur mis à jour'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteDeliveryUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content:
            Text('Êtes-vous sûr de vouloir supprimer le livreur "$userName" ?'),
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
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('delivery_users')
            .doc(userId)
            .delete();

        await _loadDeliveryUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Livreur supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de ${user['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nom', user['name']),
              _buildDetailRow('Téléphone', user['phone']),
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('Véhicule', user['vehicleType']),
              _buildDetailRow('Note', '${user['rating']}/5'),
              _buildDetailRow(
                  'Livraisons totales', user['totalDeliveries'].toString()),
              _buildDetailRow('Livraisons réussies',
                  user['completedDeliveries'].toString()),
              _buildDetailRow(
                  'Livraisons échouées', user['failedDeliveries'].toString()),
              _buildDetailRow('Gains totaux', '${user['earnings']} €'),
              _buildDetailRow('Statut', user['active'] ? 'Actif' : 'Inactif'),
              _buildDetailRow('Date d\'inscription',
                  '${user['registrationDate'].day}/${user['registrationDate'].month}/${user['registrationDate'].year}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: const Text(
          'Gestion des Livreurs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // TODO: Navigation vers ajout de livreur
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un livreur...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Filtre par statut
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'all', child: Text('Tous les livreurs')),
                    DropdownMenuItem(
                        value: 'active', child: Text('Actifs uniquement')),
                    DropdownMenuItem(
                        value: 'inactive', child: Text('Inactifs uniquement')),
                  ],
                  onChanged: (value) => setState(() => selectedStatus = value!),
                ),
              ],
            ),
          ),

          // Statistiques
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total',
                  deliveryUsers.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Actifs',
                  deliveryUsers.where((u) => u['active']).length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Inactifs',
                  deliveryUsers.where((u) => !u['active']).length.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
                _buildStatCard(
                  'Moyenne',
                  deliveryUsers.isNotEmpty
                      ? (deliveryUsers
                                  .map((u) => u['rating'])
                                  .reduce((a, b) => a + b) /
                              deliveryUsers.length)
                          .toStringAsFixed(1)
                      : '0.0',
                  Icons.star,
                  Colors.amber,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Liste des livreurs
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDeliveryUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun livreur trouvé',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredDeliveryUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredDeliveryUsers[index];
                          return _buildDeliveryUserCard(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDeliveryUserCard(Map<String, dynamic> user) {
    final successRate = user['totalDeliveries'] > 0
        ? (user['completedDeliveries'] / user['totalDeliveries'] * 100)
            .toStringAsFixed(1)
        : '0.0';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor:
              user['active'] ? Colors.green[100] : Colors.grey[200],
          child: Icon(
            Icons.delivery_dining,
            size: 30,
            color: user['active'] ? Colors.green : Colors.grey,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: user['active'] ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user['active'] ? 'Actif' : 'Inactif',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  user['phone'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    user['email'],
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${user['rating']}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.motorcycle, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  user['vehicleType'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${user['totalDeliveries']} livraisons',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '$successRate% de réussite',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.euro, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${user['earnings']} € gagnés',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: user['active'],
              onChanged: (value) =>
                  _toggleUserStatus(user['id'], user['active']),
              activeColor: const Color(0xFFF24E1E),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'details') {
                  _showUserDetails(user);
                } else if (value == 'edit') {
                  // TODO: Navigation vers édition
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité à venir')),
                  );
                } else if (value == 'delete') {
                  _deleteDeliveryUser(user['id'], user['name']);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 20),
                      SizedBox(width: 8),
                      Text('Détails'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
