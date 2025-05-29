import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/widget/navigation_footer.dart';
import '../providers/order_provider.dart';
import '../../domain/entities/order.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/usecases/get_orders.dart';
import 'order_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:liya/routes/app_router.gr.dart';
import 'package:auto_route/auto_route.dart';

final orderListProvider =
    FutureProvider.family<List<Order>, String>((ref, phoneNumber) async {
  final dataSource =
      OrderRemoteDataSourceImpl(firestore: cf.FirebaseFirestore.instance);
  final repository = OrderRepositoryImpl(dataSource);
  final usecase = GetOrders(repository);
  return usecase(phoneNumber);
});

@RoutePage(name: 'OrderListRoute')
class OrderListPage extends ConsumerWidget {
  final String phoneNumber;
  const OrderListPage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderListStreamProvider(phoneNumber));
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        //supprime le bouton de retour
        leading: SizedBox(),
        title: const Text('Mes commandes'),
        centerTitle: true,
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (orders) => orders.isEmpty
            ? const Center(child: Text('Aucune commande'))
            : ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text('Order #${order.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text('Total: ${order.total.toStringAsFixed(1)} CFA'),
                    trailing: Text(order.status.toString().split('.').last),
                    onTap: () {
                      context.router.push(OrderDetailRoute(order: order));
                    },
                  );
                },
              ),
      ),
      bottomNavigationBar: NavigationFooter(),
    );
  }
}

class _OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  const _OrderStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (status) {
      case OrderStatus.reception:
        label = 'Reception';
        color = Colors.orange;
        break;
      case OrderStatus.enRoute:
        label = 'En route';
        color = Colors.blue;
        break;
      case OrderStatus.livre:
        label = 'Livré';
        color = Colors.green;
        break;
      case OrderStatus.nonLivre:
        label = 'Non livré';
        color = Colors.red;
        break;
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}
