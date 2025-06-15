import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/parcel_provider.dart';
import '../widgets/parcel_card.dart';

@RoutePage()
class ParcelListPage extends ConsumerWidget {
  const ParcelListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcelsAsync = ref.watch(parcelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Suivi des livraisons')),
      body: parcelsAsync.when(
        data: (parcels) => ListView.builder(
          itemCount: parcels.length,
          itemBuilder: (context, index) => ParcelCard(parcel: parcels[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
