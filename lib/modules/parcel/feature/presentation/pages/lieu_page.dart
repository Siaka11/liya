import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../routes/app_router.gr.dart';
import '../providers/parcel_action_provider.dart';
import '../../domain/entities/parcel.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'dart:convert';
import 'parcel_home_page.dart';

import 'package:liya/modules/home/presentation/pages/home_page.dart';
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart';

@RoutePage()
class LieuPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String typeProduit;
  final bool isReception;
  final String ville;
  final String? colisDescription;
  final List<dynamic>? colisList;
  const LieuPage(
      {Key? key,
      required this.phoneNumber,
      required this.typeProduit,
      this.isReception = false,
      required this.ville,
      this.colisDescription,
      this.colisList})
      : super(key: key);

  @override
  ConsumerState<LieuPage> createState() => _LieuPageState();
}

class _LieuPageState extends ConsumerState<LieuPage> {
  final _formKey = GlobalKey<FormState>();
  String phone = '';
  String commune = '';
  String quartier = '';
  String secteur = '';
  String description = '';
  final _communeController = TextEditingController();
  final _quartierController = TextEditingController();
  final _secteurController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text('Je confirme ma commande',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        side: const BorderSide(color: Color(0xFFF24E1E)),
                        foregroundColor: Color(0xFFF24E1E),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: _saveParcel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF24E1E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Confirmer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveParcel() async {
    final userDetailsJson = LocalStorageFactory().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = (userDetails['phoneNumber'] ?? '').toString();
    final ville = (userDetails['ville'] ?? widget.ville).toString();
    final action = ref.read(parcelActionProvider);

    // Récupérer les valeurs des contrôleurs
    commune = _communeController.text;
    quartier = _quartierController.text;
    secteur = _secteurController.text;
    phone = _phoneController.text;
    description = _descriptionController.text;

    // Créer l'adresse complète
    final address = 'Commune: $commune, Quartier: $quartier, Secteur: $secteur';

    // Créer les instructions avec description si disponible
    String instructions = widget.typeProduit;
    if (widget.colisDescription != null &&
        widget.colisDescription!.isNotEmpty) {
      instructions += ' - ${widget.colisDescription}';
    }
    if (description.isNotEmpty) {
      instructions += ' - $description';
    }

    final parcel = Parcel(
      id: _generateColisId(),
      senderName: widget.isReception ? '' : 'Expéditeur',
      receiverName: widget.isReception ? 'Destinataire' : '',
      status: 'RECEPTION',
      createdAt: DateTime.now(),
      address: address,
      phone: phone,
      phoneNumber: phoneNumber,
      instructions: instructions,
      ville: widget.ville,
      colisDescription: widget.colisDescription,
      colisList: widget.colisList != null
          ? List<Map<String, dynamic>>.from(widget.colisList!)
          : null,
    );

    print('DEBUG - Parcel data to save:');
    print('id: ${parcel.id}');
    print('senderName: ${parcel.senderName}');
    print('receiverName: ${parcel.receiverName}');
    print('address: ${parcel.address}');
    print('phone: ${parcel.phone}');
    print('phoneNumber: ${parcel.phoneNumber}');
    print('instructions: ${parcel.instructions}');
    print('ville: ${parcel.ville}');
    print('colisDescription: ${parcel.colisDescription}');
    print('colisList: ${parcel.colisList}');

    await action.addParcel.call(parcel);
    if (mounted) {
      Navigator.pop(context); // Ferme le pop-up
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _SuccessDialog(),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context); // Ferme le dialog d'animation
        // Utiliser addPostFrameCallback pour éviter le conflit de navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.router.replaceAll([const ParcelHomeRoute()]);
          }
        });
      }
    }
  }

  String _generateColisId() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return 'COLIS${y}${m}${d}${h}${min}${s}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
            widget.isReception ? 'Je reçois un colis' : 'Je livre un colis',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Précise le lieu',
                  style: TextStyle(
                      color: Color(0xFFF24E1E),
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Commune',
                  filled: true,
                  fillColor: Color(0xFFF1F1F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
                onSaved: (v) => commune = v ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Quartier',
                  filled: true,
                  fillColor: Color(0xFFF1F1F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
                onSaved: (v) => quartier = v ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Secteur',
                  filled: true,
                  fillColor: Color(0xFFF1F1F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
                onSaved: (v) => secteur = v ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Numéro de téléphone',
                  filled: true,
                  fillColor: Color(0xFFF1F1F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
                onSaved: (v) => phone = v ?? '',
                keyboardType: TextInputType.phone,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF24E1E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      _showConfirmDialog();
                    }
                  },
                  child:
                      const Text('Confirmer', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _ParcelBottomNavBar(),
    );
  }
}

class _ParcelBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
      ],
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          AutoRouter.of(context).replace(const HomeRoute());
        } else if (index == 1) {
          AutoRouter.of(context).replace(const ParcelHomeRoute());
        } else if (index == 2) {
          AutoRouter.of(context).replace(const ProfileRoute());
        }
      },
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();
  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4BB543),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Commande enregistrée avec succès !',
                  style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}
