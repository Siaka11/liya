import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/parcel_provider.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/entities/parcel_status.dart';
import 'type_produit_page.dart';
import 'parcel_status_list_page.dart';
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'dart:convert';
import 'parcel_search_page.dart';

class ParcelHomePage extends ConsumerWidget {
  const ParcelHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcelsAsync = ref.watch(parcelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF24E1E),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ParcelSearchPage()));
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher une livraison',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: parcelsAsync.when(
                data: (parcels) {
                  final statusCounts = _getStatusCounts(parcels);
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 16),
                      _StatusRow(
                        icon: Icons.inbox,
                        label: 'RECEPTION',
                        count: statusCounts['RECEPTION'] ?? 0,
                        color: Colors.black,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ParcelStatusListPage(status: 'RECEPTION'),
                              ));
                        },
                      ),
                      _StatusRow(
                        icon: Icons.local_shipping,
                        label: 'EN ROUTE',
                        count: statusCounts['EN ROUTE'] ?? 0,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ParcelStatusListPage(status: 'EN ROUTE'),
                              ));
                        },
                      ),
                      _StatusRow(
                        icon: Icons.block,
                        label: 'NON LIVRÉ',
                        count: statusCounts['NON LIVRÉ'] ?? 0,
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ParcelStatusListPage(status: 'NON LIVRÉ'),
                              ));
                        },
                      ),
                      _StatusRow(
                        icon: Icons.check_circle,
                        label: 'LIVRÉ',
                        count: statusCounts['LIVRÉ'] ?? 0,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ParcelStatusListPage(status: 'LIVRÉ'),
                              ));
                        },
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Ce que je veux',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        label: 'Je livre un colis',
                        onTap: () {
                          _askPhoneNumber(context, false);
                        },
                      ),
                      _ActionButton(
                        label: 'Je reçois un colis',
                        onTap: () {
                          _askPhoneNumber(context, true);
                        },
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Livraison en cours',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      _ActionButton(
                        label: 'Voir les livraisons en cours',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ParcelStatusListPage(status: 'EN ROUTE'),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur: $e')),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _ParcelBottomNavBar(),
    );
  }

  Map<String, int> _getStatusCounts(List<Parcel> parcels) {
    final Map<String, int> counts = {
      'RECEPTION': 0,
      'EN ROUTE': 0,
      'NON LIVRÉ': 0,
      'LIVRÉ': 0,
    };
    for (final parcel in parcels) {
      counts[parcel.status] = (counts[parcel.status] ?? 0) + 1;
    }
    return counts;
  }

  void _askPhoneNumber(BuildContext context, bool isReception) {
    final userDetailsJson = LocalStorageFactory().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TypeProduitPage(phoneNumber: phoneNumber, isReception: isReception),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback? onTap;
  const _StatusRow(
      {required this.icon,
      required this.label,
      required this.count,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
                child:
                    Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade200,
              child:
                  Text('$count', style: const TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Material(
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
                const Icon(Icons.chevron_right),
              ],
            ),
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
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ParcelHomePage()));
        } else if (index == 1) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => ParcelStatusListPage(status: 'ALL')));
        } else if (index == 2) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        }
      },
    );
  }
}
