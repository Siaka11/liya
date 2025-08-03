import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // État initial: non en chargement

  /// Met l'état de chargement à vrai (affiche l'indicateur)
  void start() {
    state = true;
  }

  /// Met l'état de chargement à faux (cache l'indicateur)
  void complete() {
    state = false;
  }
}

final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>(
      (ref) => LoadingNotifier(),
);