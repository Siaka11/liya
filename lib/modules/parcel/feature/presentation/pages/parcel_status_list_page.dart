import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/parcel_provider.dart';
import '../../domain/entities/parcel.dart';
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart';
import 'parcel_detail_page.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'dart:convert';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: parcelsAsync.when(
        data: (parcels) {
          final filtered = status == 'ALL'
              ? parcels.where((p) => p.phone == phoneNumber).toList()
              : parcels
                  .where((p) => p.status == status && p.phone == phoneNumber)
                  .toList();
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
    );
  }
}

class _ParcelCardList extends StatelessWidget {
  final Parcel parcel;
  const _ParcelCardList({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final statusColor = parcel.status == 'LIVRÉ'
        ? Colors.green
        : parcel.status == 'EN ROUTE'
            ? Colors.green
            : parcel.status == 'NON LIVRÉ'
                ? Colors.red
                : Colors.pink.shade100;
    final statusTextColor =
        parcel.status == 'EN ROUTE' ? Colors.white : Colors.black;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                                borderRadius: BorderRadius.circular(12),
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
                        if (parcel.address != null)
                          Text(parcel.address!,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('ID livraison: ${parcel.id}',
                            style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                                decoration: TextDecoration.underline)),
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
