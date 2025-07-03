import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../application/delivery_provider.dart';
import '../../domain/entities/delivery_order.dart';
import '../../../../core/ui/theme/theme.dart';
import '../../../../core/ui/components/custom_button.dart';
import '../../../../utils/snackbar.dart';

@RoutePage()
class DeliveryDashboardPage extends ConsumerStatefulWidget {
  const DeliveryDashboardPage({super.key});

  @override
  ConsumerState<DeliveryDashboardPage> createState() =>
      _DeliveryDashboardPageState();
}

class _DeliveryDashboardPageState extends ConsumerState<DeliveryDashboardPage>
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
    final deliveryState = ref.watch(deliveryProvider);
    final currentUser = deliveryState.currentUser;

    if (deliveryState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (deliveryState.error != null) {
      return Scaffold(
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
              CustomButton(
                onPressedButton: () {
                  ref.read(deliveryProvider.notifier).clearError();
                  ref.read(deliveryProvider.notifier).refreshData();
                },
                text: 'Réessayer',
                borderRadius: 12,
                fontSize: 16,
                paddingVertical: 12,
              ),
            ],
          ),
        ),
      );
    }

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Accès non autorisé'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Livreur'),
        backgroundColor: UIColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(deliveryProvider.notifier).refreshData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec informations du livreur
          _buildDeliveryUserHeader(currentUser),

          // Onglets
          Container(
            color: Colors.grey[100],
            child: TabBar(
              controller: _tabController,
              labelColor: UIColors.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: UIColors.primary,
              tabs: const [
                Tab(text: 'Commandes', icon: Icon(Icons.list)),
                Tab(text: 'En cours', icon: Icon(Icons.delivery_dining)),
                Tab(text: 'Historique', icon: Icon(Icons.history)),
              ],
            ),
          ),

          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingOrdersTab(),
                _buildAssignedOrdersTab(),
                _buildCompletedOrdersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryUserHeader(deliveryUser) {
    final deliveryState = ref.watch(deliveryProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  deliveryUser.name.isNotEmpty
                      ? deliveryUser.name[0].toUpperCase()
                      : 'L',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: UIColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deliveryUser.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deliveryUser.phoneNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: deliveryUser.isAvailable,
                onChanged: (value) {
                  ref.read(deliveryProvider.notifier).updateAvailability(value);
                },
                activeColor: Colors.green,
                activeTrackColor: Colors.green[200],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Gains du jour',
                '${deliveryState.todayEarnings.toStringAsFixed(0)} FCFA',
                Icons.today,
                Colors.green,
              ),
              _buildStatCard(
                'Gains de la semaine',
                '${deliveryState.weekEarnings.toStringAsFixed(0)} FCFA',
                Icons.calendar_view_week,
                Colors.blue,
              ),
              _buildStatCard(
                'Livraisons',
                '${deliveryUser.completedDeliveries}',
                Icons.local_shipping,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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
    );
  }

  Widget _buildPendingOrdersTab() {
    final pendingOrders = ref.watch(pendingOrdersProvider);

    if (pendingOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune commande en attente',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(deliveryProvider.notifier).refreshData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingOrders.length,
        itemBuilder: (context, index) {
          final order = pendingOrders[index];
          return _buildOrderCard(order, showAcceptButton: true);
        },
      ),
    );
  }

  Widget _buildAssignedOrdersTab() {
    final assignedOrders = ref.watch(assignedOrdersProvider);

    if (assignedOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delivery_dining_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune commande assignée',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(deliveryProvider.notifier).refreshData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignedOrders.length,
        itemBuilder: (context, index) {
          final order = assignedOrders[index];
          return _buildOrderCard(order, showActionButtons: true);
        },
      ),
    );
  }

  Widget _buildCompletedOrdersTab() {
    final completedOrders = ref.watch(completedOrdersProvider);

    if (completedOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune livraison terminée',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(deliveryProvider.notifier).refreshData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: completedOrders.length,
        itemBuilder: (context, index) {
          final order = completedOrders[index];
          return _buildOrderCard(order, showCompletedInfo: true);
        },
      ),
    );
  }

  Widget _buildOrderCard(
    DeliveryOrder order, {
    bool showAcceptButton = false,
    bool showActionButtons = false,
    bool showCompletedInfo = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.type == DeliveryType.restaurant
                        ? Colors.orange[100]
                        : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.type == DeliveryType.restaurant
                        ? 'Restaurant'
                        : 'Colis',
                    style: TextStyle(
                      color: order.type == DeliveryType.restaurant
                          ? Colors.orange[800]
                          : Colors.blue[800],
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
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Client', order.customerName),
            _buildInfoRow('Téléphone', order.customerPhoneNumber),
            _buildInfoRow('Adresse', order.customerAddress),
            _buildInfoRow('Montant', '${order.amount.toStringAsFixed(0)} FCFA'),
            _buildInfoRow('Frais de livraison',
                '${order.deliveryFee.toStringAsFixed(0)} FCFA'),
            _buildInfoRow(
                'Total', '${order.totalAmount.toStringAsFixed(0)} FCFA'),
            if (showCompletedInfo && order.rating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Note: ${order.rating!.toStringAsFixed(1)}/5',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            if (showAcceptButton) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressedButton: () {
                    ref.read(deliveryProvider.notifier).acceptOrder(order);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Commande acceptée avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  text: 'Accepter la commande',
                  borderRadius: 12,
                  fontSize: 16,
                  paddingVertical: 12,
                ),
              ),
            ],
            if (showActionButtons) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressedButton: order.status == DeliveryStatus.reception
                          ? () {
                              ref
                                  .read(deliveryProvider.notifier)
                                  .startDelivery(order);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Livraison démarrée'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            }
                          : null,
                      text: 'Démarrer',
                      borderRadius: 12,
                      fontSize: 14,
                      paddingVertical: 12,
                      bgColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      onPressedButton: order.status == DeliveryStatus.enRoute
                          ? () {
                              ref
                                  .read(deliveryProvider.notifier)
                                  .completeDelivery(order);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Livraison terminée'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          : null,
                      text: 'Terminer',
                      borderRadius: 12,
                      fontSize: 14,
                      paddingVertical: 12,
                      bgColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.reception:
        return Colors.orange;
      case DeliveryStatus.enRoute:
        return Colors.blue;
      case DeliveryStatus.livre:
        return Colors.green;
      case DeliveryStatus.nonLivre:
        return Colors.red;
    }
  }

  String _getStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.reception:
        return 'En attente';
      case DeliveryStatus.enRoute:
        return 'En cours';
      case DeliveryStatus.livre:
        return 'Terminée';
      case DeliveryStatus.nonLivre:
        return 'Échouée';
    }
  }
}
