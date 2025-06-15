import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/home/domain/entities/item.dart';
import 'package:restaurant/features/home/domain/repositories/cart_repository.dart';
import 'package:restaurant/features/home/presentation/providers/refresh_key.dart';

class CartPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final cartRepository = watch(cartRepositoryProvider);
    final refreshKey = watch(refreshKeyProvider);
    final items = watch(cartItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
      ),
      body: items.when(
        data: (data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                title: Text(item.name),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    try {
                      await cartRepository.removeFromCart(
                          phoneNumber, item.id ?? item.name);
                      // Forcer le rafraîchissement de la page
                      ref.read(refreshKey.notifier).state++;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Article supprimé du panier'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Erreur lors de la suppression: [38;5;9m${e.toString()}[0m'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => CircularProgressIndicator(),
        error: (e, _) => Text('Erreur: $e'),
      ),
    );
  }
}
