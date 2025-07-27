import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../../core/local_storage_factory.dart';
import '../../../core/singletons.dart';
import '../../../routes/app_router.dart';
import 'package:liya/routes/app_router.gr.dart';
import '../../delivery/presentation/pages/splash_delivery_page.dart';
import '../data/datasources/home_local_datasource.dart';
import '../data/repositories/home_repository_impl.dart';
import 'package:liya/modules/home/domain/entities/home_option.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_home_options.dart';
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_home_page.dart';
import 'package:liya/modules/auth/auth_provider.dart'; // Ajout de l'import

class HomeState {
  final List<HomeOption> options;
  final bool isLoading;
  final String? error;
  final User user;

  const HomeState({
    this.options = const [],
    this.isLoading = false,
    this.error,
    this.user = const User(name: '', lastName: ''),
  });

  HomeState copyWith({
    List<HomeOption>? options,
    bool? isLoading,
    String? error,
    User? user,
  }) {
    return HomeState(
      options: options ?? this.options,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final GetHomeOptions getHomeOptions;
  final Ref ref; // Ajout de Ref pour accéder aux autres providers

  HomeNotifier(this.getHomeOptions, this.ref) : super(const HomeState()) {
    _init();
    _listenToAuthChanges(); // Écouter les changements d'authentification
  }

  Future<void> _init() async {
    await _loadUserData();
    await fetchOptions();
  }

  /// Écouter les changements d'authentification pour rafraîchir les données utilisateur
  void _listenToAuthChanges() {
    // Écouter les changements du AuthProvider
    ref.listen<AuthProvider>(authProvider, (previous, next) {
      if (next.isAuthenticated &&
          previous?.isAuthenticated != next.isAuthenticated) {
        print(
            '🔄 Changement d\'authentification détecté - rafraîchissement des données utilisateur');
        refreshUser();
      }
    });
  }

  Future<void> _loadUserData() async {
    print('🔄 Loading user data');
    state = state.copyWith(isLoading: true);
    try {
      final userDetails = singleton<LocalStorageFactory>().getUserDetails();
      print('🔍 UserDetails from LocalStorage: $userDetails');

      final userJson = jsonDecode(userDetails) as Map<String, dynamic>;
      print('🔍 UserJson decoded: $userJson');

      final user = User.fromJson(userJson);
      print('🔍 User object created: ${user.name} ${user.lastName}');

      state = state.copyWith(user: user, isLoading: false);
      print(
          '✅ State updated with user: ${state.user.name} ${state.user.lastName}');
    } catch (e) {
      print('❌ Error loading user data: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        user: const User(
            name: '', lastName: ''), // Valeur par défaut en cas d'erreur
      );
    }
  }

  Future<void> refreshUser() async {
    print('Refreshing user data');
    await _loadUserData(); // ça recharge depuis LocalStorage et update state
  }

  Future<void> fetchOptions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final options = await getHomeOptions();
      state = state.copyWith(options: options, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Map pour associer les titres aux routes
  final _routeMap = {
    'Je commande un plat': (context, option) =>
        AutoRouter.of(context).push(HomeRestaurantRoute(option: option)),
    "J'expédie un colis": (context, option) => Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ParcelHomePage())),
    'Je livrer': (context, option) =>
        AutoRouter.of(context).push(const SplashDeliveryRoute()),
    //'Faire des courses': (context, option) => singleton<AppRouter>().push(const ShoppingRoute()),
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

  Future<void> logout() async {
    print('Logging out from HomeNotifier');
    state = state.copyWith(user: const User(name: '', lastName: ''));
    await _loadUserData(); // Recharger les données pour refléter l'état local
  }
}

// Dépendances
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final localDataSource = HomeLocalDataSourceImpl();
  return HomeRepositoryImpl(localDataSource);
});

final getHomeOptionsProvider = Provider<GetHomeOptions>((ref) {
  final repository = ref.read(homeRepositoryProvider);
  return GetHomeOptions(repository);
});

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final getHomeOptions = ref.read(getHomeOptionsProvider);
  return HomeNotifier(getHomeOptions, ref);
});
