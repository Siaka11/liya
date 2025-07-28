import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../routes/app_router.gr.dart';
import '../providers/parcel_provider.dart';
import '../widgets/parcel_card.dart';

@RoutePage()
class ParcelListPage extends ConsumerWidget {
  const ParcelListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcelsAsync = ref.watch(parcelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des livraisons'),
        automaticallyImplyLeading: false,
      ),
      body: parcelsAsync.when(
        data: (parcels) => ListView.builder(
          itemCount: parcels.length,
          itemBuilder: (context, index) => ParcelCard(parcel: parcels[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
      bottomNavigationBar: _ParcelBottomNavBar(),
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
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
      ],
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          AutoRouter.of(context).replace(const ParcelHomeRoute());
        } else if (index == 1) {
          AutoRouter.of(context).replace(const ParcelListRoute());
        } else if (index == 2) {
          AutoRouter.of(context).replace(const HomeRoute());
        }
      },
    );
  }
}