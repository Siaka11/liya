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

    // Titre dynamique selon le statut
    String getStatusTitle() {
      switch (status) {
        case 'reception':
          return 'Colis en réception';
        case 'enRoute':
          return 'Colis en route';
        case 'livre':
          return 'Colis livrés';
        case 'nonLivre':
          return 'Colis non livrés';
        default:
          return 'Mes colis';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(getStatusTitle(),
            style: const TextStyle(color: Colors.black, fontSize: 18)),
        centerTitle: true,
      ),
      body: parcelsAsync.when(
        data: (parcels) {
          final userParcels =
              parcels.where((p) => p.phoneNumber == phoneNumber).toList();
          final filtered = status == 'ALL'
              ? userParcels
              : userParcels.where((p) => p.status == status).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun colis ${_getStatusText(status)}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous n\'avez pas encore de colis dans cette catégorie',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
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

  String _getStatusText(String status) {
    switch (status) {
      case 'reception':
        return 'en réception';
      case 'enRoute':
        return 'en route';
      case 'livre':
        return 'livré';
      case 'nonLivre':
        return 'non livré';
      default:
        return '';
    }
  }
}

class _ParcelCardList extends StatelessWidget {
  final Parcel parcel;
  const _ParcelCardList({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(parcel.status);
    final statusText = _getStatusText(parcel.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut et date
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${parcel.createdAt.day}/${parcel.createdAt.month}/${parcel.createdAt.year}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Informations du colis
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF24E1E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2,
                        size: 24, color: Color(0xFFF24E1E)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ID du colis
                        Text(
                          'Colis #${parcel.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFF24E1E),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Expéditeur
                        if (parcel.expediteurNom != null &&
                            parcel.expediteurNom!.isNotEmpty)
                          Text(
                            'De: ${parcel.expediteurNom}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),

                        // Destinataire
                        if (parcel.destinataireNom != null &&
                            parcel.destinataireNom!.isNotEmpty)
                          Text(
                            'À: ${parcel.destinataireNom}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),

                        // Instructions
                        if (parcel.instructions != null &&
                            parcel.instructions!.isNotEmpty)
                          Text(
                            parcel.instructions!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'reception':
        return Colors.orange;
      case 'enRoute':
        return Colors.blue;
      case 'livre':
        return Colors.green;
      case 'nonLivre':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'reception':
        return 'EN RÉCEPTION';
      case 'enRoute':
        return 'EN ROUTE';
      case 'livre':
        return 'LIVRÉ';
      case 'nonLivre':
        return 'NON LIVRÉ';
      default:
        return status.toUpperCase();
    }
  }
}

class _ParcelBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping, color: Colors.deepOrange), label: 'Mes livraisons'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Menu principal'),
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
