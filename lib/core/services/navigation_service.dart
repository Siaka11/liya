import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../routes/app_router.gr.dart';
import '../../modules/parcel/feature/presentation/pages/parcel_home_page.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  GlobalKey<NavigatorState>? _navigatorKey;
  BuildContext? _context;

  /// Initialiser le service avec un GlobalKey
  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Définir le contexte actuel
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Obtenir le contexte de navigation
  BuildContext? get context => _context ?? _navigatorKey?.currentContext;

  /// Naviguer vers la page de notifications
  void navigateToNotifications() {
    final ctx = context;
    if (ctx != null) {
      try {
        ctx.router.push(const NotificationsRoute());
        print('✅ Navigation vers la page de notifications réussie');
      } catch (e) {
        print('❌ Erreur navigation vers notifications: $e');
      }
    } else {
      print('❌ Impossible d\'obtenir le contexte de navigation');
    }
  }

  /// Naviguer vers une route spécifique
  void navigateToRoute(PageRouteInfo route) {
    final ctx = context;
    if (ctx != null) {
      try {
        ctx.router.push(route);
        print('✅ Navigation vers ${route.routeName} réussie');
      } catch (e) {
        print('❌ Erreur navigation vers ${route.routeName}: $e');
      }
    } else {
      print('❌ Impossible d\'obtenir le contexte de navigation');
    }
  }

  // Méthode pour forcer la navigation vers ParcelHomePage
  static void navigateToParcelHome(BuildContext context) {
    print(
        '🚀 NavigationService: Tentative de navigation vers ParcelHomePage...');

    try {
      // Méthode 1: Navigation directe sans popUntil
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const ParcelHomePage(),
        ),
        (route) => false, // Supprimer toutes les routes
      );
      print('✅ NavigationService: Navigation directe réussie');
    } catch (e) {
      print('❌ NavigationService: Erreur navigation - $e');

      // Méthode 2: Fallback avec pushReplacement
      try {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ParcelHomePage(),
          ),
        );
        print('✅ NavigationService: Fallback réussi');
      } catch (e2) {
        print('❌ NavigationService: Toutes les méthodes ont échoué - $e2');
      }
    }
  }
}
