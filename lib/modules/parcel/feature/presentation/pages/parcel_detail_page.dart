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
    final parcelStatus = parcelStatusFromString(parcel.status);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Détails du colis',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description du colis
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description du colis',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    parcel.instructions ?? 'Aucune description',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Informations du colis
            Expanded(
              child: ListView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informations du colis',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),

                        // Informations de base
                        _InfoRow(
                          label: 'Expéditeur',
                          value: parcel.senderName,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Destinataire',
                          value: parcel.receiverName,
                        ),
                        const SizedBox(height: 8),
                        if (parcel.address != null) ...[
                          _InfoRow(
                            label: 'Adresse',
                            value: parcel.address!,
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (parcel.phone != null) ...[
                          _InfoRow(
                            label: 'Téléphone',
                            value: parcel.phone!,
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (parcel.ville != null) ...[
                          _InfoRow(
                            label: 'Ville',
                            value: parcel.ville!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informations de livraison
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informations de livraison',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        _InfoRow(
                          label: 'ID livraison',
                          value: parcel.id,
                          isClickable: true,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Statut',
                          value: parcelStatusToString(parcelStatus),
                          valueColor: _getStatusColor(parcelStatus),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Date de création',
                          value: _formatDate(parcel.createdAt),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Date de livraison estimée',
                          value: _formatDate(
                              parcel.createdAt.add(const Duration(days: 2))),
                        ),
                        if (parcel.prix != null) ...[
                          const SizedBox(height: 8),
                          _InfoRow(
                            label: 'Prix',
                            value: '${parcel.prix!.toStringAsFixed(0)} F',
                            valueColor: Colors.green,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bouton d'action
            if (parcelStatus == ParcelStatus.reception)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF24E1E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: () {
                    // Action pour accepter/refuser la livraison
                    _showActionDialog(context);
                  },
                  child: const Text('Accepter la livraison',
                      style: TextStyle(fontSize: 18)),
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

  Color _getStatusColor(ParcelStatus status) {
    switch (status) {
      case ParcelStatus.reception:
        return Colors.orange;
      case ParcelStatus.enRoute:
        return Colors.blue;
      case ParcelStatus.nonLivre:
        return Colors.red;
      case ParcelStatus.livre:
        return Colors.green;
    }
  }

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Action sur la livraison'),
        content: const Text('Que souhaitez-vous faire avec cette livraison ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Action pour accepter
            },
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isClickable;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: isClickable
                ? () {
                    // Action pour copier l'ID
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('ID copié dans le presse-papiers')),
                    );
                  }
                : null,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor,
                decoration: isClickable ? TextDecoration.underline : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
