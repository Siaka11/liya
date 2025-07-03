import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/delivery_order.dart';
import '../../application/home_delivery_provider.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DeliveryDetailPage extends ConsumerWidget {
  final DeliveryOrder order;

  const DeliveryDetailPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (order.status) {
      case DeliveryStatus.reception:
        statusColor = Colors.orange;
        statusText = 'Nouvelle livraison';
        statusIcon = Icons.assignment;
        break;
      case DeliveryStatus.enRoute:
        statusColor = Colors.blue;
        statusText = 'En cours de livraison';
        statusIcon = Icons.local_shipping;
        break;
      case DeliveryStatus.livre:
        statusColor = Colors.green;
        statusText = 'Livraison terminée';
        statusIcon = Icons.check_circle;
        break;
      case DeliveryStatus.nonLivre:
        statusColor = Colors.red;
        statusText = 'Livraison échouée';
        statusIcon = Icons.cancel;
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: Text(
          'Détail Livraison #${order.id}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte de statut
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.type == DeliveryType.restaurant
                                ? 'Commande Restaurant'
                                : 'Colis',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Informations de la commande
            const Text(
              'Informations de la commande',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.description,
                      'Description',
                      order.description,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.attach_money,
                      'Montant',
                      '${order.amount.toStringAsFixed(0)} FCFA',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.local_shipping,
                      'Frais de livraison',
                      '${order.deliveryFee.toStringAsFixed(0)} FCFA',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.account_balance_wallet,
                      'Total',
                      '${order.totalAmount.toStringAsFixed(0)} FCFA',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Informations du client
            const Text(
              'Informations du client',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.person,
                      'Nom',
                      order.customerName,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.location_on,
                      'Adresse',
                      order.customerAddress,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.phone,
                      'Téléphone',
                      order.customerPhoneNumber,
                      isPhone: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Informations temporelles
            const Text(
              'Informations temporelles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.schedule,
                      'Créée le',
                      DateFormat('dd/MM/yyyy à HH:mm').format(order.createdAt),
                    ),
                    if (order.assignedAt != null) ...[
                      const Divider(),
                      _buildInfoRow(
                        Icons.assignment,
                        'Assignée le',
                        DateFormat('dd/MM/yyyy à HH:mm')
                            .format(order.assignedAt!),
                      ),
                    ],
                    if (order.completedAt != null) ...[
                      const Divider(),
                      _buildInfoRow(
                        Icons.check_circle,
                        'Terminée le',
                        DateFormat('dd/MM/yyyy à HH:mm')
                            .format(order.completedAt!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.note, color: Color(0xFFF24E1E)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          order.notes!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Actions
            if (order.status == DeliveryStatus.reception) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(homeDeliveryProvider.notifier)
                        .startDelivery(order);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Démarrer la livraison'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF24E1E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ] else if (order.status == DeliveryStatus.enRoute) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showDeliveryCompletionDialog(context, ref);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Terminer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showDeliveryFailureDialog(context, ref);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Échec'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isTotal = false, bool isPhone = false}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFF24E1E), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              if (isPhone)
                GestureDetector(
                  onTap: () {
                    // TODO: Implémenter l'appel téléphonique
                  },
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                      color: isTotal ? Colors.green : const Color(0xFFF24E1E),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    color: isTotal ? Colors.green : Colors.black,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeliveryCompletionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la livraison'),
        content: Text(
          'Êtes-vous sûr de vouloir marquer cette livraison comme terminée ?\n\n'
          '${order.description}\n'
          'Client: ${order.customerName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(homeDeliveryProvider.notifier).completeDelivery(order);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showDeliveryFailureDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marquer comme échouée'),
        content: Text(
          'Êtes-vous sûr de vouloir marquer cette livraison comme échouée ?\n\n'
          '${order.description}\n'
          'Client: ${order.customerName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(homeDeliveryProvider.notifier).failDelivery(order);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
