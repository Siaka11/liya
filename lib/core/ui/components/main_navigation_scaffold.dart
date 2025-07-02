import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.dart';
import 'package:liya/modules/home/presentation/pages/home_page.dart';
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_home_page.dart';
import 'package:liya/modules/delivery/presentation/pages/home_delivery_page.dart';

class MainNavigationScaffold extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScaffold({
    super.key,
    required this.initialIndex,
  });

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Accueil (index 0)
          _buildHomePage(),
          // Colis (index 1)
          _buildParcelPage(),
          // Livreur (index 2)
          _buildDeliveryPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFFF24E1E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Colis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Livreur',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    // Retourne la page d'accueil principale
    return const HomePage();
  }

  Widget _buildParcelPage() {
    // Retourne la page des colis
    return const ParcelHomePage();
  }

  Widget _buildDeliveryPage() {
    // Retourne la page du livreur
    return const HomeDeliveryPage();
  }
}
