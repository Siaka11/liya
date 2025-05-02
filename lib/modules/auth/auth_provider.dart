

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_information.dart';
import '../../core/singletons.dart';
import '../home/domain/entities/user.dart';

class AuthProvider extends ChangeNotifier{
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void login() async{
    _isAuthenticated = true;
    await singleton<SharedPreferences>().setBool(Config.ISAUTH, true);
    notifyListeners();
  }

  Future<void> logout() async {
    singleton<LocalStorageFactory>().clearUserDetails();
    await singleton<SharedPreferences>().setBool(Config.ISAUTH, false);
  }
}

final authProvider =
ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});
