import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/loading_provider.dart';
import 'package:liya/core/singletons.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/modules/auth/auth_provider.dart';
import 'package:liya/routes/app_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:liya/core/services/navigation_service.dart';

final appNameProvider = Provider((_) => 'LIYA');

GlobalKey<State<BottomNavigationBar>> bottomNavigationBar =
    GlobalKey<State<BottomNavigationBar>>();

GlobalKey<NavigatorState> rootNavigatorKey =
    singleton<AppRouter>().navigatorKey;

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class App extends ConsumerWidget {
  App({super.key});

  final _appRouter = singleton<AppRouter>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String appName = ref.read(appNameProvider);
    
    // Initialiser le NavigationService avec le GlobalKey
    NavigationService().initialize(rootNavigatorKey);

    return MaterialApp.router(
      title: appName,
      theme: ThemeData(primarySwatch: LiyaColor),
      routerConfig: _appRouter.config(
        reevaluateListenable: ref.watch(authProvider),
      ),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      builder: (context, widget) {
        EasyLoading.init();
        final isLoading = ref.watch(loadingProvider);
        if (isLoading) {
          print('⚠️ LoadingProvider est actif, cela peut bloquer l\'interface');
        }
        return Stack(children: [
          widget!,
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ]);
      },
    );
  }
}
