import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/parcel_provider.dart';
import '../../domain/entities/parcel.dart';
import 'parcel_detail_page.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'dart:convert';
import 'package:collection/collection.dart';

class ParcelSearchPage extends ConsumerStatefulWidget {
  const ParcelSearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ParcelSearchPage> createState() => _ParcelSearchPageState();
}

class _ParcelSearchPageState extends ConsumerState<ParcelSearchPage> {
  final _controller = TextEditingController();
  List<Parcel> _foundParcels = [];
  String? _error;

  void _searchParcel(List<Parcel> parcels, String query, String phoneNumber) {
    final results = parcels
        .where((p) =>
            p.id.toLowerCase().contains(query.toLowerCase()) &&
            p.phoneNumber == phoneNumber)
        .toList();
    setState(() {
      _foundParcels = results;
      _error = results.isEmpty ? 'Aucun colis trouvé.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final parcelsAsync = ref.watch(parcelProvider);
    final userDetailsJson = LocalStorageFactory().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = (userDetails['phoneNumber'] ?? '').toString();
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Recherche de colis',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: parcelsAsync.when(
          data: (parcels) => Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Numéro de colis (COLIS...)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _searchParcel(parcels, _controller.text.trim(), phoneNumber);
                },
                child: const Text('Rechercher'),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_foundParcels.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    itemCount: _foundParcels.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final parcel = _foundParcels[i];
                      return ListTile(
                        title: Text(parcel.id),
                        subtitle: Text(parcel.instructions ?? ''),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ParcelDetailPage(parcel: parcel),
                              ));
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur: $e')),
        ),
      ),
    );
  }
}
