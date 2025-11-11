import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Pour defaultTargetPlatform
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/modules/home/presentation/pages/widget/home_card_widget.dart';
import 'package:liya/modules/home/presentation/pages/widget/profile_content_widget.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:liya/modules/home/application/home_provider.dart';
import 'package:liya/modules/home/presentation/pages/utils/top_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liya/core/providers/guest_mode_provider.dart'; // Provider mode invité

import '../../../../core/services/phone_call_service.dart';
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
    final guestMode = ref.watch(guestModeProvider);

    // Filtrer les options en fonction du mode invité
    List<HomeOption> displayedOptions;
    if (guestMode.isGuestMode) {
      displayedOptions = homeState.options.where((option) {
        return option.title == 'Je commande un plat' ||
            option.title == "J'expédie un colis";
      }).toList();

      // Fallback : s'assurer que les cartes invités sont toujours visibles
      if (displayedOptions.isEmpty) {
        displayedOptions = const [
          HomeOption(title: 'Je commande un plat', icon: 'fastfood'),
          HomeOption(title: "J'expédie un colis", icon: 'local_shipping'),
        ];
      }
    } else {
      displayedOptions = homeState.options;
    }

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
                                  itemCount: displayedOptions.length,
                                  itemBuilder: (context, index) {
                                    final option = displayedOptions[index];
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
                        guestMode.isGuestMode ? "Invité" : homeState.user.name,
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
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _callNumber(context, '+2250700846546'),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset('assets/img/cascall.png',
                              width: 16.0,
                              height: 16.0,
                              color: Colors.grey[800]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          context.router.push(const NotificationsRoute());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Colors.grey[800],
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          showTopMenu(context, ref);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.grey[800],
                            size: 20.0,
                          ),
                        ),
                      ),
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
