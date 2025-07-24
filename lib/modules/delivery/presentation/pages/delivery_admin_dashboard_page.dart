import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/theme/theme.dart';
import '../../application/delivery_location_provider.dart';
import '../../domain/entities/delivery_user.dart';
import '../../data/services/delivery_location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryAdminDashboardPage extends ConsumerStatefulWidget {
  const DeliveryAdminDashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DeliveryAdminDashboardPage> createState() =>
      _DeliveryAdminDashboardPageState();
}

class _DeliveryAdminDashboardPageState
    extends ConsumerState<DeliveryAdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> pendingOrders = [];
  List<Map<String, dynamic>> pendingParcels = [];
  bool isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deliveryLocationProvider.notifier).loadAvailableDeliveryUsers();
      _loadPendingOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingOrders() async {
    setState(() {
      isLoadingOrders = true;
    });

    try {
      final orders = await DeliveryLocationService.getPendingRestaurantOrders();
      final parcels = await DeliveryLocationService.getPendingParcelOrders();

      setState(() {
        pendingOrders = orders;
        pendingParcels = parcels;
        isLoadingOrders = false;
      });
    } catch (e) {
      setState(() {
        isLoadingOrders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(deliveryLocationProvider);
    final locationNotifier = ref.read(deliveryLocationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Livraisons'),
        backgroundColor: UIColors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Commandes', icon: Icon(Icons.restaurant)),
            Tab(text: 'Colis', icon: Icon(Icons.inventory)),
            Tab(text: 'Livreurs', icon: Icon(Icons.people)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(deliveryLocationProvider.notifier)
                  .loadAvailableDeliveryUsers();
              _loadPendingOrders();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Commandes en attente
          _buildOrdersTab(locationNotifier),

          // Tab 2: Colis en attente
          _buildParcelsTab(locationNotifier),

          // Tab 3: Livreurs disponibles
          _buildDriversTab(locationState, locationNotifier),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(DeliveryLocationNotifier locationNotifier) {
    return Column(
      children: [
        // Header avec statistiques
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [UIColors.orange, UIColors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Commandes',
                      '${pendingOrders.length}',
                      Icons.restaurant,
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'En Attente',
                      '${pendingOrders.length}',
                      Icons.pending_actions,
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Liste des commandes
        Expanded(
          child: isLoadingOrders
              ? const Center(child: CircularProgressIndicator())
              : pendingOrders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Aucune commande en attente',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pendingOrders.length,
                      itemBuilder: (context, index) {
                        final order = pendingOrders[index];
                        return _buildOrderCard(order, locationNotifier);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildParcelsTab(DeliveryLocationNotifier locationNotifier) {
    return Column(
      children: [
        // Header avec statistiques
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [UIColors.orange, UIColors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Colis',
                      '${pendingParcels.length}',
                      Icons.inventory,
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'En Attente',
                      '${pendingParcels.length}',
                      Icons.pending_actions,
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Liste des colis
        Expanded(
          child: isLoadingOrders
              ? const Center(child: CircularProgressIndicator())
              : pendingParcels.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Aucun colis en attente',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pendingParcels.length,
                      itemBuilder: (context, index) {
                        final parcel = pendingParcels[index];
                        return _buildParcelCard(parcel, locationNotifier);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildDriversTab(DeliveryLocationState locationState,
      DeliveryLocationNotifier locationNotifier) {
    final drivers = locationState.availableDeliveryUsers;

    return Column(
      children: [
        // Header avec statistiques
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [UIColors.orange, UIColors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Livreurs',
                      '${drivers.length}',
                      Icons.people,
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'En Ligne',
                      '${drivers.where((d) => d.isOnline).length}',
                      Icons.circle,
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Liste des livreurs
        Expanded(
          child: drivers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucun livreur disponible',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driver = drivers[index];
                    return _buildDriverCard(driver, locationNotifier);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
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

  Widget _buildOrderCard(
      Map<String, dynamic> order, DeliveryLocationNotifier locationNotifier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: UIColors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commande #${order['id']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        order['customer_name'] ?? 'Client inconnu',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${order['amount']?.toStringAsFixed(0) ?? '0'} FCFA',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Adresse: ${order['customer_address'] ?? 'Non spécifiée'}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAssignOrderDialog(order, locationNotifier);
                },
                icon: const Icon(Icons.assignment),
                label: const Text('Assigner à un livreur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParcelCard(
      Map<String, dynamic> parcel, DeliveryLocationNotifier locationNotifier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: UIColors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Colis #${parcel['id']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        parcel['customer_name'] ?? 'Client inconnu',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Colis',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Adresse: ${parcel['customer_address'] ?? 'Non spécifiée'}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAssignParcelDialog(parcel, locationNotifier);
                },
                icon: const Icon(Icons.assignment),
                label: const Text('Assigner à un livreur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(
      DeliveryUser driver, DeliveryLocationNotifier locationNotifier) {
    final hasLocation =
        driver.currentLatitude != null && driver.currentLongitude != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // En-tête avec statut
            Row(
              children: [
                // Avatar du livreur
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      driver.isOnline ? Colors.green : Colors.grey.shade400,
                  child: Text(
                    '${driver.name[0]}${driver.lastname[0]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Informations du livreur
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${driver.name} ${driver.lastname}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driver.phoneNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            driver.isOnline
                                ? Icons.circle
                                : Icons.circle_outlined,
                            size: 12,
                            color: driver.isOnline ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            driver.isOnline ? 'En ligne' : 'Hors ligne',
                            style: TextStyle(
                              color:
                                  driver.isOnline ? Colors.green : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Indicateur de position
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasLocation
                        ? Colors.blue.shade100
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasLocation ? Icons.location_on : Icons.location_off,
                        size: 16,
                        color: hasLocation ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasLocation ? 'Position OK' : 'Pas de position',
                        style: TextStyle(
                          fontSize: 10,
                          color: hasLocation ? Colors.blue : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Statistiques du livreur
            Row(
              children: [
                Expanded(
                  child: _buildDriverStat(
                    'Livraisons',
                    '${driver.completedDeliveries}',
                    Icons.local_shipping,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDriverStat(
                    'Gains',
                    '${driver.totalEarnings.toStringAsFixed(0)} FCFA',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDriverStat(
                    'Note',
                    '${driver.averageRating.toStringAsFixed(1)}/5',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasLocation
                        ? () {
                            _showAssignToDriverDialog(driver, locationNotifier);
                          }
                        : null,
                    icon: const Icon(Icons.assignment),
                    label: const Text('Assigner une commande'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: UIColors.orange,
                      side: BorderSide(color: UIColors.orange),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasLocation
                        ? () {
                            _showDriverLocationMap(driver);
                          }
                        : null,
                    icon: const Icon(Icons.map),
                    label: const Text('Voir position'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasLocation
                        ? () {
                            _showDriverDetails(driver);
                          }
                        : null,
                    icon: const Icon(Icons.info),
                    label: const Text('Détails'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStat(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showAssignOrderDialog(
      Map<String, dynamic> order, DeliveryLocationNotifier locationNotifier) {
    final locationState = ref.watch(deliveryLocationProvider);
    final availableDrivers =
        locationState.availableDeliveryUsers.where((d) => d.isOnline).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assigner la commande #${order['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${order['customer_name'] ?? 'Inconnu'}'),
            Text('Adresse: ${order['customer_address'] ?? 'Non spécifiée'}'),
            Text('Montant: ${order['amount']?.toStringAsFixed(0) ?? '0'} FCFA'),
            const SizedBox(height: 16),
            if (availableDrivers.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aucun livreur en ligne disponible',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Choisissez un livreur en ligne :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: UIColors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    children: availableDrivers.map((driver) {
                      final hasLocation = driver.currentLatitude != null &&
                          driver.currentLongitude != null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                driver.isOnline ? Colors.green : Colors.grey,
                            child: Text(
                              '${driver.name[0]}${driver.lastname[0]}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text('${driver.name} ${driver.lastname}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driver.phoneNumber),
                              if (hasLocation) ...[
                                Text(
                                  'Position: ${driver.currentLatitude!.toStringAsFixed(4)}, ${driver.currentLongitude!.toStringAsFixed(4)}',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey[600]),
                                ),
                              ] else ...[
                                Text(
                                  'Position non disponible',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.orange),
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasLocation
                                    ? Icons.location_on
                                    : Icons.location_off,
                                color:
                                    hasLocation ? Colors.green : Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasLocation ? 'OK' : 'N/A',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: hasLocation
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: hasLocation
                              ? () {
                                  Navigator.pop(context);
                                  _assignOrderToSpecificDriver(
                                      order, driver, locationNotifier);
                                }
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          if (availableDrivers.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _assignOrderToNearestDriver(order, locationNotifier);
              },
              child: const Text('Assigner au plus proche'),
            ),
        ],
      ),
    );
  }

  void _assignOrderToSpecificDriver(
    Map<String, dynamic> order,
    DeliveryUser driver,
    DeliveryLocationNotifier locationNotifier,
  ) async {
    try {
      // Utiliser les coordonnées de la commande ou des coordonnées par défaut
      final lat = order['latitude']?.toDouble() ?? 6.8270;
      final lon = order['longitude']?.toDouble() ?? -5.2890;

      final success = await locationNotifier.assignOrderToSpecificDriver(
        order['id'],
        driver.phoneNumber,
        lat,
        lon,
      );

      if (success) {
        _showSuccessDialog(driver, order['id']);
        _loadPendingOrders();
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      print('❌ Erreur assignation spécifique: $e');
      _showErrorDialog();
    }
  }

  void _assignOrderToNearestDriver(
    Map<String, dynamic> order,
    DeliveryLocationNotifier locationNotifier,
  ) async {
    try {
      // Utiliser les coordonnées réelles de la commande
      final lat = order['latitude']?.toDouble();
      final lon = order['longitude']?.toDouble();

      if (lat == null || lon == null) {
        print(
            '❌ Coordonnées de destination manquantes pour la commande ${order['id']}');
        _showErrorDialog();
        return;
      }

      final assignedDriver = await locationNotifier.assignOrderToNearestDriver(
        order['id'],
        lat,
        lon,
      );

      if (assignedDriver != null) {
        _showSuccessDialog(assignedDriver, order['id']);
        _loadPendingOrders();
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      print('❌ Erreur assignation au plus proche: $e');
      _showErrorDialog();
    }
  }

  void _showAssignParcelDialog(
      Map<String, dynamic> parcel, DeliveryLocationNotifier locationNotifier) {
    final locationState = ref.watch(deliveryLocationProvider);
    final availableDrivers =
        locationState.availableDeliveryUsers.where((d) => d.isOnline).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assigner le colis #${parcel['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${parcel['customer_name'] ?? 'Inconnu'}'),
            Text('Adresse: ${parcel['customer_address'] ?? 'Non spécifiée'}'),
            const SizedBox(height: 16),
            if (availableDrivers.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aucun livreur en ligne disponible',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Choisissez un livreur en ligne :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: UIColors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    children: availableDrivers.map((driver) {
                      final hasLocation = driver.currentLatitude != null &&
                          driver.currentLongitude != null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                driver.isOnline ? Colors.green : Colors.grey,
                            child: Text(
                              '${driver.name[0]}${driver.lastname[0]}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text('${driver.name} ${driver.lastname}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driver.phoneNumber),
                              if (hasLocation) ...[
                                Text(
                                  'Position: ${driver.currentLatitude!.toStringAsFixed(4)}, ${driver.currentLongitude!.toStringAsFixed(4)}',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey[600]),
                                ),
                              ] else ...[
                                Text(
                                  'Position non disponible',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.orange),
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasLocation
                                    ? Icons.location_on
                                    : Icons.location_off,
                                color:
                                    hasLocation ? Colors.green : Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasLocation ? 'OK' : 'N/A',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: hasLocation
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: hasLocation
                              ? () {
                                  Navigator.pop(context);
                                  _assignParcelToSpecificDriver(
                                      parcel, driver, locationNotifier);
                                }
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          if (availableDrivers.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _assignParcelToNearestDriver(parcel, locationNotifier);
              },
              child: const Text('Assigner au plus proche'),
            ),
        ],
      ),
    );
  }

  void _assignParcelToSpecificDriver(
    Map<String, dynamic> parcel,
    DeliveryUser driver,
    DeliveryLocationNotifier locationNotifier,
  ) async {
    try {
      // Utiliser les coordonnées du colis ou des coordonnées par défaut
      final lat = parcel['latitude']?.toDouble() ?? 6.8270;
      final lon = parcel['longitude']?.toDouble() ?? -5.2890;

      final success = await locationNotifier.assignOrderToSpecificDriver(
        parcel['id'],
        driver.phoneNumber,
        lat,
        lon,
      );

      if (success) {
        _showSuccessDialog(driver, parcel['id']);
        _loadPendingOrders();
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      print('❌ Erreur assignation colis spécifique: $e');
      _showErrorDialog();
    }
  }

  void _assignParcelToNearestDriver(
    Map<String, dynamic> parcel,
    DeliveryLocationNotifier locationNotifier,
  ) async {
    try {
      // Utiliser les coordonnées réelles du colis
      final lat = parcel['latitude']?.toDouble();
      final lon = parcel['longitude']?.toDouble();

      if (lat == null || lon == null) {
        print(
            '❌ Coordonnées de destination manquantes pour le colis ${parcel['id']}');
        _showErrorDialog();
        return;
      }

      final assignedDriver = await locationNotifier.assignOrderToNearestDriver(
        parcel['id'],
        lat,
        lon,
      );

      if (assignedDriver != null) {
        _showSuccessDialog(assignedDriver, parcel['id']);
        _loadPendingOrders();
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      print('❌ Erreur assignation colis au plus proche: $e');
      _showErrorDialog();
    }
  }

  void _showSuccessDialog(DeliveryUser driver, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Assignation réussie'),
        content: Text(
            'Commande #$orderId assignée à ${driver.name} ${driver.lastname}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Erreur'),
        content: const Text('Aucun livreur disponible pour cette livraison'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAssignToDriverDialog(
      DeliveryUser driver, DeliveryLocationNotifier locationNotifier) {
    final orderIdController = TextEditingController();
    final latController = TextEditingController();
    final lonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assigner une commande à ${driver.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: orderIdController,
              decoration: const InputDecoration(
                labelText: 'ID de la commande',
                hintText: 'Ex: order_123',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude destination',
                      hintText: '6.8270',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: lonController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude destination',
                      hintText: '-5.2890',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Position du livreur: ${driver.currentLatitude?.toStringAsFixed(4)}, ${driver.currentLongitude?.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final orderId = orderIdController.text.trim();
              final lat = double.tryParse(latController.text);
              final lon = double.tryParse(lonController.text);

              if (orderId.isNotEmpty && lat != null && lon != null) {
                Navigator.pop(context);

                final assignedDriver =
                    await locationNotifier.assignOrderToNearestDriver(
                  orderId,
                  lat,
                  lon,
                );

                if (assignedDriver != null) {
                  _showSuccessDialog(assignedDriver, orderId);
                } else {
                  _showErrorDialog();
                }
              } else {
                _showValidationError();
              }
            },
            child: const Text('Assigner'),
          ),
        ],
      ),
    );
  }

  void _showDriverDetails(DeliveryUser driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de ${driver.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${driver.name} ${driver.lastname}'),
            Text('Téléphone: ${driver.phoneNumber}'),
            Text('Adresse: ${driver.address}'),
            Text('Livraisons complétées: ${driver.completedDeliveries}'),
            Text(
                'Gains totaux: ${driver.totalEarnings.toStringAsFixed(0)} FCFA'),
            Text('Note moyenne: ${driver.averageRating.toStringAsFixed(1)}/5'),
            if (driver.currentLatitude != null &&
                driver.currentLongitude != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Position actuelle:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Lat: ${driver.currentLatitude!.toStringAsFixed(4)}'),
              Text('Lon: ${driver.currentLongitude!.toStringAsFixed(4)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showValidationError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Erreur'),
        content: const Text('Veuillez remplir tous les champs correctement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDriverLocationMap(DeliveryUser driver) {
    if (driver.currentLatitude == null || driver.currentLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Position du livreur non disponible'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              // En-tête
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: UIColors.orange,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Position de ${driver.name} ${driver.lastname}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Carte
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      driver.currentLatitude!,
                      driver.currentLongitude!,
                    ),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(driver.phoneNumber),
                      position: LatLng(
                        driver.currentLatitude!,
                        driver.currentLongitude!,
                      ),
                      infoWindow: InfoWindow(
                        title: '${driver.name} ${driver.lastname}',
                        snippet: driver.isOnline ? 'En ligne' : 'Hors ligne',
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        driver.isOnline
                            ? BitmapDescriptor.hueGreen
                            : BitmapDescriptor.hueRed,
                      ),
                    ),
                  },
                  myLocationEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                ),
              ),

              // Informations
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations du livreur',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: UIColors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          driver.isOnline
                              ? Icons.circle
                              : Icons.circle_outlined,
                          size: 16,
                          color: driver.isOnline ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          driver.isOnline ? 'En ligne' : 'Hors ligne',
                          style: TextStyle(
                            color: driver.isOnline ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Téléphone: ${driver.phoneNumber}'),
                    const SizedBox(height: 4),
                    Text('Livraisons: ${driver.completedDeliveries}'),
                    const SizedBox(height: 4),
                    Text(
                        'Gains: ${driver.totalEarnings.toStringAsFixed(0)} FCFA'),
                    const SizedBox(height: 8),
                    Text(
                      'Coordonnées: ${driver.currentLatitude!.toStringAsFixed(4)}, ${driver.currentLongitude!.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
