import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Script de test pour vérifier la connectivité sur émulateur
Future<void> main() async {
  print('🔍 Test de connectivité sur émulateur...');

  final connectivity = Connectivity();

  // Test 1: Vérification via connectivity_plus
  print('\n📡 Test 1: Vérification via connectivity_plus');
  try {
    final result = await connectivity.checkConnectivity();
    print('Résultat connectivity_plus: $result');
  } catch (e) {
    print('❌ Erreur connectivity_plus: $e');
  }

  // Test 2: Vérification via DNS lookup
  print('\n🌐 Test 2: Vérification via DNS lookup');
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 5));
    print('DNS lookup google.com: ${result.isNotEmpty ? "SUCCÈS" : "ÉCHEC"}');
    if (result.isNotEmpty) {
      print('Adresse IP: ${result[0].address}');
    }
  } catch (e) {
    print('❌ Erreur DNS lookup: $e');
  }

  // Test 3: Vérification via DNS lookup (fallback)
  print('\n🔄 Test 3: Vérification via DNS lookup (fallback)');
  try {
    final result = await InternetAddress.lookup('8.8.8.8')
        .timeout(const Duration(seconds: 3));
    print('DNS lookup 8.8.8.8: ${result.isNotEmpty ? "SUCCÈS" : "ÉCHEC"}');
    if (result.isNotEmpty) {
      print('Adresse IP: ${result[0].address}');
    }
  } catch (e) {
    print('❌ Erreur DNS lookup fallback: $e');
  }

  // Test 4: Vérification via HTTP request
  print('\n🌍 Test 4: Vérification via HTTP request');
  try {
    final client = HttpClient();
    final request = await client
        .getUrl(Uri.parse('https://httpbin.org/ip'))
        .timeout(const Duration(seconds: 5));
    final response = await request.close();
    print('HTTP request: ${response.statusCode == 200 ? "SUCCÈS" : "ÉCHEC"}');
    print('Status code: ${response.statusCode}');
  } catch (e) {
    print('❌ Erreur HTTP request: $e');
  }

  print('\n✅ Test de connectivité terminé');
}
