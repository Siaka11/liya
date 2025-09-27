import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:intl/intl.dart';
import '../../../../core/ui/theme/theme.dart';
import '../../../../core/ui/components/custom_button.dart';
import '../../../../core/ui/components/notification_button.dart';
import '../../../../utils/snackbar.dart';
import '../../../../core/local_storage_factory.dart';
import 'dart:async';

// Import du provider qui fonctionne
import '../../application/home_delivery_provider.dart';
import '../../domain/entities/delivery_order.dart';
import 'order_details_page.dart';
import '../../../restaurant/features/order/presentation/pages/order_details_full_page.dart';
import '../../../parcel/feature/presentation/pages/parcel_details_full_page.dart';

@RoutePage()
class HomeDeliveryPage extends ConsumerStatefulWidget {
  const HomeDeliveryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeDeliveryPage> createState() => _HomeDeliveryPageState();
}

class _HomeDeliveryPageState extends ConsumerState<HomeDeliveryPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    print('🚀 HomeDeliveryPage initState() appelé');

    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 PostFrameCallback - Chargement automatique');
      ref.read(homeDeliveryProvider.notifier).refreshData();
    });

    // Rafraîchir les commandes assignées toutes les 10 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      print('⏰ Timer périodique - Rafraîchissement automatique');
      ref.read(homeDeliveryProvider.notifier).refreshData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(homeDeliveryProvider);
    final currentUser = deliveryState.currentUser;
    final assignedOrders = deliveryState.assignedOrders;
    final completedOrders = deliveryState.completedOrders;

    // Utiliser la vraie disponibilité du livreur
    final isAvailable = currentUser?.active ?? false;

    if (deliveryState.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF3ED),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (deliveryState.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF3ED),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                deliveryState.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(homeDeliveryProvider.notifier).clearError();
                  ref.read(homeDeliveryProvider.notifier).refreshData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF24E1E),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFFF24E1E)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Livreur',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('Connecté',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
