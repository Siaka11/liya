import 'package:flutter/material.dart';
import 'colis_info_page.dart';
import 'lieu_page.dart';
import 'package:liya/modules/home/presentation/pages/home_page.dart';
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_home_page.dart';
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:liya/core/services/connection_manager.dart';
import 'package:liya/core/ui/widgets/connection_status_widget.dart';

class TypeProduitPage extends StatefulWidget {
  final String phoneNumber;
  final bool isReception;
  const TypeProduitPage(
      {Key? key, required this.phoneNumber, this.isReception = false})
      : super(key: key);

  @override
  State<TypeProduitPage> createState() => _TypeProduitPageState();
}

class _TypeProduitPageState extends State<TypeProduitPage> {
  // Gestionnaire de connexion
  final ConnectionManager _connectionManager = ConnectionManager();

  @override
  void initState() {
    super.initState();
    // Définir le contexte pour le gestionnaire de connexion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectionManager.setCurrentContext(context);
    });
  }

  @override
  void dispose() {
    _connectionManager.clearCurrentContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Je livre un colis',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          // Widget de statut de connexion
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ConnectionStatusWidget(
                showWhenConnected: false,
                showWhenDisconnected: true,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type de produit',
                style: TextStyle(
                    color: Color(0xFFF24E1E),
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 16),
            _TypeButton(
                label: 'Document',
                onTap: () {
                  // Navigation directe vers LieuPage avec ville par défaut
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => LieuPage(
                              phoneNumber: widget.phoneNumber,
                              typeProduit: 'Document',
                              isReception: widget.isReception,
                              ville:
                                  'Yamoussoukro ou ville voisine', // Ville par défaut
                              colisDescription: null,
                              colisList: null)));
                }),
            const SizedBox(height: 16),
            _TypeButton(
                label: 'Colis',
                onTap: () {
                  // Navigation directe vers LieuPage avec ville par défaut
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ColisInfoPage(
                                phoneNumber: widget.phoneNumber,
                                isReception: widget.isReception,
                              )));
                }),
          ],
        ),
      ),
      bottomNavigationBar: _ParcelBottomNavBar(),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TypeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              const Icon(Icons.chevron_right, color: Color(0xFFD1BEBE)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParcelBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, color: Colors.deepOrange),
            label: 'Mes livraisons'),
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Menu principal'),
      ],
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          AutoRouter.of(context).replace(const HomeRoute());
        } else if (index == 1) {
          AutoRouter.of(context).replace(const ParcelHomeRoute());
        } else if (index == 2) {
          AutoRouter.of(context).replace(const HomeRoute());
        }
      },
    );
  }
}
