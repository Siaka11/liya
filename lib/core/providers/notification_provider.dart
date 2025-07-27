import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../services/fcm_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
});

// Provider pour les notifications d'un utilisateur
final userNotificationsProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, userPhone) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getUserNotifications(userPhone);
});

// Provider pour les notifications d'un rôle
final roleNotificationsProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, role) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getRoleNotifications(role);
});

// Provider pour marquer une notification comme lue
final markNotificationAsReadProvider =
    FutureProvider.family<void, String>((ref, notificationId) async {
  final notificationService = ref.watch(notificationServiceProvider);
  await notificationService.markNotificationAsRead(notificationId);
});

// Provider pour initialiser FCM
final initializeFCMProvider = FutureProvider<void>((ref) async {
  final fcmService = ref.watch(fcmServiceProvider);
  await fcmService.initialize();
});

// Provider pour nettoyer les tokens FCM
final cleanupFCMTokensProvider = FutureProvider<void>((ref) async {
  final fcmService = ref.watch(fcmServiceProvider);
  await fcmService.cleanupOldTokens();
});
