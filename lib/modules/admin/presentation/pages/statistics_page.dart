import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@RoutePage()
class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  bool isLoading = true;
  Map<String, dynamic> statistics = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Charger les statistiques depuis Firestore
      final ordersSnapshot =
          await FirebaseFirestore.instance.collection('orders').get();
      final parcelsSnapshot =
          await FirebaseFirestore.instance.collection('parcels').get();
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final deliveryUsersSnapshot =
          await FirebaseFirestore.instance.collection('delivery_users').get();

      // Calculer les statistiques
      final totalOrders = ordersSnapshot.docs.length;
      final totalParcels = parcelsSnapshot.docs.length;
      final totalUsers = usersSnapshot.docs.length;
      final totalDeliveryUsers = deliveryUsersSnapshot.docs.length;

      // Statistiques des commandes par statut
      final orderStatuses = <String, int>{};
      for (final doc in ordersSnapshot.docs) {
        final status = doc.data()['status'] ?? 'unknown';
        orderStatuses[status] = (orderStatuses[status] ?? 0) + 1;
      }

      // Statistiques des colis par statut
      final parcelStatuses = <String, int>{};
      for (final doc in parcelsSnapshot.docs) {
        final status = doc.data()['status'] ?? 'unknown';
        parcelStatuses[status] = (parcelStatuses[status] ?? 0) + 1;
      }

      // Revenus totaux
      double totalRevenue = 0;
      for (final doc in ordersSnapshot.docs) {
        final total = doc.data()['totalAmount']?.toDouble() ?? 0;
        totalRevenue += total;
      }

      for (final doc in parcelsSnapshot.docs) {
        final price = doc.data()['prix']?.toDouble() ?? 0;
        totalRevenue += price;
      }

      // Utilisateurs par rôle
      final userRoles = <String, int>{};
      for (final doc in usersSnapshot.docs) {
        final role = doc.data()['role'] ?? 'client';
        userRoles[role] = (userRoles[role] ?? 0) + 1;
      }

      setState(() {
        statistics = {
          'totalOrders': totalOrders,
          'totalParcels': totalParcels,
          'totalUsers': totalUsers,
          'totalDeliveryUsers': totalDeliveryUsers,
          'totalRevenue': totalRevenue,
          'orderStatuses': orderStatuses,
          'parcelStatuses': parcelStatuses,
          'userRoles': userRoles,
        };
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: const Text(
          'Statistiques',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cartes de statistiques principales
                  _buildMainStatsCards(),
                  const SizedBox(height: 24),

                  // Statistiques des commandes
                  _buildOrdersStats(),
                  const SizedBox(height: 24),

                  // Statistiques des colis
                  _buildParcelsStats(),
                  const SizedBox(height: 24),

                  // Statistiques des utilisateurs
                  _buildUsersStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildMainStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Commandes',
          '${statistics['totalOrders'] ?? 0}',
          Icons.restaurant,
          Colors.orange,
        ),
        _buildStatCard(
          'Total Colis',
          '${statistics['totalParcels'] ?? 0}',
          Icons.local_shipping,
          Colors.green,
        ),
        _buildStatCard(
          'Total Utilisateurs',
          '${statistics['totalUsers'] ?? 0}',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Livreurs',
          '${statistics['totalDeliveryUsers'] ?? 0}',
          Icons.delivery_dining,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersStats() {
    final orderStatuses =
        statistics['orderStatuses'] as Map<String, int>? ?? {};

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Statistiques des Commandes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...orderStatuses.entries.map((entry) => _buildStatusRow(
                  entry.key,
                  entry.value,
                  _getStatusColor(entry.key),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildParcelsStats() {
    final parcelStatuses =
        statistics['parcelStatuses'] as Map<String, int>? ?? {};

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Statistiques des Colis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...parcelStatuses.entries.map((entry) => _buildStatusRow(
                  entry.key,
                  entry.value,
                  _getStatusColor(entry.key),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersStats() {
    final userRoles = statistics['userRoles'] as Map<String, int>? ?? {};

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Statistiques des Utilisateurs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...userRoles.entries.map((entry) => _buildStatusRow(
                  entry.key,
                  entry.value,
                  _getRoleColor(entry.key),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getStatusText(status),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'reception':
        return 'En réception';
      case 'enRoute':
        return 'En route';
      case 'livre':
        return 'Livré';
      case 'nonLivre':
        return 'Non livré';
      case 'admin':
        return 'Administrateurs';
      case 'client':
        return 'Clients';
      case 'delivery':
        return 'Livreurs';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'reception':
        return Colors.orange;
      case 'enRoute':
        return Colors.blue;
      case 'livre':
        return Colors.green;
      case 'nonLivre':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'client':
        return Colors.blue;
      case 'delivery':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
