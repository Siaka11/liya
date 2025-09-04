import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/connectivity_service.dart';
import '../../services/connection_manager.dart';
import 'dart:io';

/// Widget de debug pour tester la connectivité sur émulateur
class ConnectivityDebugWidget extends StatefulWidget {
  const ConnectivityDebugWidget({Key? key}) : super(key: key);

  @override
  State<ConnectivityDebugWidget> createState() =>
      _ConnectivityDebugWidgetState();
}

class _ConnectivityDebugWidgetState extends State<ConnectivityDebugWidget> {
  final ConnectivityService _connectivityService = ConnectivityService();
  final ConnectionManager _connectionManager = ConnectionManager();

  bool _isConnected = true;
  bool _isTesting = false;
  String _lastTestResult = '';

  @override
  void initState() {
    super.initState();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivityService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  Future<void> _testConnectivity() async {
    setState(() {
      _isTesting = true;
      _lastTestResult = '';
    });

    try {
      // Test 1: connectivity_plus
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      print('🔍 connectivity_plus: $result');

      // Test 2: DNS lookup
      try {
        final dnsResult = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));
        print('🌐 DNS lookup: ${dnsResult.isNotEmpty ? "SUCCÈS" : "ÉCHEC"}');
      } catch (e) {
        print('❌ DNS lookup error: $e');
      }

      // Test 3: Force check
      await _connectionManager.forceConnectivityCheck();

      setState(() {
        _lastTestResult =
            'Test terminé - Statut: ${_connectionManager.isConnected ? "CONNECTÉ" : "DÉCONNECTÉ"}';
      });
    } catch (e) {
      setState(() {
        _lastTestResult = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Debug Connectivité',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Statut actuel
          Row(
            children: [
              Icon(
                _isConnected ? Icons.wifi : Icons.wifi_off,
                color: _isConnected ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Statut: ${_isConnected ? "CONNECTÉ" : "DÉCONNECTÉ"}',
                style: TextStyle(
                  fontSize: 14,
                  color: _isConnected ? Colors.green[600] : Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Bouton de test
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTesting ? null : _testConnectivity,
              icon: _isTesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh, size: 16),
              label: Text(
                  _isTesting ? 'Test en cours...' : 'Tester la connectivité'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Résultat du test
          if (_lastTestResult.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _lastTestResult,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Instructions
          Text(
            'Ce widget de debug vous permet de tester la connectivité sur émulateur. Cliquez sur "Tester la connectivité" pour forcer une vérification.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
