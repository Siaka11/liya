import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_information.dart';
import '../core/singletons.dart';
import '../modules/auth/auth_provider.dart';
import '../modules/auth/info_user_page.dart';
import '../modules/home/domain/entities/home_option.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter implements AutoRouteGuard {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  bool isAuthenticated() {
    return singleton<SharedPreferences>().getBool(Config.ISAUTH) ?? false;
  }

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (isAuthenticated() ||
        resolver.route.name == AuthRoute.name ||
        resolver.route.name == OtpRoute.name ||
        resolver.route.name == InfoUserRoute.name) {
      resolver.next();
    } else {
      resolver.redirect(const AuthRoute(), replace: true);
    }
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
        AutoRoute(page: DishDetailRoute.page),
        AutoRoute(page: RestaurantDetailRoute.page),
        AutoRoute(page: CartRoute.page),
        AutoRoute(page: CheckoutRoute.page),
      ];
}
