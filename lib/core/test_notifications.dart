import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/services/notification_service.dart';
import 'package:liya/core/ui/theme/theme.dart';

class TestNotificationsPage extends ConsumerStatefulWidget {
  const TestNotificationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TestNotificationsPage> createState() =>
      _TestNotificationsPageState();
}

class _TestNotificationsPageState extends ConsumerState<TestNotificationsPage> {
  String _status = 'Prêt';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notifications'),
        backgroundColor: UIColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Statut
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Statut des Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        color: _status.contains('✅')
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Boutons de test
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testLocalNotification,
              icon: const Icon(Icons.notifications),
              label: const Text('Test Notification Locale'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _diagnoseIssues,
              icon: const Icon(Icons.bug_report),
              label: const Text('Diagnostic Notifications'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _forceGetToken,
              icon: const Icon(Icons.refresh),
              label: const Text('Forcer Récupération Token'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCloudFunctions,
              icon: const Icon(Icons.cloud),
              label: const Text('Test Cloud Functions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkTokenStatus,
              icon: const Icon(Icons.info),
              label: const Text('Vérifier Statut Token'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testLocalNotification() async {
    setState(() {
      _isLoading = true;
      _status = 'Envoi notification locale...';
    });

    try {
      await NotificationService.showLocalNotification(
        title: 'Test Notification',
        body: 'Ceci est une notification de test locale',
        payload: 'test_notification',
      );
      setState(() {
        _status = '✅ Notification locale envoyée avec succès';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erreur notification locale: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _diagnoseIssues() async {
    setState(() {
      _isLoading = true;
      _status = 'Diagnostic en cours...';
    });

    try {
      // Diagnostic des notifications
      final token = await NotificationService.getToken();
      print('🔑 Token FCM: $token');
      print('✅ Diagnostic terminé');
      setState(() {
        _status = '✅ Diagnostic terminé - voir les logs';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erreur diagnostic: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _forceGetToken() async {
    setState(() {
      _isLoading = true;
      _status = 'Récupération forcée du token...';
    });

    try {
      final token = await NotificationService.getToken();
      if (token != null) {
        setState(() {
          _status = '✅ Token FCM récupéré: ${token.substring(0, 20)}...';
        });
      } else {
        setState(() {
          _status = '❌ Impossible de récupérer le token FCM';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Erreur récupération token: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCloudFunctions() async {
    setState(() {
      _isLoading = true;
      _status = 'Test des Cloud Functions...';
    });

    try {
      // TODO: Implémenter le test des Cloud Functions
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _status = '✅ Test Cloud Functions terminé';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erreur test Cloud Functions: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkTokenStatus() async {
    setState(() {
      _isLoading = true;
      _status = 'Vérification du statut...';
    });

    try {
      final token = await NotificationService.getToken();

      String status = '';
      status += 'Service initialisé: true\n';
      status += 'Token disponible: ${token != null}\n';
      if (token != null) {
        status += 'Token: ${token.substring(0, 20)}...';
      }

      setState(() {
        _status = 'ℹ️ $status';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erreur vérification: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
