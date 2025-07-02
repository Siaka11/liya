import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../application/delivery_admin_provider.dart';
import '../../domain/entities/delivery_order.dart';
import '../../domain/entities/delivery_user.dart';
import '../../../../core/ui/theme/theme.dart';
import '../../../../core/ui/components/custom_button.dart';
import '../../../../core/ui/components/custom_field.dart';

@RoutePage()
class DeliveryAssignmentPage extends ConsumerStatefulWidget {
  const DeliveryAssignmentPage({super.key});

  @override
  ConsumerState<DeliveryAssignmentPage> createState() =>
      _DeliveryAssignmentPageState();
}

class _DeliveryAssignmentPageState extends ConsumerState<DeliveryAssignmentPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour le formulaire de création
  final _customerPhoneController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _amountController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _descriptionController = TextEditingController();

  DeliveryType _selectedType = DeliveryType.restaurant;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customerPhoneController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _amountController.dispose();
    _deliveryFeeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(deliveryAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Livraisons'),
        backgroundColor: UIColors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(deliveryAdminProvider.notifier).refreshData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Onglets
          Container(
            color: Colors.grey[100],
            child: TabBar(
              controller: _tabController,
              labelColor: UIColors.orange,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: UIColors.orange,
              tabs: const [
                Tab(text: 'Commandes en attente', icon: Icon(Icons.pending)),
                Tab(text: 'Nouvelle commande', icon: Icon(Icons.add)),
              ],
            ),
          ),

          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingOrdersTab(),
                _buildNewOrderTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingOrdersTab() {
    final pendingOrders = ref.watch(adminPendingOrdersProvider);
    final availableUsers = ref.watch(availableDeliveryUsersProvider);
    final adminState = ref.watch(deliveryAdminProvider);

    if (adminState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pendingOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune commande en attente',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(deliveryAdminProvider.notifier).refreshData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingOrders.length,
        itemBuilder: (context, index) {
          final order = pendingOrders[index];
          return _buildPendingOrderCard(order, availableUsers);
        },
      ),
    );
  }

  Widget _buildPendingOrderCard(
      DeliveryOrder order, List<DeliveryUser> availableUsers) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'En attente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.type == DeliveryType.restaurant
                        ? Colors.orange[100]
                        : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.type == DeliveryType.restaurant
                        ? 'Restaurant'
                        : 'Colis',
                    style: TextStyle(
                      color: order.type == DeliveryType.restaurant
                          ? Colors.orange[800]
                          : Colors.blue[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.description,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Client', order.customerName),
            _buildInfoRow('Téléphone', order.customerPhoneNumber),
            _buildInfoRow('Adresse', order.customerAddress),
            _buildInfoRow('Montant', '${order.amount.toStringAsFixed(0)} FCFA'),
            _buildInfoRow('Frais de livraison',
                '${order.deliveryFee.toStringAsFixed(0)} FCFA'),
            _buildInfoRow(
                'Total', '${order.totalAmount.toStringAsFixed(0)} FCFA'),
            const SizedBox(height: 16),
            if (availableUsers.isNotEmpty) ...[
              const Text(
                'Assigner à un livreur:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...availableUsers
                  .map((user) => _buildDeliveryUserOption(order, user)),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Aucun livreur disponible',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryUserOption(DeliveryOrder order, DeliveryUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: UIColors.orange,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'L',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.phoneNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${user.completedDeliveries} livraisons - ${user.totalEarnings.toStringAsFixed(0)} FCFA gagnés',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          CustomButton(
            onPressedButton: () {
              ref
                  .read(deliveryAdminProvider.notifier)
                  .assignOrderToDeliveryUser(order, user);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Commande assignée à ${user.fullName}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            text: 'Assigner',
            borderRadius: 8,
            fontSize: 14,
            paddingVertical: 8,
            bgColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildNewOrderTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Créer une nouvelle commande de livraison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Type de livraison
            const Text(
              'Type de livraison:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<DeliveryType>(
                    title: const Text('Restaurant'),
                    value: DeliveryType.restaurant,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<DeliveryType>(
                    title: const Text('Colis'),
                    value: DeliveryType.parcel,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informations client
            const Text('Téléphone client:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomField(
              controller: _customerPhoneController,
              placeholder: 'Ex: 0701234567',
              keyboardType: TextInputType.phone,
              fontSize: 16,
            ),
            const SizedBox(height: 16),

            const Text('Nom du client:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomField(
              controller: _customerNameController,
              placeholder: 'Ex: Jean Dupont',
              keyboardType: TextInputType.text,
              fontSize: 16,
            ),
            const SizedBox(height: 16),

            const Text('Adresse de livraison:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomField(
              controller: _customerAddressController,
              placeholder: 'Ex: Cocody, Abidjan',
              keyboardType: TextInputType.multiline,
              fontSize: 16,
            ),
            const SizedBox(height: 16),

            // Montants
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Montant commande:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      CustomField(
                        controller: _amountController,
                        placeholder: 'Ex: 5000',
                        keyboardType: TextInputType.number,
                        fontSize: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Frais de livraison:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      CustomField(
                        controller: _deliveryFeeController,
                        placeholder: 'Ex: 500',
                        keyboardType: TextInputType.number,
                        fontSize: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Description:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomField(
              controller: _descriptionController,
              placeholder: 'Ex: Pizza margherita, 2 boissons',
              keyboardType: TextInputType.multiline,
              fontSize: 16,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressedButton: _createNewOrder,
                text: 'Créer la commande',
                borderRadius: 12,
                fontSize: 16,
                paddingVertical: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewOrder() {
    if (_formKey.currentState!.validate()) {
      ref.read(deliveryAdminProvider.notifier).createDeliveryOrder(
            customerPhoneNumber: _customerPhoneController.text,
            customerName: _customerNameController.text,
            customerAddress: _customerAddressController.text,
            type: _selectedType,
            amount: double.parse(_amountController.text),
            deliveryFee: double.parse(_deliveryFeeController.text),
            description: _descriptionController.text,
          );

      // Vider le formulaire
      _formKey.currentState!.reset();
      _customerPhoneController.clear();
      _customerNameController.clear();
      _customerAddressController.clear();
      _amountController.clear();
      _deliveryFeeController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande créée avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      // Basculer vers l'onglet des commandes en attente
      _tabController.animateTo(0);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
