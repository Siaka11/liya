import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dish_model.dart';
import '../providers/dish_provider.dart';
import 'dish_image_editor_page.dart';

@RoutePage()
class DishListPage extends ConsumerStatefulWidget {
  final String restaurantId;
  const DishListPage({super.key, required this.restaurantId});

  @override
  ConsumerState<DishListPage> createState() => _DishListPageState();
}

class _DishListPageState extends ConsumerState<DishListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dishProvider.notifier).loadDishes(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dishProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des plats'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(dishProvider.notifier)
                              .loadDishes(widget.restaurantId);
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(dishProvider.notifier)
                        .loadDishes(widget.restaurantId);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.dishes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final dish = state.dishes[index];
                      return Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surface,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: dish.imageUrl.isNotEmpty
                                ? Image.network(
                                    dish.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image,
                                            color: Colors.grey),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.fastfood,
                                        color: Colors.grey),
                                  ),
                          ),
                          title: Text(
                            dish.name,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                '${dish.price} FCFA',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              Text(
                                dish.rating.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blueAccent),
                            tooltip: "Modifier l'image du plat",
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DishImageEditorPage(dish: dish),
                                ),
                              );
                              // Refresh après modification
                              ref
                                  .read(dishProvider.notifier)
                                  .loadDishes(widget.restaurantId);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
