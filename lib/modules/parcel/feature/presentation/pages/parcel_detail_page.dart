import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/parcel.dart';
import '../providers/parcel_action_provider.dart';
import '../../domain/entities/parcel_status.dart';

@RoutePage()
class ParcelDetailPage extends ConsumerWidget {
  final Parcel parcel;

  const ParcelDetailPage({Key? key, required this.parcel}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.read(parcelActionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Détail du colis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expéditeur : ${parcel.senderName}'),
            Text('Destinataire : ${parcel.receiverName}'),
            Text('Téléphone : ${parcel.phone ?? ''}'),
            Text('Adresse : ${parcel.address ?? ''}'),
            Text('Instructions : ${parcel.instructions ?? ''}'),
            Text('Statut : ${parcel.status}'),
            const SizedBox(height: 24),
            Text('Changer le statut :'),
            Wrap(
              spacing: 8,
              children: ParcelStatus.values.map((status) {
                final statusStr = parcelStatusToString(status);
                return ElevatedButton(
                  onPressed: () async {
                    await action.updateParcelStatus.call(parcel.id, statusStr);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(statusStr),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}