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
  int get totalPoids => colisList.fold(0, (sum, c) => sum + (c.poids ?? 0));

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
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez remplir le champs description')));
      return;
    }

    // Convertir les objets _ColisBox en Map<String, dynamic>
    final colisListMap = colisList.map((colis) => colis.toMap()).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VillePage(
          phoneNumber: widget.phoneNumber,
          typeProduit: 'Colis',
          isReception: widget.isReception,
          colisDescription: _descController.text,
          colisList: colisListMap,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
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
                                      label: 'Qualité du colis',
                                      value: colisList[i].quality ?? '',
                                      onChanged: (v) => setState(
                                          () => colisList[i].quality = v)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _ColisField(
                                      label: 'Nombre de colis',
                                      value:
                                          colisList[i].nombre?.toString() ?? '',
                                      onChanged: (v) => setState(() =>
                                          colisList[i].nombre =
                                              int.tryParse(v))),
                                  const SizedBox(width: 8),
                                  _ColisField(
                                      label: 'Poids(kg)',
                                      value:
                                          colisList[i].poids?.toString() ?? '',
                                      onChanged: (v) => setState(() =>
                                          colisList[i].poids =
                                              int.tryParse(v))),
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
  String? quality;
  int? nombre;
  int? poids;

  bool get isValid => quality != null && nombre != null && poids != null;

  Map<String, dynamic> toMap() {
    return {
      'quality': quality,
      'nombre': nombre,
      'poids': poids,
    };
  }
}

class _ColisField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _ColisField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_ColisField> createState() => _ColisFieldState();
}

class _ColisFieldState extends State<_ColisField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_ColisField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          isDense: true,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
