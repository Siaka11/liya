import 'package:flutter/material.dart';
import 'ville_page.dart';
import 'colis_info_page.dart';
import 'package:liya/modules/home/presentation/pages/home_page.dart';
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_home_page.dart';
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';

class TypeProduitPage extends StatelessWidget {
  final String phoneNumber;
  final bool isReception;
  const TypeProduitPage(
      {Key? key, required this.phoneNumber, this.isReception = false})
      : super(key: key);

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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => VillePage(
                              phoneNumber: phoneNumber,
                              typeProduit: 'Document',
                              isReception: isReception)));
                }),
            const SizedBox(height: 16),
            _TypeButton(
                label: 'Colis',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ColisInfoPage(
                                phoneNumber: phoneNumber,
                                isReception: isReception,
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
