import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/annotations.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/beverage_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/providers/beverage_provider.dart';
import 'package:liya/modules/restaurant/features/order/domain/entities/beverage.dart';
import 'package:liya/core/firebase_beverages_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@RoutePage(name: 'TestBeveragesRoute')
class TestBeveragesPage extends ConsumerStatefulWidget {
  const TestBeveragesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TestBeveragesPage> createState() => _TestBeveragesPageState();
}

class _TestBeveragesPageState extends ConsumerState<TestBeveragesPage> {
  List<BeverageSelection> selectedBeverages = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final beveragesAsync = ref.watch(beveragesProvider);
    final allBeveragesAsync = ref.watch(allBeveragesProvider);
    final diagnosticAsync = ref.watch(beverageDiagnosticProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test des Boissons'),
        backgroundColor: UIColors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _initializeBeverages,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bouton d'initialisation
            ElevatedButton(
              onPressed: isLoading ? null : _initializeBeverages,
              style: ElevatedButton.styleFrom(
                backgroundColor: UIColors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Initialiser les données Firebase'),
            ),

            const SizedBox(height: 20),

            // Diagnostic Firebase
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diagnostic Firebase :',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    diagnosticAsync.when(
                      loading: () => const Text('Diagnostic en cours...'),
                      error: (error, stack) =>
                          Text('Erreur diagnostic: $error'),
                      data: (diagnostic) => _buildDiagnosticInfo(diagnostic),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Statut des données avec plus de détails
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statut des données :',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Données filtrées (isAvailable: true)
                    Row(
                      children: [
                        const Text('Filtrées (isAvailable: true): '),
                        beveragesAsync.when(
                          loading: () => const Text('Chargement...',
                              style: TextStyle(color: Colors.orange)),
                          error: (error, stack) => Text('Erreur: $error',
                              style: const TextStyle(color: Colors.red)),
                          data: (beverages) => Text(
                            '${beverages.length} boissons',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Toutes les données
                    Row(
                      children: [
                        const Text('Toutes les données: '),
                        allBeveragesAsync.when(
                          loading: () => const Text('Chargement...',
                              style: TextStyle(color: Colors.orange)),
                          error: (error, stack) => Text('Erreur: $error',
                              style: const TextStyle(color: Colors.red)),
                          data: (beverages) => Text(
                            '${beverages.length} boissons',
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Liste des boissons par catégorie
            Expanded(
              child: allBeveragesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erreur: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeBeverages,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
                data: (beverages) => _buildBeveragesList(beverages),
              ),
            ),

            const SizedBox(height: 20),

            // Bouton de test des boissons
            BeverageButton(
              selectedBeverages: selectedBeverages,
              onBeveragesChanged: (beverages) {
                setState(() {
                  selectedBeverages = beverages;
                });
              },
            ),

            const SizedBox(height: 20),

            // Affichage des sélections
            if (selectedBeverages.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Boissons sélectionnées :',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...selectedBeverages.map((selection) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(selection.displayName),
                                Text(
                                  '${selection.totalPrice.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: UIColors.orange,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total :',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${selectedBeverages.fold(0.0, (sum, s) => sum + s.totalPrice).toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: UIColors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBeveragesList(List<Beverage> beverages) {
    final sodas = beverages.where((b) => b.category == 'soda').toList();
    final water = beverages.where((b) => b.category == 'water').toList();
    final juices = beverages.where((b) => b.category == 'juice').toList();

    return ListView(
      children: [
        _buildCategorySection('Sodas', sodas),
        _buildCategorySection('Eau', water),
        _buildCategorySection('Jus', juices),
      ],
    );
  }

  Widget _buildCategorySection(String title, List<Beverage> beverages) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...beverages.map((beverage) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      beverage.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child:
                            const Icon(Icons.local_drink, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(beverage.name),
                  subtitle: Text(beverage.description),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Disponible: ${beverage.isAvailable ? "Oui" : "Non"}',
                        style: TextStyle(
                          color:
                              beverage.isAvailable ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${beverage.sizes.length} tailles',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeBeverages() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Test de connexion Firebase
      print('🔍 Test de connexion Firebase...');
      final testSnapshot = await FirebaseFirestore.instance
          .collection('beverages')
          .limit(1)
          .get();

      print(
          '📡 Connexion Firebase OK - ${testSnapshot.docs.length} documents trouvés');

      // Vérifier si les données existent déjà
      final exists = await FirebaseBeveragesInitializer.beveragesExist();

      if (!exists) {
        print('📝 Initialisation des données...');
        await FirebaseBeveragesInitializer.initializeBeverages();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Données de boissons initialisées avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('ℹ️ Les données existent déjà');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ℹ️ Les données de boissons existent déjà'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildDiagnosticInfo(Map<String, dynamic> diagnostic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Test 1: Connexion de base
        _buildDiagnosticRow(
          'Connexion de base',
          diagnostic['basic_connection'] ?? {},
        ),

        // Test 2: Tous les documents
        _buildDiagnosticRow(
          'Tous les documents',
          diagnostic['all_documents'] ?? {},
        ),

        // Test 3: Documents filtrés
        _buildDiagnosticRow(
          'Documents filtrés',
          diagnostic['filtered_documents'] ?? {},
        ),

        // Erreur générale
        if (diagnostic['overall_error'] != null) ...[
          const SizedBox(height: 8),
          Text(
            'Erreur générale: ${diagnostic['overall_error']}',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }

  Widget _buildDiagnosticRow(String title, Map<String, dynamic> data) {
    final success = data['success'] ?? false;
    final docCount = data['doc_count'] ?? 0;
    final error = data['error'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: ${success ? '$docCount docs' : 'Erreur'}',
              style: TextStyle(
                color: success ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
