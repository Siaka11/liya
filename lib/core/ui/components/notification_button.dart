import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liya/routes/app_router.gr.dart';

class NotificationButton extends ConsumerStatefulWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool showBadge;

  const NotificationButton({
    Key? key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40.0,
    this.showBadge = true,
  }) : super(key: key);

  @override
  ConsumerState<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends ConsumerState<NotificationButton> {
  bool _notificationsEnabled = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
    _loadUnreadCount();
  }

  Future<void> _loadNotificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      });
    } catch (e) {
      print('❌ Erreur chargement statut notifications: $e');
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'default_user';

      // Écouter les notifications non lues en temps réel
      FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _unreadCount = snapshot.docs.length;
        });
      });
    } catch (e) {
      print('❌ Erreur chargement notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications,
              color: widget.iconColor ?? Colors.white,
              size: widget.size * 0.5,
            ),
            onPressed: widget.onPressed ??
                () {
                  // Navigation vers la page de notifications
                  context.router.push(const NotificationsRoute());
                },
          ),
        ),
        if (widget.showBadge && _unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Widget pour afficher le bouton dans une AppBar
class NotificationAppBarButton extends ConsumerStatefulWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const NotificationAppBarButton({
    Key? key,
    this.backgroundColor,
    this.iconColor,
    this.size,
  }) : super(key: key);

  @override
  ConsumerState<NotificationAppBarButton> createState() =>
      _NotificationAppBarButtonState();
}

class _NotificationAppBarButtonState
    extends ConsumerState<NotificationAppBarButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'default_user';

      // Écouter les notifications non lues en temps réel
      FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _unreadCount = snapshot.docs.length;
        });
      });
    } catch (e) {
      print('❌ Erreur chargement notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: widget.iconColor ?? Colors.white,
            size: widget.size ?? 24,
          ),
          onPressed: () {
            // Navigation vers la page de notifications
            context.router.push(const NotificationsRoute());
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
