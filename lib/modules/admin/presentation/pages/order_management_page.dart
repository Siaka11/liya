import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../restaurant/features/order/presentation/pages/order_details_full_page.dart';
import '../../../parcel/feature/presentation/pages/parcel_details_full_page.dart';

@RoutePage()
class OrderManagementPage extends ConsumerStatefulWidget {
  const OrderManagementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderManagementPage> createState() =>
      _OrderManagementPageState();
}

class _OrderManagementPageState extends ConsumerState<OrderManagementPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedStatus = 'all';
  String selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      // Charger TOUTES les commandes de restaurant (même assignées)
      final restaurantOrdersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> restaurantOrders =
          restaurantOrdersSnapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'type': 'restaurant',
          'orderNumber': doc.id,
          'clientName':
              data['customerName'] ?? data['delivery_name'] ?? 'Client inconnu',
          'clientPhone':
              data['phoneNumber'] ?? data['phone'] ?? 'Téléphone inconnu',
          'restaurantName': data['restaurantName'] ?? 'Restaurant inconnu',
          'totalAmount': (data['total'] ?? 0.0).toDouble(),
          'status': data['status'] ?? 'reception',
          'deliveryAddress': data['address'] ?? 'Adresse inconnue',
          'assignedTo': data['assignedTo'], // Téléphone du livreur assigné
          'assignedToName': data['assignedToName'], // Nom du livreur assigné
          'assignedAt': data['assignedAt'], // Date d'assignation
          'deliveryFee': data['deliveryFee'] ?? 0.0,
          'subtotal': data['subtotal'] ?? 0.0,
          'deliveryTime': data['deliveryTime'] ?? 0,
          'distance': data['distance'] ?? 0,
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'deliveryInstructions': data['deliveryInstructions'],
          'lastUpdated': data['lastUpdated'],
          'phone': data['phone'],
          'phoneNumber': data['phoneNumber'],
          'createdAt': data['createdAt'] != null
              ? (data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.tryParse(data['createdAt'].toString()) ??
                      DateTime.now())
              : DateTime.now(),
          'items': data['items'] ?? [],
        };
      }).toList();

      // Charger TOUS les colis (même assignés)
      final parcelsSnapshot = await FirebaseFirestore.instance
          .collection('parcels')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> parcels = parcelsSnapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'type': 'parcel',
          'orderNumber': doc.id,
          'clientName':
              '${data['expediteurNom'] ?? 'Expéditeur'} → ${data['destinataireNom'] ?? 'Destinataire'}',
          'clientPhone': data['phoneNumber'] ?? 'Téléphone inconnu',
          'description': data['descriptionColis'] ?? 'Description inconnue',
          'totalAmount': (data['prix'] ?? 0.0).toDouble(),
          'status': data['status'] ?? 'reception',
          'pickupAddress':
              data['expediteurLieu'] ?? 'Adresse de collecte inconnue',
          'deliveryAddress':
              data['destinataireLieu'] ?? 'Adresse de livraison inconnue',
          'assignedTo': data['assignedTo'], // Téléphone du livreur assigné
          'assignedToName': data['assignedToName'], // Nom du livreur assigné
          'assignedAt': data['assignedAt'], // Date d'assignation
          'expediteurNom': data['expediteurNom'],
          'expediteurLieu': data['expediteurLieu'],
          'destinataireNom': data['destinataireNom'],
          'destinataireLieu': data['destinataireLieu'],
          'createdAt': data['createdAt'] != null
              ? (data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.tryParse(data['createdAt'].toString()) ??
                      DateTime.now())
              : DateTime.now(),
          'typeProduit': data['typeProduit'] ?? 'Type de produit inconnu',
        };
      }).toList();

      setState(() {
        // Séparer clairement les commandes et colis
        final allOrders = [
          ...restaurantOrders.map(
              (order) => {...order, 'displayType': '🍽️ Commande Restaurant'}),
          ...parcels.map((parcel) => {...parcel, 'displayType': '📦 Colis'}),
        ];

        orders = allOrders;
        orders.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
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

  List<Map<String, dynamic>> get filteredOrders {
    return orders.where((order) {
      // Recherche par nom client, téléphone, restaurant ou description
      final matchesSearch = searchQuery.isEmpty ||
          order['clientName']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          order['clientPhone'].toString().contains(searchQuery) ||
          (order['type'] == 'restaurant' &&
              order['restaurantName']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase())) ||
          (order['type'] == 'parcel' &&
              order['description']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()));

      // Filtrage par statut
      final matchesStatus =
          selectedStatus == 'all' || order['status'] == selectedStatus;

      // Filtrage par type (restaurant ou colis)
      final matchesType =
          selectedType == 'all' || order['type'] == selectedType;

      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  String getStatusText(String status) {
    switch (status) {
      case 'reception':
        return 'En réception';
      case 'assigned':
        return 'Assigné';
      case 'enRoute':
        return 'En route';
      case 'livre':
        return 'Livré';
      case 'nonLivre':
        return 'Non livré';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'reception':
        return Colors.orange;
      case 'assigned':
        return Colors.brown;
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

  void _showOrderDetails(Map<String, dynamic> order) {
    // Naviguer vers la page de détails appropriée
    if (order['type'] == 'restaurant' ||
        order['id']?.toString().startsWith('RESTO') == true) {
      // Commande restaurant
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailsFullPage(orderData: order),
        ),
      );
    } else {
      // Colis
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParcelDetailsFullPage(parcelData: order),
        ),
      );
    }
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
          'Gestion des Commandes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrders,
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
                    hintText: 'Rechercher une commande...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Filtres par statut et type
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: 'all', child: Text('Tous les statuts')),
                          const DropdownMenuItem(
                              value: 'reception', child: Text('En réception')),
                          const DropdownMenuItem(
                              value: 'enRoute', child: Text('En route')),
                          const DropdownMenuItem(
                              value: 'livre', child: Text('Livré')),
                          const DropdownMenuItem(
                              value: 'nonLivre', child: Text('Non livré')),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedStatus = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: 'all', child: Text('Tous les types')),
                          const DropdownMenuItem(
                              value: 'restaurant', child: Text('Restaurant')),
                          const DropdownMenuItem(
                              value: 'parcel', child: Text('Colis')),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedType = value!),
                      ),
                    ),
                  ],
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
                  orders.length.toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Restaurant',
                  orders
                      .where((o) => o['type'] == 'restaurant')
                      .length
                      .toString(),
                  Icons.restaurant,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Colis',
                  orders.where((o) => o['type'] == 'parcel').length.toString(),
                  Icons.local_shipping,
                  Colors.green,
                ),
                _buildStatCard(
                  'Livrés',
                  orders.where((o) => o['status'] == 'livre').length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Liste des commandes
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune commande trouvée',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return _buildOrderCard(order);
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: order['type'] == 'restaurant'
              ? Colors.orange[100]
              : Colors.green[100],
          child: Icon(
            order['type'] == 'restaurant'
                ? Icons.restaurant
                : Icons.local_shipping,
            size: 30,
            color: order['type'] == 'restaurant' ? Colors.orange : Colors.green,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['orderNumber'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    order['clientName'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: getStatusColor(order['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                getStatusText(order['status']),
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
                  order['clientPhone'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  order['type'] == 'restaurant'
                      ? Icons.restaurant
                      : Icons.local_shipping,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order['type'] == 'restaurant'
                        ? order['restaurantName']
                        : order['description'],
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order['deliveryAddress'],
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  '${order['totalAmount']} CFA',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${order['createdAt'].day}/${order['createdAt'].month}/${order['createdAt'].year}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            if (order['deliveryUserName'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.delivery_dining,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Livreur: ${order['deliveryUserName']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'details') {
              _showOrderDetails(order);
            } else if (value == 'assign') {
              // TODO: Navigation vers assignation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
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
            /*const PopupMenuItem(
              value: 'assign',
              child: Row(
                children: [
                  Icon(Icons.people, size: 20),
                  SizedBox(width: 8),
                  Text('Assigner'),
                ],
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
