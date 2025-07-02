import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:liya/routes/app_router.gr.dart';

@RoutePage()
class SplashDeliveryPage extends StatefulWidget {
  const SplashDeliveryPage({Key? key}) : super(key: key);

  @override
  State<SplashDeliveryPage> createState() => _SplashDeliveryPageState();
}

class _SplashDeliveryPageState extends State<SplashDeliveryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.router.replace(const HomeRoute());
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.router.push(const HomeDeliveryRoute());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF24E1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Remplacer par le logo de l'app
            Icon(Icons.delivery_dining, size: 100, color: Colors.white),
            const SizedBox(height: 32),
            const Text(
              'Bienvenue Livreur',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
