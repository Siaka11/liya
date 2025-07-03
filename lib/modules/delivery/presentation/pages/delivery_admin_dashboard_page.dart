import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../application/delivery_admin_existing_provider.dart';
import '../../domain/entities/delivery_order.dart';
import '../../domain/entities/delivery_user.dart';
import '../../../../core/ui/theme/theme.dart';
import '../../../../core/ui/components/custom_button.dart';

@RoutePage()
class DeliveryAdminDashboardPage extends ConsumerStatefulWidget {
  const DeliveryAdminDashboardPage({super.key});

  @override
  ConsumerState<DeliveryAdminDashboardPage> createState() =>
      _DeliveryAdminDashboardPageState();
}

class _DeliveryAdminDashboardPageState
    extends ConsumerState<DeliveryAdminDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Gestion des Livraisons',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: UIColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(deliveryAdminExistingProvider.notifier).refreshData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Onglets modernes
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: UIColors.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: UIColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.restaurant),
                  text: 'Commandes Restaurant',
                ),
                Tab(
                  icon: Icon(Icons.local_shipping),
                  text: 'Colis',
                ),
                Tab(
                  icon: Icon(Icons.assignment),
                  text: 'Livraisons Assignées',
                ),
              ],
            ),
          ),

          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRestaurantOrdersTab(),
                _buildParcelOrdersTab(),
                _buildAssignedDeliveriesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantOrdersTab() {
    final pendingOrders = ref.watch(pendingRestaurantOrdersProvider);
    final adminState = ref.watch(deliveryAdminExistingProvider);

    if (adminState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(UIColors.primary),
        ),
      );
    }

    if (pendingOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.restaurant_outlined,
        title: 'Aucune commande en attente',
        subtitle: 'Toutes les commandes ont été assignées',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(deliveryAdminExistingProvider.notifier).refreshData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingOrders.length,
        itemBuilder: (context, index) {
          final order = pendingOrders[index];
          return _buildOrderCard(order, true);
        },
      ),
    );
  }

  Widget _buildParcelOrdersTab() {
    final pendingOrders = ref.watch(pendingParcelOrdersProvider);
    final adminState = ref.watch(deliveryAdminExistingProvider);

    if (adminState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(UIColors.primary),
        ),
      );
    }

    if (pendingOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'Aucun colis en attente',
        subtitle: 'Tous les colis ont été assignés',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(deliveryAdminExistingProvider.notifier).refreshData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingOrders.length,
        itemBuilder: (context, index) {
          final order = pendingOrders[index];
          return _buildOrderCard(order, false);
        },
      ),
    );
  }

  Widget _buildAssignedDeliveriesTab() {
    final assignedRestaurantOrders =
        ref.watch(assignedRestaurantOrdersProvider);
    final assignedParcelOrders = ref.watch(assignedParcelOrdersProvider);
    final adminState = ref.watch(deliveryAdminExistingProvider);

    if (adminState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(UIColors.primary),
        ),
      );
    }

    final allAssignedOrders = [
      ...assignedRestaurantOrders,
      ...assignedParcelOrders
    ];

    if (allAssignedOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'Aucune livraison assignée',
        subtitle: 'Toutes les livraisons sont en cours de traitement',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(deliveryAdminExistingProvider.notifier).refreshData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allAssignedOrders.length,
        itemBuilder: (context, index) {
          final order = allAssignedOrders[index];
          return _buildAssignedOrderCard(order);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(DeliveryOrder order, bool isRestaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showOrderDetails(order, isRestaurant),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isRestaurant ? Colors.orange : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isRestaurant ? 'Restaurant' : 'Colis',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'En attente',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                order.description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.customerAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: UIColors.primary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showDeliveryUserSelection(order, isRestaurant),
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Assigner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignedOrderCard(DeliveryOrder order) {
    final isRestaurant = order.type == DeliveryType.restaurant;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showAssignedOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isRestaurant ? Colors.orange : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isRestaurant ? 'Restaurant' : 'Colis',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'En cours',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                order.description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.delivery_dining,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Livreur: ${order.deliveryName ?? 'Non assigné'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              if (order.deliveryPhoneNumber != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Tél: ${order.deliveryPhoneNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: UIColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showReassignmentDialog(order),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: const Text('Changer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showAssignedOrderDetails(order),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Détails'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(DeliveryOrder order, bool isRestaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailsModal(order, isRestaurant),
    );
  }

  Widget _buildOrderDetailsModal(DeliveryOrder order, bool isRestaurant) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isRestaurant ? Colors.orange : Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isRestaurant ? 'Commande Restaurant' : 'Colis',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'En attente d\'assignation',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Client info
                  _buildDetailSection(
                    'Informations Client',
                    [
                      _buildDetailRow('Nom', order.customerName),
                      _buildDetailRow('Téléphone', order.customerPhoneNumber),
                      _buildDetailRow('Adresse', order.customerAddress),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Financial info
                  _buildDetailSection(
                    'Informations Financières',
                    [
                      _buildDetailRow(
                          'Montant', '${order.amount.toStringAsFixed(0)} FCFA'),
                      _buildDetailRow('Frais de livraison',
                          '${order.deliveryFee.toStringAsFixed(0)} FCFA'),
                      _buildDetailRow('Total',
                          '${order.totalAmount.toStringAsFixed(0)} FCFA',
                          isTotal: true),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Assign button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeliveryUserSelection(order, isRestaurant);
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Assigner à un livreur'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? UIColors.primary : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeliveryUserSelection(DeliveryOrder order, bool isRestaurant) {
    final availableUsers = ref.read(availableDeliveryUsersProvider);

    if (availableUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Aucun livreur disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildDeliveryUserSelectionModal(order, availableUsers, isRestaurant),
    );
  }

  Widget _buildDeliveryUserSelectionModal(
    DeliveryOrder order,
    List<DeliveryUser> availableUsers,
    bool isRestaurant,
  ) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sélectionner un livreur',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choisissez un livreur pour assigner cette ${isRestaurant ? 'commande' : 'colis'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: availableUsers.length,
              itemBuilder: (context, index) {
                final user = availableUsers[index];
                return _buildDeliveryUserOption(order, user, isRestaurant);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryUserOption(
    DeliveryOrder order,
    DeliveryUser user,
    bool isRestaurant,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _assignOrderToUser(order, user, isRestaurant);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: UIColors.primary,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'L',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          user.phoneNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${user.completedDeliveries} livraisons - ${user.totalEarnings.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _assignOrderToUser(
      DeliveryOrder order, DeliveryUser user, bool isRestaurant) {
    try {
      if (isRestaurant) {
        ref
            .read(deliveryAdminExistingProvider.notifier)
            .assignRestaurantOrderToDeliveryUser(order, user);
      } else {
        ref
            .read(deliveryAdminExistingProvider.notifier)
            .assignParcelToDeliveryUser(order, user);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${isRestaurant ? 'Commande' : 'Colis'} assigné(e) à ${user.fullName}',
          ),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Voir',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Naviguer vers la page de suivi des livraisons
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de l\'assignation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReassignmentDialog(DeliveryOrder order) {
    final availableUsers = ref.read(availableDeliveryUsersProvider);
    final currentDeliveryUser = availableUsers.firstWhere(
      (user) => user.phoneNumber == order.deliveryPhoneNumber,
      orElse: () => DeliveryUser(
        id: '',
        phoneNumber: '',
        name: '',
        lastname: '',
        email: '',
        address: '',
        phone: '',
        createdAt: DateTime.now(),
        role: '',
      ),
    );

    // Filtrer pour exclure le livreur actuel
    final otherUsers = availableUsers
        .where(
          (user) => user.phoneNumber != order.deliveryPhoneNumber,
        )
        .toList();

    if (otherUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Aucun autre livreur disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer de livreur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Livreur actuel: ${currentDeliveryUser.fullName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Sélectionner un nouveau livreur:'),
            const SizedBox(height: 8),
            ...otherUsers.map((user) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: UIColors.primary,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'L',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user.fullName),
                  subtitle: Text(user.phoneNumber),
                  onTap: () {
                    Navigator.pop(context);
                    _reassignOrder(order, user);
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _reassignOrder(DeliveryOrder order, DeliveryUser newUser) {
    try {
      if (order.type == DeliveryType.restaurant) {
        ref
            .read(deliveryAdminExistingProvider.notifier)
            .reassignRestaurantOrder(order, newUser);
      } else {
        ref
            .read(deliveryAdminExistingProvider.notifier)
            .reassignParcel(order, newUser);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Livraison réassignée à ${newUser.fullName}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de la réassignation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAssignedOrderDetails(DeliveryOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAssignedOrderDetailsModal(order),
    );
  }

  Widget _buildAssignedOrderDetailsModal(DeliveryOrder order) {
    final isRestaurant = order.type == DeliveryType.restaurant;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isRestaurant ? Colors.orange : Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isRestaurant ? 'Commande Restaurant' : 'Colis',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'En cours de livraison',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Client info
                  _buildDetailSection(
                    'Informations Client',
                    [
                      _buildDetailRow('Nom', order.customerName),
                      _buildDetailRow('Téléphone', order.customerPhoneNumber),
                      _buildDetailRow('Adresse', order.customerAddress),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Delivery info
                  _buildDetailSection(
                    'Informations Livreur',
                    [
                      _buildDetailRow(
                          'Nom', order.deliveryName ?? 'Non assigné'),
                      _buildDetailRow('Téléphone',
                          order.deliveryPhoneNumber ?? 'Non assigné'),
                      if (order.assignedAt != null)
                        _buildDetailRow(
                            'Assigné le', _formatDate(order.assignedAt!)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Financial info
                  _buildDetailSection(
                    'Informations Financières',
                    [
                      _buildDetailRow(
                          'Montant', '${order.amount.toStringAsFixed(0)} FCFA'),
                      _buildDetailRow('Frais de livraison',
                          '${order.deliveryFee.toStringAsFixed(0)} FCFA'),
                      _buildDetailRow('Total',
                          '${order.totalAmount.toStringAsFixed(0)} FCFA',
                          isTotal: true),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showReassignmentDialog(order);
                          },
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Changer de livreur'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
