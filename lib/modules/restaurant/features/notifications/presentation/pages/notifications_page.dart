import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/core/services/notification_service.dart';

@RoutePage()
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'default_user';

      // Récupérer les notifications depuis Firestore
      final notificationsSnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      setState(() {
        _notifications = notificationsSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});

      // Mettre à jour la liste locale
      setState(() {
        final index =
            _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          _notifications[index]['read'] = true;
        }
      });
    } catch (e) {
      print('❌ Erreur marquer comme lu: $e');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();

      // Mettre à jour la liste locale
      setState(() {
        _notifications.removeWhere((n) => n['id'] == notificationId);
      });
    } catch (e) {
      print('❌ Erreur suppression notification: $e');
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order_assigned':
        return Colors.blue;
      case 'delivery_started':
        return Colors.orange;
      case 'delivery_completed':
        return Colors.green;
      case 'new_restaurant_order':
        return Colors.purple;
      case 'new_parcel':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order_assigned':
        return Icons.assignment;
      case 'delivery_started':
        return Icons.delivery_dining;
      case 'delivery_completed':
        return Icons.check_circle;
      case 'new_restaurant_order':
        return Icons.restaurant;
      case 'new_parcel':
        return Icons.local_shipping;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'order_assigned':
        return 'Commande assignée';
      case 'delivery_started':
        return 'Livraison en cours';
      case 'delivery_completed':
        return 'Livraison terminée';
      case 'new_restaurant_order':
        return 'Nouvelle commande';
      case 'new_parcel':
        return 'Nouveau colis';
      default:
        return 'Notification';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: UIColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous recevrez des notifications ici\nquand vous passerez des commandes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          final isRead = notification['read'] ?? false;
          final type = notification['type'] ?? 'unknown';
          final title = notification['title'] ?? _getNotificationTitle(type);
          final body = notification['body'] ?? '';
          final createdAt = notification['createdAt'] as Timestamp?;
          final orderId = notification['orderId'];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isRead ? 1 : 3,
            color: isRead ? Colors.white : Colors.blue[50],
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getNotificationColor(type),
                child: Icon(
                  _getNotificationIcon(type),
                  color: Colors.white,
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  color: isRead ? Colors.grey[600] : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    body,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(createdAt.toDate()),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'mark_read' && !isRead) {
                    _markAsRead(notification['id']);
                  } else if (value == 'delete') {
                    _deleteNotification(notification['id']);
                  }
                },
                itemBuilder: (context) => [
                  if (!isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 20),
                          SizedBox(width: 8),
                          Text('Marquer comme lu'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                if (!isRead) {
                  _markAsRead(notification['id']);
                }
                // TODO: Navigation vers la page appropriée selon le type
                if (orderId != null) {
                  // Naviguer vers la page de détail de commande
                }
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}
