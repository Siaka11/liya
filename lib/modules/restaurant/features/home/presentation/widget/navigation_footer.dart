import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';
import 'dart:convert';
import '../../../../../../routes/app_router.gr.dart';
import '../../../order/presentation/pages/order_list_page.dart';

// Provider pour gérer l'index sélectionné
final selectedIndexProvider = StateProvider<int>((ref) => 0);

class NavigationFooter extends ConsumerWidget {
  const NavigationFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final userDetailsJson =
    singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';
    print("user : $phoneNumber");
    print("------------------------------------");
    print("userDetailsJson : $userDetailsJson");
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
            context.router.push(OrderListRoute(phoneNumber: phoneNumber));
            break;
          case 4: // Profil
            context.router.push(const ProfileRoute());
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Panier',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Recherche',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Commandes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
