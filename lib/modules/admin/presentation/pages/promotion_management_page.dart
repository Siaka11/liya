import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_route/auto_route.dart';

import '../../../../core/services/promotion_service.dart';

@RoutePage()
class PromotionManagementPage extends StatefulWidget {
  const PromotionManagementPage({Key? key}) : super(key: key);

  @override
  State<PromotionManagementPage> createState() =>
      _PromotionManagementPageState();
}

class _PromotionManagementPageState extends State<PromotionManagementPage> {
  final PromotionService _promotionService = PromotionService();
  List<Map<String, dynamic>> _promotions = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('promotions')
          .orderBy('created_at', descending: true)
          .get();

      _promotions = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des promotions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredPromotions {
    switch (_selectedFilter) {
      case 'active':
        return _promotions.where((p) => p['is_active'] == true).toList();
      case 'inactive':
        return _promotions.where((p) => p['is_active'] == false).toList();
      case 'expired':
        final now = DateTime.now();
        return _promotions.where((p) {
          final endDate = p['end_date']?.toDate();
          return endDate != null && endDate.isBefore(now);
        }).toList();
      default:
        return _promotions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: const Text(
          'Gestion des Promotions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPromotionDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    decoration: InputDecoration(
                      labelText: 'Filtrer',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Toutes')),
                      DropdownMenuItem(value: 'active', child: Text('Actives')),
                      DropdownMenuItem(
                          value: 'inactive', child: Text('Inactives')),
                      DropdownMenuItem(
                          value: 'expired', child: Text('Expirées')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _loadPromotions,
                  icon: const Icon(Icons.refresh),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Statistiques
          _buildStatsSection(),

          // Liste des promotions
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPromotions.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune promotion trouvée',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredPromotions.length,
                        itemBuilder: (context, index) {
                          final promotion = _filteredPromotions[index];
                          return _buildPromotionCard(promotion);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final totalPromotions = _promotions.length;
    final activePromotions =
        _promotions.where((p) => p['is_active'] == true).length;
    final totalUses = _promotions.fold<int>(
        0, (sum, p) => sum + ((p['used_count'] as int?) ?? 0));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
                'Total', '$totalPromotions', Icons.local_offer, Colors.blue),
          ),
          Expanded(
            child: _buildStatItem('Actives', '$activePromotions',
                Icons.check_circle, Colors.green),
          ),
          Expanded(
            child: _buildStatItem(
                'Utilisations', '$totalUses', Icons.trending_up, Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPromotionCard(Map<String, dynamic> promotion) {
    final isActive = promotion['is_active'] ?? false;
    final endDate = promotion['end_date']?.toDate();
    final isExpired = endDate != null && endDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.local_offer,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          promotion['title'] ?? 'Promotion',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(promotion['description'] ?? ''),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDiscountColor(promotion),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getDiscountText(promotion),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${promotion['used_count'] ?? 0} utilisations',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (isExpired)
              const Text(
                'EXPIRÉE',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handlePromotionAction(value, promotion),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Modifier')
                ],
              ),
            ),
            PopupMenuItem(
              value: isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(isActive ? Icons.pause : Icons.play_arrow, size: 20),
                  SizedBox(width: 8),
                  Text(isActive ? 'Désactiver' : 'Activer')
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDiscountColor(Map<String, dynamic> promotion) {
    final discountType = promotion['discount_type'];
    if (discountType == 'percentage') {
      final value = promotion['discount_value'] ?? 0;
      if (value >= 50) return Colors.red;
      if (value >= 25) return Colors.orange;
      return Colors.green;
    }
    return Colors.blue;
  }

  String _getDiscountText(Map<String, dynamic> promotion) {
    final discountType = promotion['discount_type'];
    final discountValue = promotion['discount_value'];

    if (discountType == 'percentage') {
      return '-${discountValue.toInt()}%';
    } else if (discountType == 'fixed_amount') {
      return '-${discountValue.toInt()} CFA';
    }
    return 'PROMO';
  }

  void _handlePromotionAction(String action, Map<String, dynamic> promotion) {
    switch (action) {
      case 'edit':
        _showEditPromotionDialog(promotion);
        break;
      case 'activate':
      case 'deactivate':
        _togglePromotionStatus(promotion);
        break;
      case 'delete':
        _deletePromotion(promotion);
        break;
    }
  }

  void _togglePromotionStatus(Map<String, dynamic> promotion) {
    final newStatus = !(promotion['is_active'] ?? false);
    _promotionService.updatePromotion(promotion['id'], {
      'is_active': newStatus,
    }).then((_) {
      _loadPromotions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promotion ${newStatus ? 'activée' : 'désactivée'}'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _deletePromotion(Map<String, dynamic> promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer "${promotion['title']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _promotionService.deletePromotion(promotion['id']).then((_) {
                _loadPromotions();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Promotion supprimée'),
                    backgroundColor: Colors.green,
                  ),
                );
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddPromotionDialog([Map<String, dynamic>? promotion]) {
    // TODO: Implémenter le dialogue d'ajout/modification de promotion
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            promotion != null ? 'Modifier la promotion' : 'Nouvelle promotion'),
        content: const Text('Interface de création/modification à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showEditPromotionDialog(Map<String, dynamic> promotion) {
    _showAddPromotionDialog(promotion);
  }
}
