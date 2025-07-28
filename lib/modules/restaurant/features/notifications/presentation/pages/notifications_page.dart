import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/core/services/notification_service.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';
import 'dart:convert';

@RoutePage()
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _userPhone;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      // Récupérer les informations utilisateur depuis LocalStorage
      final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
      Map<String, dynamic> userDetails;

      try {
        userDetails = userDetailsJson is String
            ? jsonDecode(userDetailsJson)
            : userDetailsJson;
      } catch (e) {
        print('❌ Erreur parsing userDetails: $e');
        userDetails = {};
      }

      setState(() {
        _userPhone = userDetails['phone'] ?? userDetails['phoneNumber'];
        _userRole = userDetails['role'];
      });

      print('📱 Phone: $_userPhone, Role: $_userRole');

      // Charger les notifications après avoir récupéré les infos utilisateur
      await _loadNotifications();
    } catch (e) {
      print('❌ Erreur chargement infos utilisateur: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      if (_userPhone == null) {
        print('❌ Phone number non disponible');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Normaliser le numéro de téléphone pour Firestore
      String normalizedPhone =
          _userPhone!.startsWith('+225') ? _userPhone! : '+225$_userPhone';

      Query notificationsQuery;

      if (_userRole == 'admin') {
        // Pour les admins : récupérer toutes les notifications de type admin
        print('👨‍💼 Chargement notifications admin');
        notificationsQuery = FirebaseFirestore.instance
            .collection('notifications')
            .where('recipient_role', isEqualTo: 'admin')
            .orderBy('sent_at', descending: true)
            .limit(50);
      } else {
        // Pour les autres utilisateurs : récupérer leurs notifications personnelles
        print('👤 Chargement notifications pour: $normalizedPhone');
        notificationsQuery = FirebaseFirestore.instance
            .collection('notifications')
            .where('recipient_phone', isEqualTo: normalizedPhone)
            .orderBy('sent_at', descending: true)
            .limit(50);
      }

      final notificationsSnapshot = await notificationsQuery.get();

      setState(() {
        _notifications = notificationsSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return <String, dynamic>{
            'id': doc.id,
            ...(data ?? {}),
          };
        }).toList();
        _isLoading = false;
      });

      print('✅ ${_notifications.length} notifications chargées');
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
      case 'new_order':
        return Colors.purple;
      case 'new_parcel':
        return Colors.teal;
      case 'system_test':
        return Colors.indigo;
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
      case 'new_order':
        return Icons.restaurant;
      case 'new_parcel':
        return Icons.local_shipping;
      case 'system_test':
        return Icons.science;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'order_assigned':
        return 'Commande assignée';
      case 'delivery_started':
        return 'Livraison commencée';
      case 'delivery_completed':
        return 'Livraison terminée';
      case 'new_restaurant_order':
      case 'new_order':
        return 'Nouvelle commande';
      case 'new_parcel':
        return 'Nouveau colis';
      case 'system_test':
        return 'Test système';
      default:
        return 'Notification';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: UIColors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadNotifications();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
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
                      SizedBox(height: 8),
                      Text(
                        _userRole == 'admin'
                            ? 'Aucune notification admin pour le moment'
                            : 'Vous n\'avez pas encore reçu de notifications',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final type = notification['type'] ?? 'default';
                    final title =
                        notification['title'] ?? _getNotificationTitle(type);
                    final body = notification['body'] ?? '';
                    final isRead = notification['read'] ?? false;
                    final sentAt =
                        notification['sent_at']?.toDate() ?? DateTime.now();

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      color: isRead ? Colors.grey[50] : Colors.white,
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
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(body),
                            SizedBox(height: 4),
                            Text(
                              _formatDate(sentAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            if (!isRead)
                              PopupMenuItem(
                                value: 'mark_read',
                                child: Row(
                                  children: [
                                    Icon(Icons.check, size: 16),
                                    SizedBox(width: 8),
                                    Text('Marquer comme lu'),
                                  ],
                                ),
                              ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Supprimer',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'mark_read') {
                              _markAsRead(notification['id']);
                            } else if (value == 'delete') {
                              _deleteNotification(notification['id']);
                            }
                          },
                        ),
                        onTap: () {
                          if (!isRead) {
                            _markAsRead(notification['id']);
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
