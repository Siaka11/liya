import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart'; // Pour defaultTargetPlatform
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_home_page.dart';
import 'package:liya/modules/restaurant/features/order/presentation/pages/order_detail_page.dart';
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart';
import 'package:liya/modules/restaurant/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:liya/modules/restaurant/features/profile/presentation/pages/edit_email_page.dart';
import 'package:liya/modules/restaurant/features/profile/presentation/pages/edit_phone_page.dart';
import 'package:liya/modules/restaurant/features/order/presentation/pages/order_details_full_page.dart';
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_details_full_page.dart';
import 'package:liya/modules/delivery/presentation/pages/delivery_admin_dashboard_page.dart';
import 'package:liya/modules/delivery/presentation/pages/delivery_navigation_page.dart';
import 'package:liya/modules/admin/presentation/pages/restaurant_management_page.dart';
import 'package:liya/modules/admin/presentation/pages/dish_management_page.dart';
import 'package:liya/modules/admin/presentation/pages/delivery_user_management_page.dart';
import 'package:liya/modules/admin/presentation/pages/image_management_page.dart';
import 'package:liya/modules/admin/presentation/pages/assignment_management_page.dart';
import 'package:liya/modules/admin/presentation/pages/role_permission_management_page.dart';
import 'package:liya/modules/restaurant/features/notifications/presentation/pages/notifications_page.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_information.dart';
import '../core/singletons.dart';
import '../core/providers/guest_mode_provider.dart'; // Provider mode invité
import '../modules/auth/auth_provider.dart';
import '../modules/auth/auth_page.dart';
import '../modules/auth/otp_page.dart';
import '../modules/auth/info_user_page.dart';
import '../modules/auth/presentation/pages/delete_account_page.dart';
import '../modules/share_location_page.dart';
import '../modules/home/presentation/pages/home_page.dart';
import '../modules/home/presentation/pages/user_profile_page.dart';
import '../modules/admin/presentation/pages/admin_dashboard_page.dart';
import '../modules/parcel/feature/presentation/pages/lieu_page.dart';
import '../modules/parcel/feature/presentation/pages/parcel_status_list_page.dart';
import '../modules/restaurant/features/home/presentation/pages/home_restaurant.dart';
import '../modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart';
import '../modules/restaurant/features/order/presentation/pages/order_list_page.dart';
import '../modules/restaurant/features/checkout/presentation/pages/checkout_page.dart';
import '../modules/restaurant/features/like/presentation/pages/liked_dishes_page.dart';
import '../modules/restaurant/features/search/presentation/pages/search_page.dart';
import '../modules/delivery/presentation/pages/delivery_dashboard_page.dart';
import '../modules/delivery/presentation/pages/delivery_assignment_page.dart';
import '../modules/admin/presentation/pages/order_management_page.dart';
import '../modules/admin/presentation/pages/statistics_page.dart';
import '../modules/admin/presentation/pages/add_dish_page.dart';
import '../modules/admin/presentation/pages/edit_dish_page.dart';
import '../modules/admin/presentation/pages/promotion_management_page.dart';
import '../modules/admin/presentation/pages/user_management_page.dart';
import '../modules/admin/presentation/pages/category_management_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter implements AutoRouteGuard {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  bool isAuthenticated() {
    return singleton<SharedPreferences>().getBool(Config.ISAUTH) ?? false;
  }

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Utiliser un Future.microtask pour gérer l'asynchrone
    Future.microtask(() async {
      try {
        // Vérifier l'état d'authentification et synchroniser
        final isUserAuthenticated = await authProvider.checkAuthStateAndSync();

        // Pages accessibles sans authentification
        final publicRoutes = [
          AuthRoute.name,
          OtpRoute.name,
          InfoUserRoute.name,
          HomeRoute.name, // Accessible en mode invité sur iOS
        ];

        // Pages accessibles en mode invité sur iOS
        final guestModeRoutes = [
          HomeRoute.name,
          HomeRestaurantRoute.name, // Restaurant accessible en mode invité
          ParcelHomeRoute.name, // Colis accessible en mode invité
          SearchRoute.name, // Recherche accessible en mode invité
          AllRestaurantsRoute.name, // Liste restaurants accessible
          AllDishesRoute.name, // Liste plats accessible
          DishDetailRoute.name, // Détails plat accessible
          ModernRestaurantDetailRoute.name, // Détails restaurant accessible
          ModernDishDetailRoute.name, // Détails plat moderne accessible
          CheckoutRoute.name, // Checkout accessible en mode invité pour afficher l'invite à s'authentifier
        ];

        // Vérifier si on est sur iOS et en mode invité
        final prefs = singleton<SharedPreferences>();
        var isGuestMode = prefs.getBool('is_guest_mode') ?? false;
        final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

        // Si l'utilisateur est authentifié, désactiver automatiquement le mode invité
        // (comme le fait guestModeProvider.isGuestMode)
        if (isUserAuthenticated && isGuestMode) {
          await prefs.setBool('is_guest_mode', false);
          isGuestMode = false;
          print('🔄 Mode invité désactivé automatiquement (utilisateur authentifié)');
        }

        // Si on arrive sur AuthRoute
        if (resolver.route.name == AuthRoute.name) {
          if (isUserAuthenticated) {
            // Utilisateur authentifié, rediriger vers HomeRoute
            resolver.redirect(HomeRoute(), replace: true);
            return;
          } else {
            // Utilisateur NON authentifié : TOUJOURS rester sur AuthRoute
            // Peu importe le mode invité, si l'utilisateur arrive sur AuthRoute, il doit y rester
            // Le mode invité permet seulement d'accéder directement à HomeRoute, pas via AuthRoute
            resolver.next();
            return;
          }
        }

        // Permettre l'accès si:
        // 1. L'utilisateur est authentifié
        // 2. La route est publique
        // 3. On est sur iOS en mode invité et on va vers une route autorisée pour les invités
        if (isUserAuthenticated ||
            publicRoutes.contains(resolver.route.name) ||
            (isIOS && isGuestMode && guestModeRoutes.contains(resolver.route.name))) {
          resolver.next();
        } else {
          // Sur Android, toujours rediriger vers l'authentification
          if (!isIOS || !isGuestMode) {
            resolver.redirect(const AuthRoute(), replace: true);
          } else {
            // Sur iOS en mode invité, rediriger vers le home
            resolver.redirect(HomeRoute(), replace: true);
          }
        }
      } catch (e) {
        print('❌ Erreur dans onNavigation: $e');
        // En cas d'erreur, rediriger vers l'auth sauf si iOS en mode invité
        final prefs = singleton<SharedPreferences>();
        final isGuestMode = prefs.getBool('is_guest_mode') ?? false;
        final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

        // Pages autorisées en mode invité
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

        if (isIOS && isGuestMode && guestModeRoutes.contains(resolver.route.name)) {
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
