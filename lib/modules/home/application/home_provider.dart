
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/local_storage_factory.dart';
import '../../../core/singletons.dart';
import '../../../routes/app_router.dart';
import '../data/datasources/home_local_datasource.dart';
import '../data/repositories/home_repository_impl.dart';
import 'package:liya/modules/home/domain/entities/home_option.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_home_options.dart';

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


  HomeNotifier(this.getHomeOptions) : super(const HomeState()) {
    _init();
  }
  Future<void> _init() async {
    await _loadUserData();
    await fetchOptions();
  }

  Future<void> _loadUserData() async {
    print('Loading user data');
    state = state.copyWith(isLoading: true);
    try {
      final userDetails = singleton<LocalStorageFactory>().getUserDetails();
      final userJson = jsonDecode(userDetails) as Map<String, dynamic>;
      final user = User.fromJson(userJson);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      print('Error loading user data: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        user: const User(name: '', lastName: ''), // Valeur par défaut en cas d'erreur
      );
    }
  }

  Future<void> refreshUser() async {
    print('Refreshing user data');
    await _loadUserData();  // ça recharge depuis LocalStorage et update state
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
  void onOptionSelected(BuildContext context, HomeOption option) {
    if (option.title == 'Administrateur') {
      print('Administrateur');
      //singleton<AppRouter>().push(const AdminRoute());
    } else {
      print('Commande');
      //singleton<AppRouter>().push(OrderRoute(option: option));
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
  return HomeNotifier(getHomeOptions);
});