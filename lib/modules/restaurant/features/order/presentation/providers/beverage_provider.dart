import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/beverage.dart';

// Provider de diagnostic pour tester différentes approches
final beverageDiagnosticProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final results = <String, dynamic>{};

  try {
    print('🔍 Diagnostic Firebase en cours...');

    // Test 1: Connexion de base
    try {
      final basicTest = await FirebaseFirestore.instance
          .collection('beverages')
          .limit(1)
          .get();
      results['basic_connection'] = {
        'success': true,
        'doc_count': basicTest.docs.length,
        'error': null
      };
      print('✅ Test 1 - Connexion de base: OK');
    } catch (e) {
      results['basic_connection'] = {
        'success': false,
        'doc_count': 0,
        'error': e.toString()
      };
      print('❌ Test 1 - Connexion de base: $e');
    }

    // Test 2: Récupération sans filtre
    try {
      final allDocs =
          await FirebaseFirestore.instance.collection('beverages').get();
      results['all_documents'] = {
        'success': true,
        'doc_count': allDocs.docs.length,
        'documents': allDocs.docs
            .map((doc) => {
                  'id': doc.id,
                  'data': doc.data(),
                })
            .toList(),
        'error': null
      };
      print('✅ Test 2 - Tous les documents: ${allDocs.docs.length} trouvés');
    } catch (e) {
      results['all_documents'] = {
        'success': false,
        'doc_count': 0,
        'documents': [],
        'error': e.toString()
      };
      print('❌ Test 2 - Tous les documents: $e');
    }

    // Test 3: Récupération avec filtre
    try {
      final filteredDocs = await FirebaseFirestore.instance
          .collection('beverages')
          .where('isAvailable', isEqualTo: true)
          .get();
      results['filtered_documents'] = {
        'success': true,
        'doc_count': filteredDocs.docs.length,
        'error': null
      };
      print(
          '✅ Test 3 - Documents filtrés: ${filteredDocs.docs.length} trouvés');
    } catch (e) {
      results['filtered_documents'] = {
        'success': false,
        'doc_count': 0,
        'error': e.toString()
      };
      print('❌ Test 3 - Documents filtrés: $e');
    }
  } catch (e) {
    results['overall_error'] = e.toString();
    print('❌ Erreur générale du diagnostic: $e');
  }

  return results;
});

// Provider de test pour récupérer toutes les boissons sans filtre
final allBeveragesProvider = FutureProvider<List<Beverage>>((ref) async {
  try {
    print('🔄 Test: Récupération de TOUTES les boissons depuis Firebase...');

    final snapshot =
        await FirebaseFirestore.instance.collection('beverages').get();

    print('📊 Test: Firebase a retourné ${snapshot.docs.length} documents');

    final beverages = snapshot.docs.map((doc) {
      print('📄 Test: Document ${doc.id}: ${doc.data()}');
      return Beverage.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
    }).toList();

    print('✅ Test: ${beverages.length} boissons chargées avec succès');
    return beverages;
  } catch (e) {
    print('❌ Test: Erreur Firebase: $e');
    return [];
  }
});

// Provider pour récupérer toutes les boissons depuis Firebase
final beveragesProvider = FutureProvider<List<Beverage>>((ref) async {
  try {
    print('🔄 Tentative de récupération des boissons depuis Firebase...');

    final snapshot = await FirebaseFirestore.instance
        .collection('beverages')
        .where('isAvailable', isEqualTo: true)
        .get();

    print('📊 Firebase a retourné ${snapshot.docs.length} documents');

    final beverages = snapshot.docs.map((doc) {
      print('📄 Document ${doc.id}: ${doc.data()}');
      return Beverage.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
    }).toList();

    print('✅ ${beverages.length} boissons chargées avec succès');
    return beverages;
  } catch (e) {
    print('❌ Erreur Firebase: $e');
    print('🔄 Utilisation des données par défaut...');
    // En cas d'erreur, retourner des données par défaut
    return _getDefaultBeverages();
  }
});

// Provider pour les boissons par catégorie
final beveragesByCategoryProvider =
    Provider.family<List<Beverage>, String>((ref, category) {
  final beveragesAsync = ref.watch(beveragesProvider);
  return beveragesAsync.when(
    data: (beverages) =>
        beverages.where((b) => b.category == category).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider pour les sodas
final sodasProvider = Provider<List<Beverage>>((ref) {
  return ref.watch(beveragesByCategoryProvider('soda'));
});

// Provider pour l'eau
final waterProvider = Provider<List<Beverage>>((ref) {
  return ref.watch(beveragesByCategoryProvider('water'));
});

// Provider pour les jus
final juicesProvider = Provider<List<Beverage>>((ref) {
  return ref.watch(beveragesByCategoryProvider('juice'));
});

// Données par défaut si Firebase n'est pas disponible
List<Beverage> _getDefaultBeverages() {
  return [
    Beverage(
      id: 'coca_cola',
      name: 'Coca Cola',
      imageUrl:
          'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=200',
      category: 'soda',
      sizes: {'small': 300, 'medium': 500, 'large': 800},
      isAvailable: true,
      description: 'Boisson gazeuse rafraîchissante',
    ),
    Beverage(
      id: 'fanta',
      name: 'Fanta',
      imageUrl:
          'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=200',
      category: 'soda',
      sizes: {'small': 300, 'medium': 500, 'large': 800},
      isAvailable: true,
      description: 'Boisson gazeuse aux fruits',
    ),
    Beverage(
      id: 'sprite',
      name: 'Sprite',
      imageUrl:
          'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=200',
      category: 'soda',
      sizes: {'small': 300, 'medium': 500, 'large': 800},
      isAvailable: true,
      description: 'Boisson gazeuse citron-lime',
    ),
    Beverage(
      id: 'water_mineral',
      name: 'Eau minérale',
      imageUrl:
          'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=200',
      category: 'water',
      sizes: {'small': 200, 'medium': 400, 'large': 600},
      isAvailable: true,
      description: 'Eau minérale naturelle',
    ),
    Beverage(
      id: 'water_sparkling',
      name: 'Eau gazeuse',
      imageUrl:
          'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=200',
      category: 'water',
      sizes: {'small': 250, 'medium': 450, 'large': 650},
      isAvailable: true,
      description: 'Eau minérale gazeuse',
    ),
    Beverage(
      id: 'orange_juice',
      name: 'Jus d\'orange',
      imageUrl:
          'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200',
      category: 'juice',
      sizes: {'small': 400, 'medium': 600, 'large': 900},
      isAvailable: true,
      description: 'Jus d\'orange frais',
    ),
    Beverage(
      id: 'apple_juice',
      name: 'Jus de pomme',
      imageUrl:
          'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200',
      category: 'juice',
      sizes: {'small': 400, 'medium': 600, 'large': 900},
      isAvailable: true,
      description: 'Jus de pomme naturel',
    ),
  ];
}
