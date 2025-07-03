import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class EarningsPage extends StatelessWidget {
  const EarningsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: const Text('Mes Gains', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: const Color(0xFFF24E1E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Total des gains',
                    style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text('25.000F',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 10, // TODO: Remplacer par la vraie liste
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading:
                      Icon(Icons.monetization_on, color: Color(0xFFF24E1E)),
                  title: Text('Livraison #${i + 1}'),
                  subtitle: Text('ID: LIYA25032${i + 1}'),
                  trailing: Text('+${(i + 1) * 1000}F',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
