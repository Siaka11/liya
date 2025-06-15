import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liya/core/singletons.dart';

import '../../core/local_storage_factory.dart';
import '../../utils/snackbar.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;



  Future verifynumpad({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required BuildContext context,
  }) async {

    //rediriger vers l'otp
    onCodeSent('123456');
    showSnackBar(context, "Code envoyé");

    return;


/*    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: '+225'+ phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _firebaseAuth.signInWithCredential(credential);
            showSnackBar(context, "Connexion réussie");
          } catch (e) {
            showSnackBar(context, "Erreur de connexion automatique : $e", isError: true);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          showSnackBar(context, "Erreur de vérification : ${e.message}", isError: true);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Délai de récupération du code expiré")),
          );
          showSnackBar(context, "Délai de récupération du code expiré", isError: true);
        },
      );
    } catch (e) {
      showSnackBar(context, "Erreur de vérification : $e", isError: true);
    }*/
  }

  Future<void> verifOtp({
    required String otp,
    required String verificationId,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      if(otp == verificationId){
        onSuccess();
      }else{
        throw Exception("Erreur de vérification");
      }
      // Exemple Firebase :
      // var credential = PhoneAuthProvider.credential(
      //   verificationId: verificationId,
      //   smsCode: otp,
      // );
      // await FirebaseAuth.instance.signInWithCredential(credential);
      // onSuccess();
    }catch (e){
      onError(e.toString());
    }
  }

  Future<void> saveUserInfo({
    required String name,
    required String lastName,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // Simuler la sauvegarde des données
      print('Saving user info: name=$name, lastName=$lastName');
      await Future.delayed(const Duration(seconds: 1));
      onSuccess();
      // Exemple Firebase :
      // var user = FirebaseAuth.instance.currentUser;
      // await user?.updateProfile(displayName: '$name $lastName');
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> saveUserLocation({
    required double latitude,
    required double longitude,
    required String address,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      print('Saving user location: lat=$latitude, lon=$longitude, address=$address');
      await singleton<LocalStorageFactory>().setUserLocation(latitude: latitude, longitude: longitude, address: address);
      // Simuler la sauvegarde (remplace par une API réelle ou Firebase)
      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }
}




