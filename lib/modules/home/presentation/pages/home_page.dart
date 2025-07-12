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
import 'package:liya/core/init_restaurant_data.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:liya/routes/app_router.gr.dart';
import '../../application/home_provider.dart';

// Nouveau widget CustomPromoDialog fidèle au design Yango, largeur max, image bord à bord, bouton collé en bas
class CustomPromoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? imageUrl;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final VoidCallback? onClose;

  const CustomPromoDialog({
    Key? key,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.buttonText,
    required this.onButtonPressed,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width,
            height: height -
                100, // Presque toute la hauteur, laisse un peu d'espace en haut
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4B2B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: onButtonPressed,
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Close button (top right, détachée)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onClose ?? () => Navigator.of(context).pop(),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.close, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PromoPopupManager extends StatefulWidget {
  final Widget child;
  const PromoPopupManager({required this.child, Key? key}) : super(key: key);

  @override
  State<PromoPopupManager> createState() => _PromoPopupManagerState();
}

class _PromoPopupManagerState extends State<PromoPopupManager> {
  @override
  void initState() {
    super.initState();
    _checkAndShowPopup();
  }

  Future<void> _checkAndShowPopup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenPopup = prefs.getBool('hasSeenPromoPopup') ?? false;
      if (hasSeenPopup) return;

      final remoteConfig = FirebaseRemoteConfig.instance;

      // --- NOUVEAU: Définir les valeurs par défaut côté client ---
      await remoteConfig.setDefaults(const {
        'popup_config':
            '{"title": "Titre par défaut", "message": "Message par défaut.", "imageUrl": null, "showButton": false, "buttonText": "OK"}',
        // Ajoutez ici d'autres valeurs par défaut si vous avez d'autres paramètres
      });
      // --------------------------------------------------------

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 1),
      ));

      await remoteConfig.fetchAndActivate();

      final popupConfigString = remoteConfig.getString('popup_config');
      debugPrint('popupConfigString: $popupConfigString');

      // Vérifiez explicitement si la chaîne est vide AVANT de tenter de la décoder
      if (popupConfigString.isEmpty || popupConfigString == 'null') {
        // Ajout de 'null' en tant que chaîne
        debugPrint('Popup config string is empty or null, skipping popup.');
        return;
      }

      final popupConfig = json.decode(popupConfigString);

      if (!mounted) return;

      // Affiche le popup
      showCustomBottomPopup(
        context,
        title: popupConfig['title'] ?? '',
        message: popupConfig['message'] ?? '',
        imageUrl: popupConfig['imageUrl'],
        buttonText: popupConfig['buttonText'] ?? 'OK',
        onButtonPressed: () {
          Navigator.of(context).pop();
        },
      );

      // Marquer comme vu
      await prefs.setBool('hasSeenPromoPopup', true);
    } catch (e, stack) {
      debugPrint('❌ Erreur Remote Config: $e\n$stack');
      // Gérer l'erreur plus élégamment, par exemple afficher un SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Impossible de charger la configuration de la popup.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Bouton flottant de debug pour reset le flag
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            heroTag: 'resetPopupFlag',
            backgroundColor: Colors.red,
            child: const Icon(Icons.refresh),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('hasSeenPromoPopup');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Flag popup réinitialisé !')),
                );
              }
            },
            tooltip: 'Réinitialiser le popup',
          ),
        ),
      ],
    );
  }
}

void showCustomBottomPopup(
  BuildContext context, {
  required String title,
  required String message,
  String? imageUrl,
  required String buttonText,
  required VoidCallback onButtonPressed,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final height = MediaQuery.of(context).size.height;
      return Container(
        height: height * 0.62, // Commence vers le milieu, ajuste si besoin
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Stack(
          children: [
            // Utilise SingleChildScrollView pour garantir la taille de l'image
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 300, // Hauteur garantie
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4B2B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: onButtonPressed,
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Close button (top right)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, size: 24),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    // Map pour associer les titres aux routes
    final _routeMap = {
      'Je commande un plat': (context, option) =>
          AutoRouter.of(context).push(HomeRestaurantRoute(option: option)),
      "J'expédie un colis": (context, option) =>
          AutoRouter.of(context).push(const ParcelHomeRoute()),
      'Je livre': (context, option) =>
          AutoRouter.of(context).push(const HomeDeliveryRoute()),
      'Administrateur': (context, option) =>
          AutoRouter.of(context).push(const AdminDashboardRoute()),
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

    return PromoPopupManager(
      child: Scaffold(
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

            // Bouton pour accéder au dashboard admin
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  AutoRouter.of(context).push(const AdminDashboardRoute());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF24E1E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '👨‍💼 Dashboard Admin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Bouton pour définir le rôle admin
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  // Définir le rôle admin temporairement
                  final userDetails = {
                    'name': homeState.user.name,
                    'phoneNumber': homeState.user.phoneNumber,
                    'email': homeState.user.email,
                    'role': 'admin',
                  };
                  singleton<LocalStorageFactory>().setUserDetails(userDetails);

                  // Recharger la page pour voir les changements
                  ref.refresh(homeProvider);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('✅ Rôle défini comme admin! Rechargez la page.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '🔧 Définir Rôle Admin',
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

            // Bouton pour initialiser les restaurants
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () async {
                  await InitRestaurantData.initializeRestaurantData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('✅ Données des restaurants initialisées!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '🍽️ Initialiser les Restaurants',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
