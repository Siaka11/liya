import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/singletons.dart';
import 'package:liya/modules/auth/auth_service.dart';
import 'package:liya/routes/app_router.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/loading_provider.dart';
import '../../core/local_storage_factory.dart';
import '../home/application/home_provider.dart';
import 'auth_provider.dart';

enum InfoUserStatus { Empty, Processing, Error, Success }

class InfoUserState {
  final String name;
  final String lastName;
  final bool hasError;
  final String errorText;
  final InfoUserStatus status;

  const InfoUserState({
    this.name = '',
    this.lastName = '',
    this.hasError = false,
    this.errorText = '',
    this.status = InfoUserStatus.Empty,
  });

  InfoUserState copyWith({
    String? name,
    String? lastName,
    bool? hasError,
    String? errorText,
    InfoUserStatus? status,
  }) {
    return InfoUserState(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      hasError: hasError ?? this.hasError,
      errorText: errorText ?? this.errorText,
      status: status ?? this.status,
    );
  }
}

class InfoUserNotifier extends StateNotifier<InfoUserState> {
  final Ref ref;

  InfoUserNotifier(this.ref) : super(const InfoUserState());

  void updateName(String name) {
    state = state.copyWith(name: name, status: InfoUserStatus.Empty);
  }

  void updateLastName(String lastName) {
    state = state.copyWith(lastName: lastName, status: InfoUserStatus.Empty);
  }

  Future<void> submit(BuildContext context) async {
    final name = state.name.trim();
    final lastName = state.lastName.trim();

    print('Submitting user info: name=$name, lastName=$lastName');

    state = state.copyWith(
      hasError: false,
      errorText: '',
      status: InfoUserStatus.Processing,
    );
    ref.read(loadingProvider.notifier).start();

    if (name.isEmpty || lastName.isEmpty) {
      print('Validation failed: Empty fields');
      state = state.copyWith(
        hasError: true,
        errorText: 'Veuillez remplir tous les champs.',
        status: InfoUserStatus.Error,
      );
      ref.read(loadingProvider.notifier).complete();
      return;
    }

    try {
      await AuthService().saveUserInfo(
        name: name,
        lastName: lastName,
        onSuccess: () {
          state = state.copyWith(
            hasError: false,
            errorText: '',
            status: InfoUserStatus.Success,
          );
          var userDetail = {"name": name, "lastName": lastName};
          singleton<LocalStorageFactory>().setUserDetails(userDetail);
          ref.read(authProvider).login();
          ref.read(homeProvider.notifier).refreshUser();
          singleton<AppRouter>().replace(const ShareLocationRoute());
          print('User info saved successfully');
        },
        onError: (error) {
          state = state.copyWith(
            hasError: true,
            errorText: error,
            status: InfoUserStatus.Error,
          );
        },
      );
    } catch (e) {
      print('Error saving user info: $e');
      state = state.copyWith(
        hasError: true,
        errorText: e.toString(),
        status: InfoUserStatus.Error,
      );
    } finally {
      ref.read(loadingProvider.notifier).complete();
    }
  }

  void reset() {
    state = const InfoUserState();
  }
}

final infoUserProvider = StateNotifierProvider<InfoUserNotifier, InfoUserState>(
      (ref) => InfoUserNotifier(ref),
);