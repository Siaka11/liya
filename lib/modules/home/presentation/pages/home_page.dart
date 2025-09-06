import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/modules/home/presentation/pages/widget/home_card_widget.dart';
import 'package:liya/modules/home/presentation/pages/widget/profile_content_widget.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:liya/modules/home/application/home_provider.dart';
import 'package:liya/modules/home/presentation/pages/utils/top_menu.dart';
import 'package:liya/core/ui/components/notification_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/clean_test_data.dart';
import '../../../../core/init_delivery_data.dart';
import '../../../../core/init_restaurant_data.dart';
import '../../../../core/services/phone_call_service.dart';
import '../../../../core/test_beverages.dart';
import '../../../../core/test_modern_system.dart';
import '../../../../core/test_users_management.dart';
import '../../domain/entities/home_option.dart';

// Provider pour gérer l'affichage du profil
final showProfileProvider = StateProvider<bool>((ref) => false);

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
        action: popupConfig['action'],
        actionData: popupConfig['actionData'],
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
        /*Positioned(
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
        ),*/
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
  String? action,
  dynamic actionData,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final height = MediaQuery.of(context).size.height;
      return Container(
        height: height * 0.62,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.network(
                            imageUrl,
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
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Action dynamique selon le JSON
                        if (action == 'open_restaurant' && actionData != null) {
                          // Naviguer vers la page restaurant
                          // context.router.push(RestaurantDetailRoute(restaurantId: actionData));
                        } else if (action == 'open_dish' &&
                            actionData != null) {
                          // Naviguer vers la page plat
                          // context.router.push(DishDetailRoute(dishId: actionData));
                        } else if (action == 'open_dishes' &&
                            actionData is List) {
                          // Naviguer vers une page liste de plats personnalisée
                          // context.router.push(DishesListRoute(dishIds: List<String>.from(actionData)));
                        } else if (action == 'open_all_restaurants') {
                          // Naviguer vers la liste de tous les restaurants
                          context.router.push(AllRestaurantsRoute());
                        }
                        // Ajoute d'autres cas selon tes besoins
                      },
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
    final showProfile = ref.watch(showProfileProvider);

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
              // Image de fond
              Positioned.fill(
                child: Image.asset(
                  'assets/img/basilique.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Contenu principal de la HomePage
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                              ? Center(
                                  child: Text('Erreur : ${homeState.error}'))
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

              // Message de bienvenue en haut à gauche
              Positioned(
                top: 10,
                left: 10,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bonjour ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        homeState.user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton menu utilisateur en haut à droite
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.call,
                        color: Colors.grey,
                        size: 20.0,
                      ),
                      onPressed: () => _callNumber(context, '+2250700846546'),
                    ),
                    // Icône de notifications
                    NotificationButton(
                      backgroundColor: Colors.transparent,
                      iconColor: Colors.grey,
                      size: 40.0,
                      onPressed: () {
                        // Navigation vers la page de notifications
                        context.router.push(const NotificationsRoute());
                      },
                    ),
                    // Icône de profil
                    IconButton(
                      icon: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 20.0,
                      ),
                      onPressed: () {
                        showTopMenu(context, ref);
                      },
                    ),
                  ],
                ),
              ),

              // Bouton paramètres en bas à gauche
              /*Positioned(
                bottom: 20,
                left: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    _showTestDrawer(context);
                  },
                  backgroundColor: Colors.grey[300],
                  child: const Icon(
                    Icons.settings,
                    color: Colors.black54,
                  ),
                ),
              ),*/
              // Overlay du profil
              if (showProfile)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ProfileContentWidget(
                        onClose: () {
                          ref.read(showProfileProvider.notifier).state = false;
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTestDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Titre
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.science, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Tests et Configuration',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Boutons de test
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Bouton pour tester les boissons
                    SizedBox(
                      width: double.infinity,
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

                    const SizedBox(height: 12),

                    // Bouton pour tester le système moderne
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TestModernSystemPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '🎨 Tester le Système Moderne',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bouton pour tester la gestion des utilisateurs
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TestUsersManagementPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '👥 Tester la Gestion des Utilisateurs',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bouton pour initialiser les données de livraison
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await InitDeliveryData.initializeDeliverySystem();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '✅ Données de livraison initialisées!'),
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

                    const SizedBox(height: 12),

                    // Bouton pour initialiser les restaurants
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await InitRestaurantData.initializeRestaurantData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '✅ Données des restaurants initialisées!'),
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

                    const SizedBox(height: 12),

                    // Bouton pour tester les notifications
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TestNotificationsPage(),
                            ),
                          );*/
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
                          '🔔 Tester les Notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bouton pour tester Google Maps
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => _TestMapsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('🗺️ Test Google Maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bouton pour nettoyer les données de test
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await CleanTestData.cleanTestOrders();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Données de test nettoyées!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '🧹 Nettoyer Données Test',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _callNumber(BuildContext context, String number) async {
  try {
    debugPrint('Tentative d\'appel vers: $number');

    final success = await PhoneCallService.makeCall(number);

    if (!success) {
      _showCopySnackBar(context, number);
    }
  } catch (e) {
    debugPrint('Erreur lors de l\'appel: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur lors de l\'appel : $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

void _showCopySnackBar(BuildContext context, String number) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          'Impossible d\'ouvrir l\'application Téléphone.\nNuméro : $number'),
      action: SnackBarAction(
        label: 'Copier',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: number));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Numéro copié dans le presse-papiers')),
          );
        },
      ),
    ),
  );
}

// Page de test pour Google Maps
class _TestMapsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Google Maps'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.blue[100]!,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map,
                size: 64,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Test Google Maps',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Position: Yamoussoukro (6.8270, -5.2890)',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
