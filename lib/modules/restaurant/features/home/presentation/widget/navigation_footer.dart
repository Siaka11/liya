import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/routes/app_router.gr.dart';

// Provider pour gérer l'index sélectionné
final selectedIndexProvider = StateProvider<int>((ref) => 0);

class NavigationFooter extends ConsumerWidget {
  const NavigationFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      currentIndex: selectedIndex,
      onTap: (index) {
        ref.read(selectedIndexProvider.notifier).state = index;
        switch (index) {
          case 0: // Accueil
            context.router.push(const HomeRoute());
            break;
          case 1: // Favoris
            // TODO: Implémenter la navigation vers les favoris
            break;
          case 2: // Recherche
            context.router.push(const SearchRoute());
            break;
          case 3: // Commandes
            context.router.push(const CartRoute());
            break;
          case 4: // Profil
            context.router.push(const ProfileRoute());
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoris"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Recherche"),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Commandes"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    );
  }
}
