import 'package:flutter/material.dart';
import '../../domain/entities/parcel.dart';
import '../pages/parcel_detail_page.dart';

class ParcelCard extends StatelessWidget {
  final Parcel parcel;
  const ParcelCard({Key? key, required this.parcel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.local_shipping),
        title: Text('Colis pour ${parcel.receiverName}'),
        subtitle:
            Text('Statut: ${parcel.status}\nCréé le: ${parcel.createdAt}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParcelDetailPage(parcel: parcel),
            ),
          );
        },
      ),
    );
  }
}
