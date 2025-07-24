import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart';

class TestIOSNotificationsPage extends StatefulWidget {
  const TestIOSNotificationsPage({Key? key}) : super(key: key);

  @override
  State<TestIOSNotificationsPage> createState() =>
      _TestIOSNotificationsPageState();
}

class _TestIOSNotificationsPageState extends State<TestIOSNotificationsPage> {
  String _log = '';
  bool _isLoading = false;
  String? _fcmToken;
  String? _apnsToken;
  PermissionStatus _notificationStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _log += '🍎 Test des notifications iOS...\n';
    });

    try {
      // Test 1: Vérifier les permissions
      await _testPermissions();

      // Test 2: Vérifier les tokens
      await _testTokens();

      // Test 3: Tester les notifications locales
      await _testLocalNotifications();
    } catch (e) {
      setState(() {
        _log += '❌ Erreur lors des tests: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPermissions() async {
    setState(() {
      _log += '🔐 Test des permissions...\n';
    });

    try {
      final status = await Permission.notification.status;
      setState(() {
        _notificationStatus = status;
        _log += '📱 Statut des permissions: $status\n';
      });

      if (status.isDenied) {
        setState(() {
          _log += '⚠️ Permissions refusées, demande d\'accès...\n';
        });

        final result = await Permission.notification.request();
        setState(() {
          _notificationStatus = result;
          _log += '📱 Nouveau statut: $result\n';
        });
      }
    } catch (e) {
      setState(() {
        _log += '❌ Erreur permissions: $e\n';
      });
    }
  }

  Future<void> _testTokens() async {
    setState(() {
      _log += '🔑 Test des tokens...\n';
    });

    try {
      // Test FCM Token
      final fcmToken = await NotificationService.getToken();
      setState(() {
        _fcmToken = fcmToken;
        _log += '✅ FCM Token: ${fcmToken?.substring(0, 20)}...\n';
      });

      // Test APNS Token (iOS seulement)
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        setState(() {
          _apnsToken = apnsToken;
          _log += '🍎 APNS Token: ${apnsToken?.substring(0, 20)}...\n';
        });
      }
    } catch (e) {
      setState(() {
        _log += '❌ Erreur tokens: $e\n';
      });
    }
  }

  Future<void> _testLocalNotifications() async {
    setState(() {
      _log += '📱 Test des notifications locales...\n';
    });

    try {
      await NotificationService.showLocalNotification(
        title: 'Test iOS',
        body: 'Cette notification fonctionne sur iOS !',
        payload: 'test_ios_notification',
      );

      setState(() {
        _log += '✅ Notification locale envoyée\n';
      });
    } catch (e) {
      setState(() {
        _log += '❌ Erreur notification locale: $e\n';
      });
    }
  }

  Future<void> _testBackgroundNotification() async {
    setState(() {
      _log += '🔄 Test notification en arrière-plan...\n';
    });

    try {
      // Simuler une notification Firebase
      await NotificationService.showLocalNotification(
        title: 'Commande reçue',
        body: 'Votre commande a été reçue et est en cours de préparation.',
        payload: 'order_received',
      );

      setState(() {
        _log += '✅ Notification d\'arrière-plan envoyée\n';
      });
    } catch (e) {
      setState(() {
        _log += '❌ Erreur notification arrière-plan: $e\n';
      });
    }
  }

  Future<void> _testTopicSubscription() async {
    setState(() {
      _log += '📡 Test abonnement topic...\n';
    });

    try {
      await NotificationService.subscribeToTopic('orders');
      setState(() {
        _log += '✅ Abonné au topic "orders"\n';
      });
    } catch (e) {
      setState(() {
        _log += '❌ Erreur abonnement topic: $e\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notifications iOS'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runTests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Log Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Log des tests iOS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 300,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _log,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statut',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                _notificationStatus.isGranted
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _notificationStatus.isGranted
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text('Permissions: $_notificationStatus'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _fcmToken != null
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _fcmToken != null
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              const Text('FCM Token'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _apnsToken != null
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _apnsToken != null
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              const Text('APNS Token'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Test Buttons
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tests',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : _testLocalNotifications,
                                  icon: const Icon(Icons.notifications),
                                  label: const Text('Test locale'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : _testBackgroundNotification,
                                  icon: const Icon(Icons.background),
                                  label: const Text('Test arrière-plan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isLoading ? null : _testTopicSubscription,
                              icon: const Icon(Icons.topic),
                              label: const Text('Test abonnement topic'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Instructions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Instructions pour iOS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '1. Assurez-vous que les notifications sont activées dans les paramètres iOS\n'
                            '2. Sur l\'émulateur, allez dans Settings > Notifications > Liya\n'
                            '3. Activez "Allow Notifications"\n'
                            '4. Testez les notifications locales d\'abord\n'
                            '5. Pour les notifications Firebase, utilisez un appareil physique',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
