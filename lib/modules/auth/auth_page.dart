import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:liya/core/ui/components/custom_button.dart';
import 'package:liya/core/ui/components/custom_number_field.dart';

@RoutePage()
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..forward();

    _animation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _verifyPhone() async {
   // await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
    print("Avant d'envoyer le SMS");
    //String phone = "+225" + _phoneController.text.trim();
    String phone = "+2250102030405";
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 60),  // Augmenter le délai
      verificationCompleted: (PhoneAuthCredential credential) {
        print("Vérification automatique réussie");
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Erreur lors de la vérification : ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        print("Code envoyé avec succès : $verificationId");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Timeout, code non reçu.");
      },
    );
    print("Après l'envoi du SMS");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade700, Colors.deepOrange.shade900],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animation.value * 300 - 60),
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/img/basilique.png',
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.all(26.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  height: 180.0,
                  width: 180.0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
          // Contenu UI
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 200.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "VEUILLEZ SAISIR VOTRE NUMERO S'IL VOUS PLAÎT",
                  style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
                  textDirection: TextDirection.ltr,
                ),
                SizedBox(height: 10),
                const Text(
                  "Ce numéro recevra un code de confirmation",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                  textDirection: TextDirection.ltr,
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                    child: CustomerNumberField(
                      controller: _phoneController,
                      fontSize: 21,
                      prefixText: "+225 ",
                      paddingLeft: 12,
                      keyboardType: TextInputType.phone,
                    ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Envoyer",
                  borderRaduis: 50,
                  onPressedButton: _verifyPhone,
                  bgColor: Colors.orange,
                  fontSize: 18,
                  paddingVertical: 18,
                ),
                // child: ElevatedButton(
                //   onPressed: _verifyPhone,
                //   style: ElevatedButton.styleFrom(
                //     padding: EdgeInsets.symmetric(vertical: 15),
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                //   ),
                //   child: Text("Envoyer", style: TextStyle(fontSize: 16)),
                // ),

              ),
            ),
          ),
        ],
      ),
    );
  }

}

