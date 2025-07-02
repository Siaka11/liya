import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class DeliveryListPage extends StatelessWidget {
  const DeliveryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title:
            const Text('Mes Livraisons', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // TODO: Remplacer par la vraie liste
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Icon(Icons.local_shipping, color: Color(0xFFF24E1E)),
            title: Text('Livraison #${i + 1}'),
            subtitle: Text(i % 2 == 0 ? 'En cours' : 'Livrée'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}
