import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OTPDebugger {
  static Future<void> debugOTPState() async {
    print('🔍 === DIAGNOSTIC OTP ===');

    try {
      // 1. Vérifier l'état de Firebase Auth
      print('\n📱 1. État Firebase Auth:');
      final currentUser = FirebaseAuth.instance.currentUser;
      print('   - Utilisateur connecté: ${currentUser != null}');
      if (currentUser != null) {
        print('   - Phone: ${currentUser.phoneNumber}');
        print('   - UID: ${currentUser.uid}');
        print('   - Email verified: ${currentUser.emailVerified}');
      }

      // 2. Vérifier SharedPreferences
      print('\n💾 2. État SharedPreferences:');
      final prefs = await SharedPreferences.getInstance();
      final verificationId = prefs.getString('verification_id');
      final timestamp = prefs.getInt('verification_id_timestamp');
      final isAuth = prefs.getBool('isAuth');

      print('   - VerificationId: ${verificationId?.substring(0, 10)}...');
      print('   - Timestamp: $timestamp');
      print('   - IsAuth: $isAuth');

      if (timestamp != null) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final timeDiff = currentTime - timestamp;
        final minutesDiff = timeDiff / (1000 * 60);
        print(
            '   - Âge du verificationId: ${minutesDiff.toStringAsFixed(1)} minutes');
        print('   - Expiré (>10min): ${minutesDiff > 10}');
      }

      // 3. Vérifier Firestore
      print('\n🔥 3. État Firestore:');
      if (currentUser?.phoneNumber != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.phoneNumber)
            .get();

        print('   - Document existe: ${userDoc.exists}');
        if (userDoc.exists) {
          final data = userDoc.data()!;
          print(
              '   - FCM Token: ${data['fcm_token'] != null ? 'Présent' : 'Absent'}');
          print('   - Dernière mise à jour: ${data['updated_at']}');
        }
      } else {
        print('   - Pas d\'utilisateur connecté pour vérifier Firestore');
      }

      // 4. Recommandations
      print('\n💡 4. Recommandations:');
      if (verificationId == null) {
        print('   - Aucun verificationId trouvé → Redemander un OTP');
      } else if (timestamp != null) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final timeDiff = currentTime - timestamp;
        if (timeDiff > 10 * 60 * 1000) {
          print('   - VerificationId expiré → Nettoyer et redemander un OTP');
        } else {
          print('   - VerificationId valide → Peut être utilisé');
        }
      }

      if (currentUser == null) {
        print(
            '   - Pas d\'utilisateur connecté → Processus d\'authentification nécessaire');
      }
    } catch (e) {
      print('❌ Erreur lors du diagnostic: $e');
    }

    print('\n🔍 === FIN DIAGNOSTIC ===');
  }

  static Future<void> clearAllOTPData() async {
    print('🗑️ === NETTOYAGE COMPLET OTP ===');

    try {
      // 1. Nettoyer SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('verification_id');
      await prefs.remove('verification_id_timestamp');
      await prefs.remove('isAuth');
      print('✅ SharedPreferences nettoyé');

      // 2. Déconnecter Firebase Auth
      await FirebaseAuth.instance.signOut();
      print('✅ Firebase Auth déconnecté');

      print('✅ Nettoyage complet terminé');
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }

    print('🗑️ === FIN NETTOYAGE ===');
  }
}
