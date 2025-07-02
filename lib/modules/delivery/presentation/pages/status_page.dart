import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  bool isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: const Text('Statut', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Statut du livreur',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 24),
                SwitchListTile(
                  value: isAvailable,
                  onChanged: (v) => setState(() => isAvailable = v),
                  title: Text(isAvailable ? 'Disponible' : 'Occupé'),
                  activeColor: const Color(0xFFF24E1E),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
