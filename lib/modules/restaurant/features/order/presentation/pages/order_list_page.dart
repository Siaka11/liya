import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/ui/theme/theme.dart';
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
        leading: SizedBox(),
        title: const Text('Mes commandes', style: TextStyle(color: UIColors.orange)),
        centerTitle: true,
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (orders) => orders.isEmpty
            ? const Center(child: Text('Aucune commande'))
            : Column(
                children: [
                  const SizedBox(height: 10), // ESPACE APRÈS LE TITRE
                  Expanded(
                      child:ListView.separated(
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

                  )
                ],
        )

      ),
      bottomNavigationBar: NavigationFooter(),
    );
  }
}

