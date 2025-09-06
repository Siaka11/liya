import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/local_storage_factory.dart';
import '../../../../core/ui/theme/theme.dart';
import '../../application/delivery_location_provider.dart';
import '../../data/services/delivery_location_service.dart';
import '../../domain/entities/delivery_user.dart';
import 'dart:async';

@RoutePage()
class DeliveryDashboardPage extends ConsumerStatefulWidget {
  const DeliveryDashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DeliveryDashboardPage> createState() =>
      _DeliveryDashboardPageState();
}

class _DeliveryDashboardPageState extends ConsumerState<DeliveryDashboardPage>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Position? _currentPosition;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    print('🚀 initState() appelé');

    _initializeAnimations();
    print('✅ Animations initialisées');

    _getCurrentLocation();
    print('✅ Position actuelle récupérée');

    // Test direct du provider
    print('🧪 Test du provider...');
    try {
      final provider = ref.read(deliveryLocationProvider.notifier);
      print('✅ Provider accessible: ${provider.runtimeType}');
    } catch (e) {
      print('❌ Erreur accès provider: $e');
    }

    // Charger les commandes assignées
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(
          '🔄 PostFrameCallback exécuté - Chargement des commandes assignées');
      try {
        ref.read(deliveryLocationProvider.notifier).loadAssignedOrders();
        print('✅ loadAssignedOrders() appelée avec succès');
      } catch (e) {
        print('❌ Erreur lors de l\'appel à loadAssignedOrders: $e');
      }
    });

    // Rafraîchir les commandes assignées toutes les 10 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      print('⏰ Timer périodique - Rafraîchissement des commandes assignées');
      try {
        ref.read(deliveryLocationProvider.notifier).loadAssignedOrders();
        print('✅ loadAssignedOrders() appelée par timer');
      } catch (e) {
        print('❌ Erreur lors de l\'appel à loadAssignedOrders par timer: $e');
      }
    });

    print('✅ Timer périodique configuré');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _updateMapMarkers();
    } catch (e) {
      print('Erreur obtention position: $e');
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

  Future<void> _testWithSpecificNumber() async {
    try {
      print('🧪 Test avec le numéro spécifique 0749856986');
      final testOrders = await DeliveryLocationService
          .testGetAssignedOrdersForSpecificDriver();

      if (testOrders.isNotEmpty) {
        print('✅ Test réussi: ${testOrders.length} commandes trouvées');
        // Mettre à jour le state avec les commandes de test
        ref
            .read(deliveryLocationProvider.notifier)
            .updateTestOrders(testOrders);
      } else {
        print('❌ Test échoué: Aucune commande trouvée');
      }
    } catch (e) {
      print('❌ Erreur test: $e');
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'assigned':
        return Colors.purple;
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

  void _updateMapMarkers() {
    _markers.clear();

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(
            title: 'Votre position',
            snippet: 'Position actuelle',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(deliveryLocationProvider);
    final locationNotifier = ref.read(deliveryLocationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Livreur'),
        backgroundColor: UIColors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Section de statut en ligne avec design Uber/Glovo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: locationState.isOnline
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.grey.shade300, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // Indicateur de statut
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: locationState.isOnline
                              ? _pulseAnimation.value
                              : 1.0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: locationState.isOnline
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              shape: BoxShape.circle,
                              boxShadow: locationState.isOnline
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locationState.isOnline ? 'EN LIGNE' : 'HORS LIGNE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: locationState.isOnline
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            locationState.isSharingLocation
                                ? 'Vous recevez des commandes'
                                : 'Activez-vous pour recevoir des commandes',
                            style: TextStyle(
                              fontSize: 14,
                              color: locationState.isOnline
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bouton principal comme Uber/Glovo
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (locationState.isSharingLocation) {
                        // Arrêter la course
                        await locationNotifier.deactivateDriver();
                      } else if (locationState.isOnline) {
                        // Déjà connecté, démarrer la course
                        await locationNotifier.activateDriver();
                      } else {
                        // Pas encore connecté, se connecter d'abord
                        await locationNotifier.connectDriver();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: locationState.isSharingLocation
                          ? Colors.red.shade600
                          : Colors.white,
                      foregroundColor: locationState.isSharingLocation
                          ? Colors.white
                          : UIColors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: locationState.isSharingLocation ? 8 : 4,
                    ),
                    child: locationState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                locationState.isSharingLocation
                                    ? Icons.stop_circle
                                    : locationState.isOnline
                                        ? Icons.play_circle_fill
                                        : Icons.power_settings_new,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                locationState.isSharingLocation
                                    ? 'ARRÊTER LA COURSE'
                                    : locationState.isOnline
                                        ? 'DÉMARRER LA COURSE'
                                        : 'SE CONNECTER',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Carte avec position actuelle
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude)
                        : const LatLng(
                            6.8270, -5.2890), // Yamoussoukro par défaut
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
            ),
          ),

          // Section des commandes assignées
          if (locationState.assignedOrders.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment, color: UIColors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Commandes assignées (${locationState.assignedOrders.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: UIColors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: locationState.assignedOrders.length,
                      itemBuilder: (context, index) {
                        final order = locationState.assignedOrders[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        order['type'] == 'restaurant'
                                            ? Icons.restaurant
                                            : Icons.inventory,
                                        color: UIColors.orange,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Commande #${order['id']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Client: ${order['customer_name'] ?? 'Inconnu'}',
                                    style: const TextStyle(fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Montant: ${order['amount']?.toStringAsFixed(0) ?? '0'} FCFA',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order['status']),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      order['status'] ?? 'enRoute',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Section des informations
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Statut actuel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: locationState.isSharingLocation
                        ? Colors.green.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: locationState.isSharingLocation
                          ? Colors.green.shade200
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        locationState.isSharingLocation
                            ? Icons.directions_car
                            : Icons.person,
                        color: locationState.isSharingLocation
                            ? Colors.green
                            : Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          locationState.isSharingLocation
                              ? '🟢 En course - Partage de position actif'
                              : '🔵 Disponible - Prêt à recevoir des commandes',
                          style: TextStyle(
                            color: locationState.isSharingLocation
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Indicateur des commandes assignées
                if (locationState.assignedOrders.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '📦 ${locationState.assignedOrders.length} commande(s) assignée(s)',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Informations du livreur
                if (locationState.currentDeliveryUser != null) ...[
                  _buildInfoCard(
                    icon: Icons.person,
                    title: 'Informations',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${locationState.currentDeliveryUser!.name} ${locationState.currentDeliveryUser!.lastname}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Livraisons complétées: ${locationState.currentDeliveryUser!.completedDeliveries}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Gains totaux: ${locationState.currentDeliveryUser!.totalEarnings.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Actions rapides
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Forcer le rafraîchissement des commandes assignées
                          ref
                              .read(deliveryLocationProvider.notifier)
                              .loadAssignedOrders();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualiser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIColors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Naviguer vers les commandes assignées
                        },
                        icon: const Icon(Icons.list_alt),
                        label: Text(
                            'Mes commandes (${locationState.assignedOrders.length})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIColors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
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
              Icon(icon, color: UIColors.orange),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
