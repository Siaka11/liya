import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../category/presentation/pages/dishes_by_category_page.dart';
import '../../application/categories_firebase_provider.dart';

class FilterItem {
  final String id;
  final String label;
  final String imageUrl;

  FilterItem({required this.id, required this.label, required this.imageUrl});
}

class FilterSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends ConsumerState<FilterSection> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Charger les catégories au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriesState = ref.read(categoriesFirebaseProvider);
      if (categoriesState.categories == null && !categoriesState.isLoading) {
        ref.read(categoriesFirebaseProvider.notifier).loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesFirebaseProvider);

    // Si en cours de chargement
    if (categoriesState.isLoading) {
      return Container(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Si erreur
    if (categoriesState.error != null) {
      return Container(
        height: 80,
        child: Center(
          child: Text(
            'Erreur: ${categoriesState.error}',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      );
    }

    // Si pas de catégories
    if (categoriesState.categories == null ||
        categoriesState.categories!.isEmpty) {
      return Container(
        height: 80,
        child: Center(
          child: Text(
            'Aucune catégorie disponible',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    // Convertir les catégories Firebase en FilterItems
    final filters = categoriesState.categories!.map((category) {
      return FilterItem(
        id: category['id'],
        label: category['name'],
        imageUrl: category['imageUrl'] ?? category['image_url'] ?? '',
      );
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(filters.length, (index) {
          bool isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DishesByCategoryPage(
                      categoryId: filters[index].id,
                      categoryName: filters[index].label),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image de la catégorie
                  Container(
                    width: 24,
                    height: 24,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: filters[index].imageUrl.isNotEmpty
                          ? Image.network(
                              filters[index].imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/img/basilique.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/img/basilique.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    filters[index].label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
