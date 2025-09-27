import 'package:flutter/material.dart';

/// Test rapide pour vérifier que les contrôleurs fonctionnent correctement
class TestControleursRapide extends StatefulWidget {
  @override
  _TestControleursRapideState createState() => _TestControleursRapideState();
}

class _TestControleursRapideState extends State<TestControleursRapide> {
  // Contrôleurs séparés comme dans lieu_page.dart
  final _expediteurNomController = TextEditingController();
  final _expediteurLieuController = TextEditingController();
  final _destinataireNomController = TextEditingController();
  final _destinataireLieuController = TextEditingController();

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
      appBar: AppBar(
        title: Text('Test Contrôleurs - Correction'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Test des contrôleurs corrigés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Champ 1: Nom expéditeur
            Text('Expéditeur - Nom:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _expediteurNomController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tapez le nom expéditeur...',
              ),
            ),
            SizedBox(height: 16),

            // Champ 2: Lieu expéditeur
            Text('Expéditeur - Lieu:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _expediteurLieuController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tapez le lieu expéditeur...',
              ),
            ),
            SizedBox(height: 32),

            // Champ 3: Nom destinataire
            Text('Destinataire - Nom:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _destinataireNomController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tapez le nom destinataire...',
              ),
            ),
            SizedBox(height: 16),

            // Champ 4: Lieu destinataire
            Text('Destinataire - Lieu:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _destinataireLieuController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tapez le lieu destinataire...',
              ),
            ),
            SizedBox(height: 32),

            // Bouton de test
            ElevatedButton(
              onPressed: () {
                print('=== TEST DES CONTRÔLEURS ===');
                print('Expéditeur Nom: "${_expediteurNomController.text}"');
                print('Expéditeur Lieu: "${_expediteurLieuController.text}"');
                print('Destinataire Nom: "${_destinataireNomController.text}"');
                print(
                    'Destinataire Lieu: "${_destinataireLieuController.text}"');
                print('==========================');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Valeurs affichées dans la console'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Afficher les valeurs'),
            ),

            SizedBox(height: 16),

            // Instructions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions de test:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800),
                  ),
                  SizedBox(height: 8),
                  Text('1. Tapez "Jean Dupont" dans le champ Expéditeur Nom'),
                  Text('2. Tapez "Abidjan" dans le champ Expéditeur Lieu'),
                  Text(
                      '3. Tapez "Marie Martin" dans le champ Destinataire Nom'),
                  Text('4. Tapez "Bouaké" dans le champ Destinataire Lieu'),
                  Text('5. Cliquez sur "Afficher les valeurs"'),
                  Text('6. Vérifiez que chaque champ garde son propre texte'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TestControleursRapide(),
    title: 'Test Contrôleurs',
  ));
}
