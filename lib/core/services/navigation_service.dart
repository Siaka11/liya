import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';

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
}
