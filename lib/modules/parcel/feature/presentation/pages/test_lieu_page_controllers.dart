import 'package:flutter/material.dart';

class TestLieuPageControllers extends StatefulWidget {
  @override
  _TestLieuPageControllersState createState() =>
      _TestLieuPageControllersState();
}

class _TestLieuPageControllersState extends State<TestLieuPageControllers> {
  // Contrôleurs séparés pour chaque champ
  final TextEditingController _expediteurNomController =
      TextEditingController();
  final TextEditingController _expediteurLieuController =
      TextEditingController();
  final TextEditingController _destinataireNomController =
      TextEditingController();
  final TextEditingController _destinataireLieuController =
      TextEditingController();

  @override
  void dispose() {
    _expediteurNomController.dispose();
    _expediteurLieuController.dispose();
    _destinataireNomController.dispose();
    _destinataireLieuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Contrôleurs')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Expéditeur - Nom:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _expediteurNomController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nom expéditeur',
              ),
            ),
            SizedBox(height: 16),
            Text('Expéditeur - Lieu:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _expediteurLieuController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Lieu expéditeur',
              ),
            ),
            SizedBox(height: 32),
            Text('Destinataire - Nom:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _destinataireNomController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nom destinataire',
              ),
            ),
            SizedBox(height: 16),
            Text('Destinataire - Lieu:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _destinataireLieuController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Lieu destinataire',
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                print('Expéditeur Nom: ${_expediteurNomController.text}');
                print('Expéditeur Lieu: ${_expediteurLieuController.text}');
                print('Destinataire Nom: ${_destinataireNomController.text}');
                print('Destinataire Lieu: ${_destinataireLieuController.text}');
              },
              child: Text('Afficher les valeurs'),
            ),
          ],
        ),
      ),
    );
  }
}
