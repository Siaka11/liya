import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_information.dart';
import '../core/singletons.dart';
import '../modules/auth/auth_provider.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter implements AutoRouteGuard {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  bool isAuthenticated() {
    return singleton<SharedPreferences>().getBool(Config.ISAUTH) ?? false;
  }

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Pages accessibles sans authentification
    final publicRoutes = [
      AuthRoute.name,
      OtpRoute.name,
      InfoUserRoute.name,
    ];

    // Routes accessibles en mode invité sur iOS
    final guestModeRoutes = [
      HomeRoute.name,
      HomeRestaurantRoute.name,
      ParcelHomeRoute.name,
      SearchRoute.name,
      AllRestaurantsRoute.name,
      AllDishesRoute.name,
      DishDetailRoute.name,
      ModernRestaurantDetailRoute.name,
      ModernDishDetailRoute.name,
      CheckoutRoute.name,
    ];

    // Si c'est une route publique, autoriser immédiatement
    if (publicRoutes.contains(resolver.route.name)) {
      resolver.next();
      return;
    }

    // Pour les autres routes, vérifier l'authentification de manière non-bloquante
    Future.microtask(() async {
      try {
        final prefs = singleton<SharedPreferences>();
        final isAuthLocally = prefs.getBool(Config.ISAUTH) ?? false;
        final isUserAuthenticated = isAuthLocally || authProvider.isAuthenticated;
        final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
        var isGuestMode = prefs.getBool('is_guest_mode') ?? false;

        // Si l'utilisateur est authentifié, désactiver le mode invité
        if (isUserAuthenticated && isGuestMode) {
          await prefs.setBool('is_guest_mode', false);
          isGuestMode = false;
        }

        // Autoriser l'accès si authentifié ou en mode invité iOS
        if (isUserAuthenticated ||
            (isIOS && isGuestMode && guestModeRoutes.contains(resolver.route.name))) {
          resolver.next();
        } else {
          resolver.redirect(const AuthRoute(), replace: true);
        }
      } catch (e) {
        print('❌ Erreur dans onNavigation: $e');
        // En cas d'erreur, autoriser AuthRoute, sinon rediriger vers AuthRoute
        if (resolver.route.name == AuthRoute.name) {
          resolver.next();
        } else {
          resolver.redirect(const AuthRoute(), replace: true);
        }
      }
    });
  }

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: AuthRoute.page, initial: true),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: OtpRoute.page),
        AutoRoute(page: InfoUserRoute.page),
        AutoRoute(page: DeleteAccountRoute.page),
        AutoRoute(page: ShareLocationRoute.page),
        AutoRoute(page: HomeRestaurantRoute.page),
        AutoRoute(page: DishDetailRoute.page),
        AutoRoute(page: ModernRestaurantDetailRoute.page),
        AutoRoute(page: CartRoute.page),
        AutoRoute(page: CheckoutRoute.page),
        AutoRoute(page: ProfileRoute.page),
        AutoRoute(page: UserProfileRoute.page),
        AutoRoute(page: EditProfileRoute.page),
        AutoRoute(page: EditEmailRoute.page),
        AutoRoute(page: EditPhoneRoute.page),
        AutoRoute(page: OrderDetailsFullRoute.page),
        AutoRoute(page: ParcelDetailsFullRoute.page),
        AutoRoute(page: SearchRoute.page),
        AutoRoute(page: OrderListRoute.page),
        AutoRoute(page: OrderDetailRoute.page),
        AutoRoute(page: LikedDishesRoute.page),
        AutoRoute(page: AllRestaurantsRoute.page),
        AutoRoute(page: AllDishesRoute.page),
        AutoRoute(page: DishImageEditorRoute.page),
        AutoRoute(page: DishListRoute.page),
        AutoRoute(page: RestaurantSelectRoute.page),
        AutoRoute(page: ParcelListRoute.page),
        AutoRoute(page: AddParcelRoute.page),
        AutoRoute(page: ParcelDetailRoute.page),
        AutoRoute(page: LieuRoute.page),
        AutoRoute(page: ParcelHomeRoute.page),
        AutoRoute(page: ModernHomeRestaurantRoute.page),
        AutoRoute(page: ModernRestaurantDetailRoute.page),
        AutoRoute(page: ModernDishDetailRoute.page),
        AutoRoute(page: SplashDeliveryRoute.page),
        AutoRoute(page: HomeDeliveryRoute.page),
        AutoRoute(page: DeliveryListRoute.page),
        AutoRoute(page: DeliveryDetailRoute.page),
        AutoRoute(page: EarningsRoute.page),
        AutoRoute(page: DeliveryProfileRoute.page),
        AutoRoute(page: StatusRoute.page),
        AutoRoute(page: DeliveryAdminDashboardRoute.page),
        AutoRoute(page: DeliveryAssignmentRoute.page),
        AutoRoute(page: AdminDashboardRoute.page),
        AutoRoute(page: RestaurantManagementRoute.page),
        AutoRoute(page: DishManagementRoute.page),
        AutoRoute(page: DeliveryUserManagementRoute.page),
        AutoRoute(page: RestaurantEditRoute.page),
        AutoRoute(page: NotificationsRoute.page),
        AutoRoute(page: OrderManagementRoute.page),
        AutoRoute(page: StatisticsRoute.page),
        AutoRoute(page: AddDishRoute.page),
        AutoRoute(page: EditDishRoute.page),
        AutoRoute(page: PromotionManagementRoute.page),
        AutoRoute(page: UserManagementRoute.page),
        AutoRoute(page: CategoryManagementRoute.page),
        AutoRoute(page: ImageManagementRoute.page),
        AutoRoute(page: AssignmentManagementRoute.page),
        AutoRoute(page: RolePermissionManagementRoute.page),
      ];
}
