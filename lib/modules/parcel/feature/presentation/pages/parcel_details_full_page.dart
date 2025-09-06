import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ParcelDetailsFullPage extends StatelessWidget {
  final Map<String, dynamic> parcelData;

  const ParcelDetailsFullPage({
    Key? key,
    required this.parcelData,
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
          'Détails du colis',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          // Badge de statut
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(parcelData['status']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(parcelData['status']).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              _getStatusText(parcelData['status']),
              style: TextStyle(
                color: Colors.white,
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
              icon: Icons.inventory,
              children: [
                _buildInfoRow('ID Colis', parcelData['id'] ?? 'N/A'),
                _buildInfoRow(
                    'Type de produit', parcelData['typeProduit'] ?? 'N/A'),
                _buildInfoRow(
                    'Date de création', _formatDate(parcelData['createdAt'])),
                /*_buildInfoRow(
                    'Dernière mise à jour',
                    parcelData['lastUpdated'] != null
                        ? _formatDate(parcelData['lastUpdated'])
                        : 'N/A'),*/
                _buildInfoRow('Statut', _getStatusText(parcelData['status'])),
              ],
            ),

            const SizedBox(height: 16),

            // Informations expéditeur
            _buildInfoCard(
              title: 'Informations de l\'expéditeur',
              icon: Icons.person_outline,
              children: [
                _buildInfoRow(
                    'Nom de l\'expéditeur',
                    parcelData['expediteurNom'] ??
                        parcelData['senderName'] ??
                        'N/A'),
                _buildInfoRow('Lieu de l\'expéditeur',
                    parcelData['expediteurLieu'] ?? 'N/A'),
                _buildInfoRow('Téléphone',
                    parcelData['expediteurPhone'] ?? parcelData['expediteurPhone'] ?? 'N/A'),
              ],
            ),

            const SizedBox(height: 16),

            // Informations destinataire
            _buildInfoCard(
              title: 'Informations du destinataire',
              icon: Icons.person,
              children: [
                _buildInfoRow(
                    'Nom du destinataire',
                    parcelData['destinataireNom'] ??
                        parcelData['receiverName'] ??
                        'N/A'),
                _buildInfoRow('Lieu du destinataire',
                    parcelData['destinataireLieu'] ?? 'N/A'),
                _buildInfoRow('Téléphone',
                    parcelData['destinatairePhone'] ?? parcelData['phone'] ?? 'N/A'),
              ],
            ),

            const SizedBox(height: 16),

            // Informations livreur
          /*  _buildInfoCard(
              title: 'Informations du livreur',
              icon: Icons.delivery_dining,
              children: [
                _buildInfoRow('Nom du livreur',
                    parcelData['assignedToName'] ?? 'Non assigné'),
                _buildInfoRow('Téléphone du livreur',
                    parcelData['assignedTo'] ?? 'Non assigné'),
                *//*_buildInfoRow(
                    'Date d\'assignation',
                    parcelData['assignedAt'] != null
                        ? _formatDate(parcelData['assignedAt'])
                        : 'Non assigné'),*//*
              ],
            ),*/

            const SizedBox(height: 16),

            // Description du colis
            if (parcelData['descriptionColis'] != null ||
                parcelData['colisDescription'] != null)
              _buildInfoCard(
                title: 'Description du colis',
                icon: Icons.description,
                children: [
                  _buildInfoRow(
                      'Description',
                      parcelData['descriptionColis'] ??
                          parcelData['colisDescription'] ??
                          'Aucune description'),
                ],
              ),

            if (parcelData['descriptionColis'] != null ||
                parcelData['colisDescription'] != null)
              const SizedBox(height: 16),

            // Liste des colis
            if (parcelData['colisList'] != null &&
                parcelData['colisList'] is List)
              _buildInfoCard(
                title: 'Contenu du colis',
                icon: Icons.list_alt,
                children: [
                  ...((parcelData['colisList'] as List)
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildParcelItem(item, index + 1);
                  }).toList())
                ],
              ),

            if (parcelData['colisList'] != null &&
                parcelData['colisList'] is List)
              const SizedBox(height: 16),

            // Informations de livraison
            /*_buildInfoCard(
              title: 'Informations de livraison',
              icon: Icons.local_shipping,
              children: [
                _buildInfoRow('Ville', parcelData['ville'] ?? 'N/A'),
                _buildInfoRow('Adresse', parcelData['address'] ?? 'N/A'),
                if (parcelData['instructions'] != null &&
                    parcelData['instructions'].isNotEmpty)
                  _buildInfoRow('Instructions', parcelData['instructions']),
              ],
            ),*/

            const SizedBox(height: 16),

            // Informations financières
            if (parcelData['prix'] != null)
              _buildInfoCard(
                title: 'Informations financières',
                icon: Icons.account_balance_wallet,
                children: [
                  _buildInfoRow('Prix', '${parcelData['prix']} FCFA'),
                ],
              ),

            if (parcelData['prix'] != null) const SizedBox(height: 16),

            // Informations techniques
           /* _buildInfoCard(
              title: 'Informations techniques',
              icon: Icons.info_outline,
              children: [
                _buildInfoRow('Date de mise à jour',
                    _formatDate(parcelData['updated_at'])),
                if (parcelData['latitude'] != null &&
                    parcelData['longitude'] != null)
                  _buildInfoRow('Coordonnées',
                      '${parcelData['latitude']}, ${parcelData['longitude']}'),
              ],
            ),*/

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

  Widget _buildInfoRow(String label, String value) {
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
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelItem(dynamic item, int index) {
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
          if (item['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              item['description'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (item['quantity'] != null || item['weight'] != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item['quantity'] != null)
                  Text(
                    'Quantité: ${item['quantity']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                if (item['weight'] != null)
                  Text(
                    'Poids: ${item['weight']} kg',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
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
      case 'reception':
        return Colors.purple;
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
      case 'reception':
        return 'En réception';
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
