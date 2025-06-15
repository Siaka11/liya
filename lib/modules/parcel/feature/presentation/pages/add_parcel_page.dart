import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/parcel_action_provider.dart';
import '../../domain/entities/parcel.dart';

@RoutePage()
class AddParcelPage extends ConsumerStatefulWidget {
  const AddParcelPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddParcelPage> createState() => _AddParcelPageState();
}

class _AddParcelPageState extends ConsumerState<AddParcelPage> {
  final _formKey = GlobalKey<FormState>();
  String sender = '';
  String receiver = '';
  String phone = '';
  String address = '';
  String instructions = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau colis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Expéditeur'),
                onSaved: (v) => sender = v ?? '',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Destinataire'),
                onSaved: (v) => receiver = v ?? '',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Téléphone'),
                onSaved: (v) => phone = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Adresse'),
                onSaved: (v) => address = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Instructions'),
                onSaved: (v) => instructions = v ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final action = ref.read(parcelActionProvider);
                    await action.addParcel.call(Parcel(
                      id: '',
                      senderName: sender,
                      receiverName: receiver,
                      status: 'RECEPTION',
                      createdAt: DateTime.now(),
                      address: address,
                      phone: phone,
                      instructions: instructions,
                    ));
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
