import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/singletons.dart';
import 'package:liya/modules/auth/auth_service.dart';
import 'package:liya/routes/app_router.dart';
import 'package:liya/routes/app_router.gr.dart';
import '../../core/loading_provider.dart';

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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  InfoUserNotifier(this.ref) : super(const InfoUserState()) {
    nameController.addListener(_updateState);
    lastNameController.addListener(_updateState);
  }

  void _updateState() {
    state = state.copyWith(
      name: nameController.text.trim(),
      lastName: lastNameController.text.trim(),
      status: InfoUserStatus.Empty,
    );
  }

  Future<void> submit(BuildContext context) async {
    print('Submitting user info: name=${nameController.text}, lastName=${lastNameController.text}');
    state = state.copyWith(
      hasError: false,
      errorText: '',
      status: InfoUserStatus.Processing,
    );
    ref.read(loadingProvider.notifier).start();

    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();

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
          // Naviguer vers la page suivante
          singleton<AppRouter>().replace(const HomeRoute()); // Ajuste selon ta route
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
    nameController.clear();
    lastNameController.clear();
    state = const InfoUserState();
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}

final infoUserProvider = StateNotifierProvider<InfoUserNotifier, InfoUserState>(
      (ref) => InfoUserNotifier(ref),
);