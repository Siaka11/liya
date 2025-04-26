
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:liya/core/ui/components/custom_button.dart';
import 'package:liya/core/ui/components/custom_field.dart';
import 'package:liya/modules/auth/login_provider.dart';


@RoutePage()
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _animation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }


  @override
  Widget build(BuildContext context) {
    final _loginProviderForm = ref.read(loginProvider.notifier);
    final _loginProvider = ref.watch(loginProvider);
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
            padding: const EdgeInsets.all(26.0),
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
                const SizedBox(height: 10),
                const Text(
                  "Ce numéro recevra un code de confirmation",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                    child: CustomField(
                      controller: _loginProviderForm.phoneController,
                      fontSize: 21,
                      prefixText: "+225 ",
                      paddingLeft: 12,
                      keyboardType: TextInputType.phone,
                    ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    (_loginProvider.hasError)
                        ? Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _loginProvider.errorText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                    ): Container(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Envoyer",
                  borderRaduis: 50,
                  onPressedButton: () => _loginProviderForm.submit(context),
                  bgColor: Colors.orange,
                  fontSize: 18,
                  paddingVertical: 18,
                ),

              ),
            ),
          ),
        ],
      ),
    );
  }

}

