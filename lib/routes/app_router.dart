
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';

import '../modules/auth/auth_provider.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter implements AutoRouteGuard{
  bool authenticated = false;
  bool alreadyAuthenticated = false;
  final AuthProvider authProvider;

  AppRouter(this.authProvider){
    authProvider.addListener(() {
      if (!authProvider.isAuthenticated) {
        reevaluateGuards();
      }
    });
  }
  bool isAuthenticated() {
    //return singleton<SharedPreferences>().getBool(Config.ISAUTH)??false;
    return false;
  }


  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {

    if (isAuthenticated()  || resolver.route.name == AuthRoute.name) {
      resolver.next();
    } else {
      push(AuthRoute());
    }

  }

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: AuthRoute.page),
  ];
}