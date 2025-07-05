import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:liya/core/singletons.dart';
import 'package:liya/core/providers.dart';
import 'package:liya/core/services/firebase_storage_helper.dart';
import 'firebase_options.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await initSingletons();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé avec succès');

    // Diagnostic Firebase Storage
    await FirebaseStorageHelper.printDiagnostics();
    await FirebaseStorageHelper.ensureFoldersExist();
  } catch (e) {
    print('❌ Firebase init error: $e');
  }

  runApp(
      //Plugin for Internationalization i18n
      ProviderScope(
          child: EasyLocalization(
    useOnlyLangCode: true,
    supportedLocales: const [Locale('en'), Locale('fr')],
    path: 'assets/lang',
    fallbackLocale: const Locale('en', 'EN'),
    child: App(),
  )));
}
