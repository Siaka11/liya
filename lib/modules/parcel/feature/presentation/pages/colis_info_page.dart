import 'package:flutter/material.dart';
import 'ville_page.dart';

class ColisInfoPage extends StatefulWidget {
  final String phoneNumber;
  final bool isReception;
  const ColisInfoPage(
      {Key? key, required this.phoneNumber, required this.isReception})
      : super(key: key);

  @override
  State<ColisInfoPage> createState() => _ColisInfoPageState();
}

class _ColisInfoPageState extends State<ColisInfoPage> {
  final _descController = TextEditingController();
  List<_ColisBox> colisList = [
    _ColisBox(),
  ];

  int get totalColis => colisList.fold(0, (sum, c) => sum + (c.nombre ?? 0));
  double get totalPoids => colisList.fold(0, (sum, c) => sum + (c.poids ?? 0));

  void _addColis() {
    setState(() {
      colisList.add(_ColisBox());
    });
  }

  void _removeColis(int index) {
    setState(() {
      colisList.removeAt(index);
    });
  }

  void _onConfirm() {
    if (_descController.text.isEmpty || colisList.any((c) => !c.isValid)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir tous les champs')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VillePage(
          phoneNumber: widget.phoneNumber,
          typeProduit: 'Colis',
          isReception: widget.isReception,
          colisDescription: _descController.text,
          colisList: colisList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Colis', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                hintText: 'Description',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: colisList.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Votre emballage',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _ColisField(
                                      label: 'Long.(en cm)',
                                      initialValue: colisList[i].longueur,
                                      onChanged: (v) => setState(() =>
                                          colisList[i].longueur =
                                              double.tryParse(v))),
                                  const SizedBox(width: 8),
                                  _ColisField(
                                      label: 'Larg.(en cm)',
                                      initialValue: colisList[i].largeur,
                                      onChanged: (v) => setState(() =>
                                          colisList[i].largeur =
                                              double.tryParse(v))),
                                  const SizedBox(width: 8),
                                  _ColisField(
                                      label: 'Haut.(en cm)',
                                      initialValue: colisList[i].hauteur,
                                      onChanged: (v) => setState(() =>
                                          colisList[i].hauteur =
                                              double.tryParse(v))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _ColisField(
                                      label: 'Nombre de colis',
                                      initialValue: colisList[i].nombre,
                                      onChanged: (v) => setState(() =>
                                          colisList[i].nombre =
                                              int.tryParse(v))),
                                  const SizedBox(width: 8),
                                  _ColisField(
                                      label: 'Poids(kg)',
                                      initialValue: colisList[i].poids,
                                      onChanged: (v) => setState(() =>
                                          colisList[i].poids =
                                              double.tryParse(v))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: i > 0
                              ? GestureDetector(
                                  onTap: () => _removeColis(i),
                                  child: const Icon(Icons.delete,
                                      color: Colors.red),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            TextButton.icon(
              onPressed: _addColis,
              icon: const Icon(Icons.add, color: Colors.blue),
              label: const Text('Rajouter des colis',
                  style: TextStyle(color: Colors.blue)),
            ),
            const SizedBox(height: 8),
            Text('Nombre de colis  ${totalColis}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Poids total de l'envoi  ${totalPoids}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF24E1E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: _onConfirm,
                child: const Text('Confirmer', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColisBox {
  double? longueur;
  double? largeur;
  double? hauteur;
  int? nombre;
  double? poids;

  bool get isValid =>
      longueur != null &&
      largeur != null &&
      hauteur != null &&
      nombre != null &&
      poids != null;
}

class _ColisField extends StatelessWidget {
  final String label;
  final dynamic initialValue;
  final ValueChanged<String> onChanged;
  const _ColisField(
      {required this.label,
      required this.initialValue,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          isDense: true,
        ),
        controller: TextEditingController(text: initialValue?.toString() ?? ''),
        onChanged: onChanged,
      ),
    );
  }
}
