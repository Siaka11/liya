import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_home_page.dart';
import '../providers/parcel_provider.dart';
import '../../domain/entities/parcel.dart';
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart';
import 'parcel_detail_page.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'dart:convert';
import 'package:liya/modules/home/presentation/pages/home_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';

class ParcelStatusListPage extends ConsumerWidget {
  final String status;
  const ParcelStatusListPage({Key? key, required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcelsAsync = ref.watch(parcelProvider);
    final userDetailsJson = LocalStorageFactory().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3ED),
        elevation: 0,
        leading: SizedBox(),
        title: const Text('Mes livraisons',
            style: TextStyle(color: Colors.black, fontSize: 18)),
        centerTitle: true,
      ),
      body: parcelsAsync.when(
        data: (parcels) {
          final filtered = status == 'ALL'
              ? parcels
              : parcels.where((p) => p.status == status).toList();
          if (filtered.isEmpty) {
            return const Center(child: Text('Aucune demande.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final parcel = filtered[i];
              return _ParcelCardList(parcel: parcel);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
      bottomNavigationBar: _ParcelBottomNavBar(),
    );
  }
}

class _ParcelCardList extends StatelessWidget {
  final Parcel parcel;
  const _ParcelCardList({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final statusColor = parcel.status == 'livre'
        ? Colors.green
        : parcel.status == 'enRoute'
            ? Colors.green
            : parcel.status == 'nonLivre'
                ? Colors.red
                : Colors.pink.shade100;
    final statusTextColor =
        parcel.status == 'enRoute' ? Colors.white : Colors.black;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ParcelDetailPage(parcel: parcel),
              ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2,
                        size: 32, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                parcel.status,
                                style: TextStyle(
                                    color: statusTextColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${parcel.createdAt.day} ${_monthName(parcel.createdAt.month)} ${parcel.createdAt.year}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(parcel.instructions ?? '',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('ID: ${parcel.id}',
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ParcelDetailPage(parcel: parcel),
                          ));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.'
    ];
    return months[month];
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
