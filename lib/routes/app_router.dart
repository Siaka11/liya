import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
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
import '../core/test_delivery_tracking.dart';
import '../modules/auth/auth_provider.dart';
import '../modules/auth/auth_page.dart';
import '../modules/auth/otp_page.dart';
import '../modules/auth/info_user_page.dart';
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

        if (isUserAuthenticated ||
            resolver.route.name == AuthRoute.name ||
            resolver.route.name == OtpRoute.name ||
            resolver.route.name == InfoUserRoute.name) {
          resolver.next();
        } else {
          resolver.redirect(const AuthRoute(), replace: true);
        }
      } catch (e) {
        print('❌ Erreur dans onNavigation: $e');
        // En cas d'erreur, rediriger vers l'auth
        resolver.redirect(const AuthRoute(), replace: true);
      }
    });
  }

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: AuthRoute.page),
        AutoRoute(page: OtpRoute.page),
        AutoRoute(page: InfoUserRoute.page),
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
        AutoRoute(page: TestBeveragesRoute.page),
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
