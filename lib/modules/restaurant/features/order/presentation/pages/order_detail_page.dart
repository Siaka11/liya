import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order.dart';
import 'package:auto_route/auto_route.dart';
import '../widgets/order_status_timeline.dart';
import '../widgets/order_item_card.dart';
import '../widgets/order_details_section.dart';
import '../providers/order_provider.dart';

@RoutePage(name: 'OrderDetailRoute')
class OrderDetailPage extends ConsumerWidget {
  final Order order;
  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderStreamProvider(order.id));
    return orderAsync.when(
      data: (currentOrder) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('DETAILS DE LA COMMANDE',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            OrderStatusTimeline(
                status: currentOrder.status,
                expectedDate: currentOrder.createdAt),
            OrderItemCardSection(items: currentOrder.items),
            OrderDetailsSection(order: currentOrder),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Erreur: $e')),
    );
  }
}


