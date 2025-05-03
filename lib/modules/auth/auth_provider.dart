

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_information.dart';
import '../../core/singletons.dart';
import '../home/domain/entities/user.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  AuthProvider() {
    _loadAuthState();
  }

  bool get isAuthenticated => _isAuthenticated;

  Future<void> _loadAuthState() async {
    _isAuthenticated = singleton<SharedPreferences>().getBool(Config.ISAUTH) ?? false;
    notifyListeners();
  }

  Future<void> login() async {
    _isAuthenticated = true;
    await singleton<SharedPreferences>().setBool(Config.ISAUTH, true);
    notifyListeners();
  }

  Future<void> logout() async {
    print('Logging out - Before: $_isAuthenticated');
    _isAuthenticated = false;
    singleton<LocalStorageFactory>().clearUserDetails();
    await singleton<SharedPreferences>().setBool(Config.ISAUTH, false);
    print('Logging out - After: $_isAuthenticated');
    notifyListeners();
  }
}

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});
