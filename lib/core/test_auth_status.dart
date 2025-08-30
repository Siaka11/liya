import 'package:flutter/material.dart';
import 'package:liya/core/services/account_management_service.dart';

class TestAuthStatus extends StatefulWidget {
  const TestAuthStatus({super.key});

  @override
  State<TestAuthStatus> createState() => _TestAuthStatusState();
}

class _TestAuthStatusState extends State<TestAuthStatus> {
  Map<String, dynamic> _authStatus = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test État Authentification'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bouton de test
            ElevatedButton(
              onPressed: _isLoading ? null : _checkAuthStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '🔍 Vérifier l\'état d\'authentification',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 16),

            // Résultats
            if (_authStatus.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 État d\'authentification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatusItem('Firebase User',
                          _authStatus['firebaseUser']?.toString() ?? 'NULL'),
                      _buildStatusItem(
                          'UID', _authStatus['uid']?.toString() ?? 'NULL'),
                      _buildStatusItem('Téléphone',
                          _authStatus['phoneNumber']?.toString() ?? 'NULL'),
                      _buildStatusItem(
                          'Email', _authStatus['email']?.toString() ?? 'NULL'),
                      _buildStatusItem('Stockage Local',
                          _authStatus['localStorage']?.toString() ?? 'NULL'),
                      _buildStatusItem(
                          'Téléphone Local',
                          _authStatus['localPhoneNumber']?.toString() ??
                              'NULL'),
                      _buildStatusItem('Nom Local',
                          _authStatus['localName']?.toString() ?? 'NULL'),
                      if (_authStatus['error'] != null)
                        _buildStatusItem('Erreur',
                            _authStatus['error']?.toString() ?? 'NULL'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bouton de suppression de compte
              ElevatedButton(
                onPressed: _authStatus['firebaseUser'] == true
                    ? _testDeleteAccount
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  '🧪 Tester la suppression de compte',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    final isError = value == 'NULL' || value == 'false';
    final isSuccess = value == 'true' || (value != 'NULL' && value.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error
                : (isSuccess ? Icons.check_circle : Icons.info),
            color:
                isError ? Colors.red : (isSuccess ? Colors.green : Colors.blue),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                color: isError
                    ? Colors.red
                    : (isSuccess ? Colors.green : Colors.black87),
                fontWeight: isError ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await AccountManagementService.checkAuthStatus();
      setState(() {
        _authStatus = status;
      });
    } catch (e) {
      setState(() {
        _authStatus = {'error': e.toString()};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDeleteAccount() async {
    try {
      await AccountManagementService.showDeleteAccountDialog(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du test: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
