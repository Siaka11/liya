import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../../services/notification_service.dart';

class NotificationsPage extends ConsumerWidget {
  final String userPhone;
  final String userRole;

  const NotificationsPage({
    Key? key,
    required this.userPhone,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Utiliser le provider approprié selon le rôle
    final notificationsAsync = userRole == 'admin'
        ? ref.watch(roleNotificationsProvider(userRole))
        : ref.watch(userNotificationsProvider(userPhone));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: notificationsAsync.when(
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isRead = data['read'] ?? false;
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: isRead ? Colors.white : Colors.blue.shade50,
                child: ListTile(
                  leading: _getNotificationIcon(data['type']),
                  title: Text(
                    data['title'] ?? '',
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['body'] ?? ''),
                      if (createdAt != null)
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  trailing: !isRead
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  onTap: () {
                    // Marquer comme lue
                    if (!isRead) {
                      ref.read(markNotificationAsReadProvider(doc.id));
                    }

                    // Naviguer selon le type de notification
                    _handleNotificationTap(context, data);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String? type) {
    switch (type) {
      case 'new_order':
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.restaurant, color: Colors.white),
        );
      case 'new_parcel':
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.local_shipping, color: Colors.white),
        );
      case 'order_assigned':
      case 'parcel_assigned':
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.assignment, color: Colors.white),
        );
      case 'delivery_started':
        return const CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.directions_car, color: Colors.white),
        );
      case 'delivery_completed':
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check_circle, color: Colors.white),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.notifications, color: Colors.white),
        );
    }
  }

  void _handleNotificationTap(BuildContext context, Map<String, dynamic> data) {
    final type = data['type'];

    switch (type) {
      case 'new_order':
      case 'order_assigned':
        // Naviguer vers la page des commandes
        // context.router.push(OrdersRoute());
        break;
      case 'new_parcel':
      case 'parcel_assigned':
        // Naviguer vers la page des colis
        // context.router.push(ParcelsRoute());
        break;
      case 'delivery_started':
      case 'delivery_completed':
        // Naviguer vers le suivi de livraison
        // context.router.push(DeliveryTrackingRoute(orderId: data['orderId']));
        break;
    }
  }
}
