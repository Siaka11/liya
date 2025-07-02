import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/admin/features/dishes/presentation/pages/restaurant_select_page.dart';
import 'package:liya/modules/home/presentation/pages/utils/top_menu.dart';
import 'package:liya/modules/home/presentation/pages/widget/home_card_widget.dart';
import 'package:liya/core/test_modern_system.dart';
import 'package:liya/core/test_beverages.dart';
import 'package:liya/modules/home/domain/entities/home_option.dart';
import 'package:liya/core/test_users_management.dart';
import 'package:liya/modules/delivery/presentation/pages/delivery_assignment_page.dart';
import 'package:liya/modules/delivery/presentation/pages/delivery_dashboard_page.dart';
import 'package:liya/core/init_delivery_data.dart';

import 'package:liya/routes/app_router.gr.dart';
import '../../application/home_provider.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    // Map pour associer les titres aux routes
    final _routeMap = {
      'Je veux commander un plat': (context, option) =>
          AutoRouter.of(context).push(HomeRestaurantRoute(option: option)),
      'Je veux expédier un colis': (context, option) =>
          AutoRouter.of(context).push(const ParcelHomeRoute()),
      'Je veux livrer': (context, option) =>
          AutoRouter.of(context).push(const HomeDeliveryRoute()),
      // 'Faire des courses': (context, option) => AutoRouter.of(context).push(const ShoppingRoute()),
      // 'Administrateur': (context, option) => AutoRouter.of(context).push(const AdminRoute()),
    };

    void onOptionSelected(BuildContext context, HomeOption option) {
      final navigate = _routeMap[option.title];
      if (navigate != null) {
        print('Navigating to ${option.title}');
        navigate(context, option);
      } else {
        print('Unknown module: ${option.title}');
      }
    }

    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                        height: 120.0,
                        width: 120.0,
                      ),
                    ],
                  ),
                ),
                // Titre
                const Text(
                  'Comment pouvons-nous vous aider ?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                // Grille de cartes
                Expanded(
                  child: homeState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : homeState.error != null
                          ? Center(child: Text('Erreur : ${homeState.error}'))
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                              itemCount: homeState.options.length,
                              itemBuilder: (context, index) {
                                final option = homeState.options[index];
                                return HomeOptionCard(
                                  option: option,
                                  onTap: () {
                                    onOptionSelected(context, option);
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(
                Icons.account_circle,
                color: Colors.grey,
                size: 40,
              ),
              onPressed: () {
                showTopMenu(context, ref); // Ouvre le menu depuis le haut
              },
            ),
          ),
          Positioned(
              top: 10,
              left: 10,
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bonjour "),
                      Text(homeState.user.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black)),
                    ],
                  ))),
          // Bouton de test pour le système moderne
          Positioned(
            bottom: 200,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestModernSystemPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '🧪 Tester le Système Moderne',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Bouton de test pour les boissons
          Positioned(
            bottom: 140,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestBeveragesPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '🥤 Tester les Boissons',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Bouton pour initialiser les données de livraison
          Positioned(
            bottom: 260,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                await InitDeliveryData.initializeDeliverySystem();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Données de livraison initialisées!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '🚀 Initialiser les Données de Livraison',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Bouton pour accéder au dashboard admin des livraisons
          Positioned(
            bottom: 200,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                AutoRouter.of(context)
                    .push(const DeliveryAdminDashboardRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '👨‍💼 Dashboard Admin - Assignation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Bouton pour accéder à l'interface livreur existante
          Positioned(
            bottom: 140,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                AutoRouter.of(context).push(const HomeDeliveryRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '🚚 Interface Livreur (Dynamique)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Bouton pour initialiser les données de livraison
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                await InitDeliveryData.initializeDeliverySystem();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Données de livraison initialisées!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '🚀 Initialiser les Données',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
