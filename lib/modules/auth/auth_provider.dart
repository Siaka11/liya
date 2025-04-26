

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthProvider extends ChangeNotifier{
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void login(){
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {

  }
}

final authProvider =
ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});