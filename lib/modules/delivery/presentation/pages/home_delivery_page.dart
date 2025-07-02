import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/routes/app_router.gr.dart';
import '../../application/home_delivery_provider.dart';
import '../../domain/entities/delivery_order.dart';
import 'package:intl/intl.dart';

@RoutePage()
class HomeDeliveryPage extends ConsumerStatefulWidget {
  const HomeDeliveryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeDeliveryPage> createState() => _HomeDeliveryPageState();
}

class _HomeDeliveryPageState extends ConsumerState<HomeDeliveryPage> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeDeliveryProvider.notifier).refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(homeDeliveryProvider);
    final currentUser = deliveryState.currentUser;
    final assignedOrders = ref.watch(assignedOrdersProvider);
    final completedOrders = ref.watch(completedOrdersProvider);

    // Utiliser la vraie disponibilité du livreur
    final isAvailable = currentUser?.isAvailable ?? false;

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

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF3ED),
        body: Center(
          child: Text('Accès non autorisé - Vous devez être un livreur'),
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
                  Text('Livreur: ${currentUser.fullName}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                  Text('${currentUser.phoneNumber}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.notifications, color: Colors.white),
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
            // Carte des gains
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF24E1E),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('dd MMMM yyyy').format(DateTime.now()),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          currentUser.fullName,
                          style: const TextStyle(color: Color(0xFFF24E1E)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Votre gain du jour',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    '${deliveryState.todayEarnings.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Naviguer vers la page des gains détaillés
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFF24E1E),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Tous mes gains'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${currentUser.averageRating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
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
                      onChanged: (value) {
                        ref
                            .read(homeDeliveryProvider.notifier)
                            .updateAvailability(value);
                      },
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      activeTrackColor: Colors.green.withOpacity(0.3),
                      inactiveTrackColor: Colors.red.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistiques rapides
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'En cours',
                    assignedOrders.length.toString(),
                    Icons.local_shipping,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Terminées',
                    completedOrders.length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Livraisons en cours
            Row(
              children: [
                const Icon(Icons.local_shipping, color: Color(0xFFF24E1E)),
                const SizedBox(width: 8),
                const Text('Livraisons en cours',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF24E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assignedOrders.length.toString(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (assignedOrders.isEmpty) ...[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: const ListTile(
                  leading: Icon(Icons.inbox_outlined, color: Colors.grey),
                  title: Text('Aucune livraison en cours'),
                  subtitle: Text(
                      'Vous n\'avez pas de livraisons assignées pour le moment'),
                ),
              ),
            ] else ...[
              ...assignedOrders.map((order) => _buildOrderCard(order)),
            ],

            const SizedBox(height: 24),

            // Gains récents
            Row(
              children: [
                const Icon(Icons.history, color: Color(0xFFF24E1E)),
                const SizedBox(width: 8),
                const Text('Gains récents',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    completedOrders.length.toString(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (completedOrders.isEmpty) ...[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: const ListTile(
                  leading: Icon(Icons.history, color: Colors.grey),
                  title: Text('Aucun gain récent'),
                  subtitle:
                      Text('Vous n\'avez pas encore terminé de livraisons'),
                ),
              ),
            ] else ...[
              ...completedOrders
                  .take(5)
                  .map((order) => _buildCompletedOrderCard(order)),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFFF24E1E),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
        ],
        onTap: (index) {
          if (index == 0) {
            AutoRouter.of(context).replace(const HomeRoute());
          } else if (index == 1) {
            AutoRouter.of(context).replace(const ParcelHomeRoute());
          } else if (index == 2) {
            AutoRouter.of(context).replace(const HomeDeliveryRoute());
          }
        },
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
                fontSize: 24,
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
      case DeliveryStatus.enRoute:
        statusColor = Colors.blue;
        statusText = 'En cours de livraison';
        statusIcon = Icons.local_shipping;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Statut inconnu';
        statusIcon = Icons.help;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: order.type == DeliveryType.restaurant
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    order.type == DeliveryType.restaurant
                        ? Icons.restaurant
                        : Icons.local_shipping,
                    color: order.type == DeliveryType.restaurant
                        ? Colors.orange
                        : Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${order.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Client',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        order.customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        order.customerAddress,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Gain',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${order.deliveryFee.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (order.status == DeliveryStatus.reception) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(homeDeliveryProvider.notifier)
                            .startDelivery(order);
                      },
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Démarrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF24E1E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ] else if (order.status == DeliveryStatus.enRoute) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showDeliveryCompletionDialog(order);
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Terminer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(homeDeliveryProvider.notifier)
                            .failDelivery(order);
                      },
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Échec'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedOrderCard(DeliveryOrder order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            order.type == DeliveryType.restaurant
                ? Icons.restaurant
                : Icons.local_shipping,
            color: Colors.green,
          ),
        ),
        title: Text(
          order.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${order.id}'),
            Text(
              'Terminé le ${DateFormat('dd/MM/yyyy').format(order.completedAt ?? DateTime.now())}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${order.deliveryFee.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (order.rating != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 16),
                  Text(
                    order.rating!.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeliveryCompletionDialog(DeliveryOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la livraison'),
        content: Text(
          'Êtes-vous sûr de vouloir marquer cette livraison comme terminée ?\n\n'
          '${order.description}\n'
          'Client: ${order.customerName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(homeDeliveryProvider.notifier).completeDelivery(order);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
