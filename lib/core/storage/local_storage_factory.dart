import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageFactory {
  static const String _userDetailsKey = 'user_details';

  Future<void> saveUserDetails(Map<String, dynamic> userDetails) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDetailsKey, jsonEncode(userDetails));
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userDetailsJson = prefs.getString(_userDetailsKey);
    if (userDetailsJson == null) return {};
    try {
      return jsonDecode(userDetailsJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDetailsKey);
  }
}
