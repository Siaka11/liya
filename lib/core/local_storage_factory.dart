

import 'dart:convert';
import 'dart:ui';

import 'package:liya/core/singletons.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum SupportedLocale {
  fr,
  en,
}

extension SupportedLocaleExt on SupportedLocale {
  String get code => this == SupportedLocale.fr ? 'fr' : 'en';
}

class LocalStorageFactory {
  static const _LOCALE_KEY = 'locale';

  set(key, value) {
    singleton<SharedPreferences>().setString(key, value);
  }

  get(key, defaultValue) {
    return singleton<SharedPreferences>().get(key) ?? defaultValue;
  }

  getInt(key, defaultValue) {
    return singleton<SharedPreferences>().getInt(key) ?? defaultValue;
  }

  setObject(key, value) {
    singleton<SharedPreferences>().setString(key, jsonEncode(value));
  }

  getObject(key) {
    return singleton<SharedPreferences>().get(key) ?? '{}';
  }

  setUserDetails(data) {
    setObject("UserDetails", data);
  }

  setAppModules(data) {
    setObject("AppModules", data);
  }

  setUserSetting(data) {
    setObject("UserSetting", data);
  }

  void clearUserDetails() {
    singleton<SharedPreferences>().remove("UserDetails");
  }

  static getUserSetting() {
    var gUser = '{}'; // getObject("UserSetting");
    if (gUser == "") {
      gUser = {
        "language": 'fr_FR',
        "notification": '',
      } as String;
    }
    return gUser;
  }

  getUserDetails() {
    return getObject("UserDetails");
  }

  getAppModules() {
    return getObject("AppModules");
  }

  getOffset(docType) {
    var key = docType + "Offset";
    return getObject(key);
  }

  setOffset(offSet) {
    var key = offSet.docType + "Offset";
    setObject(key, offSet);
  }

  getSyncDate() {
    var date = get("SyncDate", null);
    return date;
  }

  setSyncDate(date) {
    set("SyncDate", date);
  }

  getNotificationCounter() {
    var notifs = get("Notifications", "[]");
    var decodedNotifs = jsonDecode(notifs);
    var counter = decodedNotifs.length;
    if (counter > 100) {
      counter = 100;
    }
    return counter;
  }


  getInitialRunFlag(flag) {
    return get('InitialRunFlag', flag);
  }

  setInitialRunFlag(flag) {
    set('InitialRunFlag', flag);
  }

  static void saveLocale(SupportedLocale locale) {
    singleton<SharedPreferences>().setString(_LOCALE_KEY, locale.code);
  }

  static Locale getLocale() {
    final String localeCode = singleton<SharedPreferences>().getString(_LOCALE_KEY) ?? 'fr';
    return Locale(localeCode);
  }

  static String getLocaleName() {
    return getLocale().languageCode == "fr" ? "Français" : "English";
  }

  getNotifications() {
    return get("Notifications", "[]");
  }

  setNotifications(List notifications) {
    return set("Notifications", jsonEncode(notifications));
  }

  addNotifications(List notifications) async {
    List notifs = await jsonDecode(getNotifications());
    notifs.addAll(notifications);
    await setNotifications(notifs);
  }

  void removeNotifAtIndex(int index) {
    List notifs = jsonDecode(getNotifications());
    notifs.removeAt(index);
    setNotifications(notifs);
  }

  void removeNotifAll() {
    List notifs = jsonDecode(getNotifications());
    notifs.clear();
    setNotifications(notifs);
  }

  getNotifsSetting() {}

  initNotifsSettings() {
    final String localeCode = singleton<SharedPreferences>().getString(_LOCALE_KEY) ?? 'fr';
  }

  // Nouvelles méthodes pour gérer la localisation
   setUserLocation({required double latitude, required double longitude, required String address}) {
    final locationData = {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
    setObject("UserLocation", locationData);
  }

  Map<String, dynamic> getUserLocation() {
    final locationData = getObject("UserLocation");
    return jsonDecode(locationData);
  }
}