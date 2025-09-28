import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@RoutePage()
class AssignmentManagementPage extends StatefulWidget {
  const AssignmentManagementPage({Key? key}) : super(key: key);

  @override
  State<AssignmentManagementPage> createState() =>
      _AssignmentManagementPageState();
}

class _AssignmentManagementPageState extends State<AssignmentManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _pendingOrders = [];
  List<Map<String, dynamic>> _pendingParcels = [];
  List<Map<String, dynamic>> _deliveryUsers = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Charger les commandes en attente (nourritures)
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('status', whereIn: [
            'pending',
            'confirmed',
            'preparing',
            'reception',
            'enRoute'
          ])
          .orderBy('createdAt', descending: true)
          .get();

      final orders = ordersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'type': 'order',
          'orderNumber': doc.id,
          'customerName':
              data['delivery_name'] ?? data['phoneNumber'] ?? 'Client inconnu',
          'customerAddress': data['address'] ?? 'Adresse non spécifiée',
          'total': data['total'] ?? data['totalAmount'] ?? 0.0,
          'status': data['status'] ?? 'pending',
          'createdAt': data['createdAt'] != null
              ? (data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.tryParse(data['createdAt'].toString()) ??
                      DateTime.now())
              : DateTime.now(),
          'assignedTo': data['assignedTo'] ?? data['deliveryUserId'],
          'restaurantName': data['restaurantName'] ?? 'Restaurant inconnu',
        };
      }).toList();

      // Charger les colis en attente
      final parcelsSnapshot = await _firestore
          .collection('parcels')
          .where('status', whereIn: ['reception', 'enRoute', 'pickup'])
          .orderBy('createdAt', descending: true)
          .get();

      final parcels = parcelsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'type': 'parcel',
          'orderNumber': doc.id,
          'expediteurNom': data['expediteurNom'] ?? 'Expéditeur inconnu',
          'destinataireNom': data['destinataireNom'] ?? 'Destinataire inconnu',
          'expediteurLieu': data['expediteurLieu'] ?? 'Lieu non spécifié',
          'destinataireLieu': data['destinataireLieu'] ?? 'Lieu non spécifié',
          'status': data['status'] ?? 'reception',
          'createdAt': data['createdAt'] != null
              ? (data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.tryParse(data['createdAt'].toString()) ??
                      DateTime.now())
              : DateTime.now(),
          'assignedTo': data['assignedTo'],
        };
      }).toList();

      // Charger les livreurs disponibles
      final deliverySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'livreur')
          .get();

      final deliveryUsers = deliverySnapshot.docs.map((doc) {
        final data = doc.data();
        print(
            'DEBUG: Livreur trouvé - ID: ${doc.id}, Role: ${data['role']}, Name: ${data['name']}');
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Livreur inconnu',
          'phoneNumber': data['phoneNumber'] ?? '',
          'isAvailable': data['isAvailable'] ?? true,
          'currentLocation': data['currentLocation'],
        };
      }).toList();

      print('DEBUG: Nombre de livreurs trouvés: ${deliveryUsers.length}');

      print('DEBUG: Commandes trouvées: ${orders.length}');
      print('DEBUG: Colis trouvés: ${parcels.length}');

      setState(() {
        _pendingOrders = orders;
        _pendingParcels = parcels;
        _deliveryUsers = deliveryUsers;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des assignations: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredItems {
    final allItems = [..._pendingOrders, ..._pendingParcels];

    if (_selectedFilter == 'Tous') return allItems;
    if (_selectedFilter == 'Commandes') return _pendingOrders;
    if (_selectedFilter == 'Colis') return _pendingParcels;

    return allItems;
  }

  Future<void> _assignToDelivery(
      Map<String, dynamic> item, Map<String, dynamic> deliveryUser) async {
    try {
      final collection = item['type'] == 'order' ? 'orders' : 'parcels';
      final status = item['type'] == 'order' ? 'assigned' : 'assigned';

      // Vérifier que l'élément n'est pas déjà assigné
      if (item['assignedTo'] != null && item['assignedTo'].isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${item['type'] == 'order' ? 'La commande' : 'Le colis'} est déjà assigné'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Mettre à jour l'assignation
      await _firestore.collection(collection).doc(item['id']).update({
        'assignedTo': deliveryUser['phoneNumber'],
        'assignedToName': deliveryUser['name'],
        'status': status,
        'assignedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Envoyer une notification au livreur
      await _sendAssignmentNotification(item, deliveryUser);

      _loadData(); // Recharger les données

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${item['type'] == 'order' ? 'Commande' : 'Colis'} assigné à ${deliveryUser['name']}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'assignation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendAssignmentNotification(
      Map<String, dynamic> item, Map<String, dynamic> deliveryUser) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': deliveryUser['phoneNumber'],
        'title': 'Nouvelle assignation',
        'body':
            'Vous avez été assigné à une ${item['type'] == 'order' ? 'commande' : 'livraison de colis'}',
        'type': 'assignment',
        'itemId': item['id'],
        'itemType': item['type'],
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification: $e');
    }
  }

  Future<void> _showAssignmentDialog(Map<String, dynamic> item) async {
    final availableDeliveryUsers =
        _deliveryUsers.where((user) => user['isAvailable'] == true).toList();

    if (availableDeliveryUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun livreur disponible'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Assigner ${item['type'] == 'order' ? 'la commande' : 'le colis'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item['type'] == 'order'
                  ? '${item['customerName']} - ${item['customerAddress']}'
                  : '${item['expediteurNom']} → ${item['destinataireNom']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Sélectionner un livreur:'),
            const SizedBox(height: 8),
            ...availableDeliveryUsers.map((user) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user['name']),
                  subtitle: Text(user['phoneNumber']),
                  onTap: () {
                    Navigator.of(context).pop();
                    _assignToDelivery(item, user);
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Assignations'),
        backgroundColor: const Color(0xFFF24E1E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtres
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('Filtrer par: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedFilter,
                        items: ['Tous', 'Commandes', 'Colis'].map((filter) {
                          return DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Statistiques
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildStatCard('En attente',
                          _filteredItems.length.toString(), Colors.orange),
                      const SizedBox(width: 12),
                      _buildStatCard('Commandes',
                          _pendingOrders.length.toString(), Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatCard('Colis', _pendingParcels.length.toString(),
                          Colors.green),
                      const SizedBox(width: 12),
                      _buildStatCard('Livreurs',
                          _deliveryUsers.length.toString(), Colors.purple),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Liste des items en attente
                Expanded(
                  child: _filteredItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun élément en attente d\'assignation',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return _buildItemCard(item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
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
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final isOrder = item['type'] == 'order';
    final isAssigned = item['assignedTo'] != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOrder ? Icons.restaurant : Icons.local_shipping,
                  color: isOrder ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOrder ? 'Commande' : 'Colis',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item['orderNumber'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAssigned
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAssigned ? 'Assigné' : 'En attente',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAssigned ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isOrder) ...[
              Text('Client: ${item['customerName']}'),
              Text('Adresse: ${item['customerAddress']}'),
              Text('Total: ${item['total']} FCFA'),
            ] else ...[
              Text('De: ${item['expediteurNom']}'),
              Text('À: ${item['destinataireNom']}'),
              Text(
                  'Lieu: ${item['expediteurLieu']} → ${item['destinataireLieu']}'),
            ],
            if (isAssigned) ...[
              const SizedBox(height: 8),
              Text(
                'Assigné à: ${item['assignedToName'] ?? 'Livreur'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (!isAssigned)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showAssignmentDialog(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF24E1E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Assigner à un livreur'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
