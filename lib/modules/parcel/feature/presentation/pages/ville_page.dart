import 'package:flutter/material.dart';
import 'lieu_page.dart';
import 'package:liya/modules/home/presentation/pages/home_page.dart';
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_home_page.dart';
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';

class VillePage extends StatelessWidget {
  final String phoneNumber;
  final String typeProduit;
  final bool isReception;
  final String? colisDescription;
  final List<dynamic>? colisList;
  const VillePage(
      {Key? key,
      required this.phoneNumber,
      required this.typeProduit,
      required this.isReception,
      this.colisDescription,
      this.colisList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(isReception ? 'Je reçois un colis' : 'Je livre un colis',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Je suis à',
                style: TextStyle(
                    color: Color(0xFFF24E1E),
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 16),
            _VilleButton(
                label: 'Yamoussoukro ou ville voisine',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LieuPage(
                          phoneNumber: phoneNumber,
                          typeProduit: typeProduit,
                          isReception: isReception,
                          ville: 'Yamoussoukro ou ville voisine',
                          colisDescription: colisDescription,
                          colisList: colisList,
                        ),
                      ));
                }),
            const SizedBox(height: 16),
            _VilleButton(
                label: 'Abidjan',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LieuPage(
                          phoneNumber: phoneNumber,
                          typeProduit: typeProduit,
                          isReception: isReception,
                          ville: 'Abidjan',
                          colisDescription: colisDescription,
                          colisList: colisList,
                        ),
                      ));
                }),
          ],
        ),
      ),
      bottomNavigationBar: _ParcelBottomNavBar(),
    );
  }
}

class _VilleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _VilleButton({required this.label, required this.onTap});

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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          AutoRouter.of(context).replace(const HomeRoute());
        } else if (index == 1) {
          AutoRouter.of(context).replace(const ParcelHomeRoute());
        } else if (index == 2) {
          AutoRouter.of(context).replace(const ProfileRoute());
        }
      },
    );
  }
}
