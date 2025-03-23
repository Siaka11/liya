import 'package:get_it/get_it.dart';
import 'package:liya/modules/auth/auth_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_router.dart';

final singleton = GetIt.I;

Future<void> initSingletons() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  singleton.registerSingleton<AppRouter>(AppRouter(AuthProvider()));

}