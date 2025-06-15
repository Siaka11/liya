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
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Détails de la livraison',
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (parcel.prix != null)
              Text('${parcel.prix!.toStringAsFixed(0)} F',
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Description :',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(parcel.instructions ?? '',
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('ID livraison:',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(parcel.id,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Date de livraison',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      Text(_formatDate(parcel.createdAt)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Date de réception',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      Text(_formatDate(
                          parcel.createdAt.add(const Duration(days: 2)))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}
