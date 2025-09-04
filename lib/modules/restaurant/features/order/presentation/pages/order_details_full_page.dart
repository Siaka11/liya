import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class OrderDetailsFullPage extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsFullPage({
    Key? key,
    required this.orderData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Détails de la commande',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          // Badge de statut
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(orderData['status']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(orderData['status']).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              _getStatusText(orderData['status']),
              style: TextStyle(
                color: _getStatusColor(orderData['status']),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations générales
            _buildInfoCard(
              title: 'Informations générales',
              icon: Icons.receipt_long,
              children: [
                _buildInfoRow('ID Commande', orderData['id'] ?? 'N/A'),
                _buildInfoRow(
                    'Date de création', _formatDate(orderData['createdAt'])),
                _buildInfoRow(
                    'Dernière mise à jour',
                    orderData['lastUpdated'] != null
                        ? _formatDate(orderData['lastUpdated'])
                        : 'N/A'),
                _buildInfoRow('Statut', _getStatusText(orderData['status'])),
              ],
            ),

            const SizedBox(height: 16),

            // Informations client
            _buildInfoCard(
              title: 'Informations du client',
              icon: Icons.person,
              children: [
                _buildInfoRow('Téléphone du client',
                    orderData['phoneNumber'] ?? orderData['phone'] ?? 'N/A'),
                _buildInfoRow(
                    'Adresse de livraison', orderData['address'] ?? 'N/A'),
                if (orderData['deliveryInstructions'] != null &&
                    orderData['deliveryInstructions'].isNotEmpty)
                  _buildInfoRow('Instructions de livraison',
                      orderData['deliveryInstructions']),
              ],
            ),

            const SizedBox(height: 16),

            // Informations livreur
            _buildInfoCard(
              title: 'Informations du livreur',
              icon: Icons.delivery_dining,
              children: [
                _buildInfoRow('Nom du livreur',
                    orderData['assignedToName'] ?? 'Non assigné'),
                _buildInfoRow('Téléphone du livreur',
                    orderData['assignedTo'] ?? 'Non assigné'),
                _buildInfoRow(
                    'Date d\'assignation',
                    orderData['assignedAt'] != null
                        ? _formatDate(orderData['assignedAt'])
                        : 'Non assigné'),
              ],
            ),

            const SizedBox(height: 16),

            // Articles commandés
            _buildInfoCard(
              title: 'Articles commandés',
              icon: Icons.restaurant_menu,
              children: [
                if (orderData['items'] != null && orderData['items'] is List)
                  ...((orderData['items'] as List).asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildOrderItem(item, index + 1);
                  }).toList())
                else
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Aucun article trouvé'),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Informations de livraison
            _buildInfoCard(
              title: 'Informations de livraison',
              icon: Icons.local_shipping,
              children: [
                _buildInfoRow('Frais de livraison',
                    '${orderData['deliveryFee'] ?? 0} FCFA'),
                _buildInfoRow('Temps de livraison estimé',
                    '${orderData['deliveryTime'] ?? 0} minutes'),
                _buildInfoRow('Distance', '${orderData['distance'] ?? 0} km'),
                if (orderData['latitude'] != null &&
                    orderData['longitude'] != null)
                  _buildInfoRow('Coordonnées de livraison',
                      '${orderData['latitude']}, ${orderData['longitude']}'),
              ],
            ),

            const SizedBox(height: 16),

            // Résumé financier
            _buildInfoCard(
              title: 'Résumé financier',
              icon: Icons.account_balance_wallet,
              children: [
                _buildInfoRow(
                    'Sous-total', '${orderData['subtotal'] ?? 0} FCFA'),
                _buildInfoRow('Frais de livraison',
                    '${orderData['deliveryFee'] ?? 0} FCFA'),
                const Divider(),
                _buildInfoRow(
                  'Total',
                  '${orderData['total'] ?? 0} FCFA',
                  isTotal: true,
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFF24E1E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isTotal ? const Color(0xFFF24E1E) : Colors.black87,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF24E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['name'] ?? 'Article inconnu',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantité: ${item['quantity'] ?? 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${item['price'] ?? 0} FCFA',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF24E1E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'enroute':
        return Colors.orange;
      case 'livre':
        return Colors.green;
      case 'nonlivre':
        return Colors.red;
      case 'assigned':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'enroute':
        return 'En route';
      case 'livre':
        return 'Livré';
      case 'nonlivre':
        return 'Non livré';
      case 'assigned':
        return 'Assigné';
      default:
        return status ?? 'Inconnu';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';

    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} à ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}';
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }
}
