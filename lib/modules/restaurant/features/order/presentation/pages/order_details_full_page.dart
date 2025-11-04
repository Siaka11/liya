import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../delivery/presentation/pages/delivery_navigation_page.dart';
import '../../../../../delivery/domain/entities/delivery_order.dart';

@RoutePage()
class OrderDetailsFullPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsFullPage({
    Key? key,
    required this.orderData,
  }) : super(key: key);

  @override
  State<OrderDetailsFullPage> createState() => _OrderDetailsFullPageState();
}

class _OrderDetailsFullPageState extends State<OrderDetailsFullPage> {
  bool _isCourseStarted = false;
  bool _isNavigationOpened = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  void _checkInitialState() {
    final status = widget.orderData['status']?.toString().toLowerCase();
    _isCourseStarted = status == 'enroute';
    _isNavigationOpened = status == 'enroute';
  }

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
              color: _getStatusColor(widget.orderData['status'])
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(widget.orderData['status'])
                    .withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              _getStatusText(widget.orderData['status']),
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
              icon: Icons.receipt_long,
              children: [
                _buildInfoRow('ID Commande', widget.orderData['id'] ?? 'N/A'),
                _buildInfoRow('Date de création',
                    _formatDate(widget.orderData['createdAt'])),
                _buildInfoRow(
                    'Dernière mise à jour',
                    widget.orderData['lastUpdated'] != null
                        ? _formatDate(widget.orderData['lastUpdated'])
                        : 'N/A'),
                _buildInfoRow(
                    'Statut', _getStatusText(widget.orderData['status'])),
              ],
            ),

            const SizedBox(height: 16),

            // Informations client
            _buildInfoCard(
              title: 'Informations du client',
              icon: Icons.person,
              children: [
                _buildInfoRow(
                    'Téléphone du client',
                    widget.orderData['phoneNumber'] ??
                        widget.orderData['phone'] ??
                        'N/A'),
                _buildInfoRow('Adresse de livraison',
                    widget.orderData['address'] ?? 'N/A'),
                if (widget.orderData['deliveryInstructions'] != null &&
                    widget.orderData['deliveryInstructions'].isNotEmpty)
                  _buildInfoRow('Instructions de livraison',
                      widget.orderData['deliveryInstructions']),
              ],
            ),

            const SizedBox(height: 16),

            // Informations livreur
            _buildInfoCard(
              title: 'Informations du livreur',
              icon: Icons.delivery_dining,
              children: [
                _buildInfoRow('Nom du livreur',
                    widget.orderData['assignedToName'] ?? 'Non assigné'),
                _buildInfoRow('Téléphone du livreur',
                    widget.orderData['assignedTo'] ?? 'Non assigné'),
                _buildInfoRow(
                    'Date d\'assignation',
                    widget.orderData['assignedAt'] != null
                        ? _formatDate(widget.orderData['assignedAt'])
                        : 'Non assigné'),
              ],
            ),

            const SizedBox(height: 16),

            // Articles commandés
            _buildInfoCard(
              title: 'Articles commandés',
              icon: Icons.restaurant_menu,
              children: [
                if (widget.orderData['items'] != null &&
                    widget.orderData['items'] is List)
                  ...((widget.orderData['items'] as List)
                      .asMap()
                      .entries
                      .map((entry) {
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
                    '${widget.orderData['deliveryFee'] ?? 0} FCFA'),
                _buildInfoRow('Temps de livraison estimé',
                    '${widget.orderData['deliveryTime'] ?? 0} minutes'),
                _buildInfoRow(
                    'Distance', '${widget.orderData['distance'] ?? 0} km'),
                if (widget.orderData['latitude'] != null &&
                    widget.orderData['longitude'] != null)
                  _buildInfoRow('Coordonnées de livraison',
                      '${widget.orderData['latitude']}, ${widget.orderData['longitude']}'),
              ],
            ),

            const SizedBox(height: 16),

            // Résumé financier
            _buildInfoCard(
              title: 'Résumé financier',
              icon: Icons.account_balance_wallet,
              children: [
                _buildInfoRow(
                    'Sous-total', '${widget.orderData['subtotal'] ?? 0} FCFA'),
                _buildInfoRow('Frais de livraison',
                    '${widget.orderData['deliveryFee'] ?? 0} FCFA'),
                const Divider(),
                _buildInfoRow(
                  'Total',
                  '${widget.orderData['total'] ?? 0} FCFA',
                  isTotal: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Boutons d'action pour les livreurs
            _buildActionButtons(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // Vérifier si c'est une commande assignée à un livreur
    final isAssigned = widget.orderData['assignedTo'] != null &&
        widget.orderData['assignedTo'].toString().isNotEmpty;
    final status = widget.orderData['status']?.toString().toLowerCase();

    // Si la commande n'est pas assignée, ne pas afficher les boutons
    if (!isAssigned) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                _getActionIcon(),
                color: const Color(0xFFF24E1E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getActionTitle(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Afficher les boutons selon l'état
          ..._buildActionButtonsForState(),
        ],
      ),
    );
  }

  IconData _getActionIcon() {
    if (!_isCourseStarted) return Icons.play_arrow;
    if (!_isNavigationOpened) return Icons.navigation;
    return Icons.check_circle;
  }

  String _getActionTitle() {
    if (!_isCourseStarted) return 'Démarrer la livraison';
    if (!_isNavigationOpened) return 'Navigation';
    return 'Finaliser la livraison';
  }

  List<Widget> _buildActionButtonsForState() {
    final buttons = <Widget>[];

    if (!_isCourseStarted) {
      // État initial : Seul le bouton "Démarrer la course" est visible
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _startDelivery(),
            icon: const Icon(Icons.directions_car, color: Colors.white),
            label: const Text(
              'Démarrer la course',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    } else if (!_isNavigationOpened) {
      // Course démarrée : Bouton "Ouvrir Navigation" visible
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openGoogleMapsNavigation(),
            icon: const Icon(Icons.navigation, color: Colors.white),
            label: const Text(
              'Ouvrir Navigation',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );

      buttons.add(const SizedBox(height: 12));

      // Bouton "Navigation Complète" (toujours disponible)
     /* buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openDeliveryNavigationPage(),
            icon: const Icon(Icons.map, color: Colors.white),
            label: const Text(
              'Navigation Complète',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF24E1E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );*/
    } else {
      // Navigation ouverte : Boutons de finalisation
      buttons.add(
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _completeDelivery(true),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'Livré',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _completeDelivery(false),
                icon: const Icon(Icons.cancel, color: Colors.white),
                label: const Text(
                  'Non livré',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return buttons;
  }

  void _openGoogleMapsNavigation() async {
    try {
      final latitude = widget.orderData['latitude'] ??
          widget.orderData['destinationLatitude'];
      final longitude = widget.orderData['longitude'] ??
          widget.orderData['destinationLongitude'];

      if (latitude == null || longitude == null) {
        _showErrorSnackBar('Coordonnées de destination non disponibles');
        return;
      }

      // URL pour Google Maps Navigation
      final url = 'google.navigation:q=$latitude,$longitude';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );

        // Mettre à jour l'état local pour afficher les boutons de finalisation
        setState(() {
          _isNavigationOpened = true;
        });

        _showSuccessSnackBar('Navigation Google Maps ouverte !');
      } else {
        // Fallback vers Google Maps web
        final webUrl =
            'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
        if (await canLaunchUrl(Uri.parse(webUrl))) {
          await launchUrl(
            Uri.parse(webUrl),
            mode: LaunchMode.externalApplication,
          );
          _showSuccessSnackBar('Google Maps ouvert dans le navigateur');
        } else {
          _showErrorSnackBar('Impossible d\'ouvrir Google Maps');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  void _startDelivery() async {
    try {
      // Mettre à jour le statut de la commande vers "enRoute"
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderData['id'])
          .update({
        'status': 'enRoute',
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Mettre à jour l'état local
      setState(() {
        _isCourseStarted = true;
      });

      _showSuccessSnackBar('Course démarrée !');
    } catch (e) {
      _showErrorSnackBar('Erreur lors du démarrage: $e');
    }
  }

  void _openDeliveryNavigationPage() {
    try {
      // Convertir les données en DeliveryOrder
      final deliveryOrder = DeliveryOrder(
        id: widget.orderData['id'] ?? '',
        customerPhoneNumber:
            widget.orderData['phoneNumber'] ?? widget.orderData['phone'] ?? '',
        customerName: widget.orderData['customerName'] ?? 'Client',
        customerAddress:
            widget.orderData['address'] ?? 'Adresse non disponible',
        type: DeliveryType.restaurant,
        status: _mapStringToDeliveryStatus(widget.orderData['status']),
        amount: (widget.orderData['total'] ?? 0).toDouble(),
        deliveryFee: (widget.orderData['deliveryFee'] ?? 0).toDouble(),
        description: widget.orderData['description'] ?? 'Commande restaurant',
        createdAt: DateTime.now(),
        destinationLatitude: widget.orderData['latitude'] ??
            widget.orderData['destinationLatitude'],
        destinationLongitude: widget.orderData['longitude'] ??
            widget.orderData['destinationLongitude'],
        deliveryTime: widget.orderData['deliveryTime'],
        distance: widget.orderData['distance']?.toDouble(),
        items: widget.orderData['items'] ?? [],
      );

      // Naviguer vers la page de navigation complète
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeliveryNavigationPage(order: deliveryOrder),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Erreur lors de l\'ouverture: $e');
    }
  }

  DeliveryStatus _mapStringToDeliveryStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'assigned':
        return DeliveryStatus.assigned;
      case 'enroute':
        return DeliveryStatus.enRoute;
      case 'livre':
        return DeliveryStatus.livre;
      case 'nonlivre':
        return DeliveryStatus.nonLivre;
      default:
        return DeliveryStatus.assigned;
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
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
            color: Colors.black.withValues(alpha: 0.05),
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

  void _completeDelivery(bool isDelivered) async {
    try {
      final status = isDelivered ? 'livre' : 'nonlivre';
      final message = isDelivered
          ? 'Livraison marquée comme livrée !'
          : 'Livraison marquée comme non livrée !';

      // Mettre à jour le statut dans Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderData['id'])
          .update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
        'delivered_at': isDelivered ? FieldValue.serverTimestamp() : null,
      });

      _showSuccessSnackBar(message);

      // Optionnel : revenir à la page précédente ou actualiser les données
      // Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la mise à jour du statut: $e');
    }
  }
}