/*            NotificationAppBarButton(
              backgroundColor: Colors.transparent,
              iconColor: Colors.white,
            ),*/
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.read(homeDeliveryProvider.notifier).refreshData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(homeDeliveryProvider.notifier).refreshData();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section d'informations du livreur
            _buildDriverInfoSection(),

            // Section de statut avec bouton disponibilité
            _buildStatusSection(isAvailable),

            // Section carte (seulement si en course)
            // if (isAvailable) _buildMapSection(),

            // Section des gains et statistiques
            //_buildEarningsSection(),

            // Section des commandes assignées
            _buildAssignedOrdersSection(assignedOrders),

            // Section des commandes restaurant
            _buildRestaurantOrdersSection(assignedOrders
                .where((order) => order.type == DeliveryType.restaurant)
                .toList()),

            // Section des colis
            _buildParcelOrdersSection(assignedOrders
                .where((order) => order.type == DeliveryType.parcel)
                .toList()),

            // Section des actions
            /*_buildActionsSection(),*/
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF24E1E),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bonjour, Livreur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'fr_FR')
                          .format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(bool isAvailable) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isAvailable ? Icons.check_circle : Icons.cancel,
                  color: isAvailable ? Colors.green : Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAvailable ? 'Disponible' : 'Indisponible',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      isAvailable
                          ? 'Prêt pour les livraisons'
                          : 'Non disponible pour les livraisons',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isAvailable,
                onChanged: (value) async {
                  print('🔄 Switch changé: $value');
                  // Utiliser la méthode qui fonctionne du homeDeliveryProvider
                  await ref
                      .read(homeDeliveryProvider.notifier)
                      .updateAvailability(value);

                  // Feedback visuel
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          value ? 'Livreur activé !' : 'Livreur désactivé !'),
                      backgroundColor: value ? Colors.green : Colors.orange,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                activeTrackColor: Colors.green.withOpacity(0.3),
                inactiveTrackColor: Colors.red.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(height: 16),
          /*Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isAvailable) {
                      // Utiliser le provider pour récupérer les commandes assignées
                      final orders =
                          ref.read(homeDeliveryProvider).assignedOrders;
                      if (orders.isNotEmpty) {
                        // Démarrer la première commande assignée
                        ref
                            .read(homeDeliveryProvider.notifier)
                            .startDelivery(orders.first);
                      }
                    }
                  },
                  icon: const Icon(Icons.directions_car),
                  label: const Text('En course'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),*/
        ],
      ),
    );
  }

  Widget _buildEarningsSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aujourd\'hui',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEarningsCard(
                  'Gains',
                  '0 FCFA',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEarningsCard(
                  'Livraisons',
                  '0',
                  Icons.local_shipping,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedOrdersSection(List<DeliveryOrder> assignedOrders) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commandes assignées (${assignedOrders.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (assignedOrders.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: Text(
                  'Aucune commande assignée pour le moment',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...assignedOrders.map((order) => _buildOrderCard(order)).toList(),
        ],
      ),
    );
  }

  Widget _buildRestaurantOrdersSection(List<DeliveryOrder> restaurantOrders) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Commandes Restaurant (${restaurantOrders.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (restaurantOrders.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: Text(
                  'Aucune commande restaurant assignée',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...restaurantOrders.map((order) => _buildOrderCard(order)).toList(),
        ],
      ),
    );
  }

  Widget _buildParcelOrdersSection(List<DeliveryOrder> parcelOrders) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Colis (${parcelOrders.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (parcelOrders.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: Text(
                  'Aucun colis assigné',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...parcelOrders.map((order) => _buildOrderCard(order)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderCard(DeliveryOrder order) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (order.status) {
      case DeliveryStatus.reception:
        statusColor = Colors.orange;
        statusText = 'Nouvelle livraison';
        statusIcon = Icons.assignment;
        break;
      case DeliveryStatus.assigned:
        statusColor = Colors.blue;
        statusText = 'Assigné';
        statusIcon = Icons.assignment_ind;
        break;
      case DeliveryStatus.enRoute:
        statusColor = Colors.purple;
        statusText = 'En cours de livraison';
        statusIcon = Icons.local_shipping;
        break;
      case DeliveryStatus.livre:
        statusColor = Colors.green;
        statusText = 'Livré';
        statusIcon = Icons.check_circle;
        break;
      case DeliveryStatus.nonLivre:
        statusColor = Colors.red;
        statusText = 'Non livré';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Statut inconnu';
        statusIcon = Icons.help;
    }

    return GestureDetector(
      onTap: () {
        // Naviguer vers les détails de la course
        _showOrderDetails(order);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  order.type == DeliveryType.restaurant
                      ? Icons.restaurant
                      : Icons.local_shipping,
                  color: const Color(0xFFF24E1E),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Commande ${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
                'Client', order.customerFullName ?? order.customerName),
            _buildDetailRow(' Téléphone', order.customerPhoneNumber),
            _buildDetailRow(' Adresse', order.customerAddress),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(DeliveryOrder order) {
    // Convertir DeliveryOrder en Map pour la page de détails complète
    final orderData = {
      'id': order.id,
      'phoneNumber': order.customerPhoneNumber,
      'phone': order.customerPhoneNumber,
      'customer_name': order.customerName,
      'address': order.customerAddress,
      'assignedTo': order.deliveryPhoneNumber,
      'assignedToName': order.deliveryName,
      'assignedAt': order.assignedAt?.toIso8601String(),
      'lastUpdated': order.assignedAt?.toIso8601String(),
      'createdAt': order.createdAt.toIso8601String(),
      'status': order.status.toString().split('.').last,
      'subtotal': order.amount,
      'deliveryFee': order.deliveryFee,
      'total': order.amount + order.deliveryFee,
      'deliveryTime': 10, // Valeur par défaut
      'distance': 0.0, // Valeur par défaut
      'items': [
        {
          'name': order.description,
          'price': order.amount,
          'quantity': 1,
        }
      ],
      'deliveryInstructions': null,
      'latitude': null,
      'longitude': null,
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => order.type == DeliveryType.restaurant
            ? OrderDetailsFullPage(orderData: orderData)
            : ParcelDetailsFullPage(parcelData: orderData),
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
            width: 80,
            child: Text(
              '$label',
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

  /*Widget _buildActionsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Test avec le numéro spécifique
                    _testWithSpecificNumber();
                  },
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Afficher le numéro du livreur connecté
                    _showConnectedDriverNumber();
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Mon numéro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }*/

  Widget _buildMapSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.map, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Carte de déplacement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 48,
                      color: Colors.blue.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Position en temps réel',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Partage de localisation actif',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'assigned':
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

  Future<void> _testWithSpecificNumber() async {
    try {
      print('🧪 Test - Chargement des commandes assignées');

      // Charger les vraies commandes assignées
      await ref.read(homeDeliveryProvider.notifier).refreshData();

      print('✅ Test - Commandes assignées chargées');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commandes assignées rechargées !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Erreur test: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _showConnectedDriverNumber() async {
    try {
      final localStorage = LocalStorageFactory();
      final userDetails = await localStorage.getUserDetails();
      final phoneNumber = userDetails['phoneNumber'] ?? '';

      print('📱 Numéro du livreur connecté: $phoneNumber');

      if (phoneNumber.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Votre numéro: $phoneNumber'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun numéro trouvé'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur récupération numéro: $e');
    }
  }
}
