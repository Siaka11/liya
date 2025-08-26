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
import 'package:liya/core/services/navigation_service.dart';

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
  const LieuPage({
    Key? key,
    required this.phoneNumber,
    required this.typeProduit,
    this.isReception = false,
    required this.ville,
    this.colisDescription,
    this.colisList,
  }) : super(key: key);

  @override
  ConsumerState<LieuPage> createState() => _LieuPageState();
}

class _LieuPageState extends ConsumerState<LieuPage> {
  final _formKey = GlobalKey<FormState>();

  // ====== Controllers COHÉRENTS ======
  // Expéditeur
  final _expediteurNomController = TextEditingController();
  final _expediteurLieuController = TextEditingController();
  final _expediteurPhoneController = TextEditingController();

  // Destinataire
  final _destinataireNomController = TextEditingController();
  final _destinataireLieuController = TextEditingController();
  final _destinatairePhoneController = TextEditingController();

  // Description
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _expediteurNomController.dispose();
    _expediteurLieuController.dispose();
    _expediteurPhoneController.dispose();

    _destinataireNomController.dispose();
    _destinataireLieuController.dispose();
    _destinatairePhoneController.dispose();

    _descriptionController.dispose();
    super.dispose();
  }

  // Pré-remplissage: si l'utilisateur est le demandeur, on suppose qu'il est l'expéditeur (cas par défaut)
  // Si widget.isReception == true, on pré-remplit plutôt le destinataire.
  void _loadExistingData() {
    try {
      final userDetailsJson = LocalStorageFactory().getUserDetails();
      if (userDetailsJson != null) {
        final userDetails = userDetailsJson is String
            ? jsonDecode(userDetailsJson)
            : userDetailsJson;

        final userName = (userDetails['name'] ?? '').toString();
        final userLastName = (userDetails['lastName'] ?? '').toString();
        final userFullName = '$userName $userLastName'.trim();
        final userPhone = (userDetails['phoneNumber'] ?? '').toString();
        final userAddress = (userDetails['address'] ?? '').toString();

        if (!widget.isReception) {
          // Cas "J'envoie un colis" : l'utilisateur est l'expéditeur
          if (userFullName.isNotEmpty) _expediteurNomController.text = userFullName;
          if (userPhone.isNotEmpty) _expediteurPhoneController.text = userPhone;
          if (userAddress.isNotEmpty) _expediteurLieuController.text = userAddress;
        } else {
          // Cas "Je reçois un colis" : l'utilisateur est le destinataire
          if (userFullName.isNotEmpty) _destinataireNomController.text = userFullName;
          if (userPhone.isNotEmpty) _destinatairePhoneController.text = userPhone;
          if (userAddress.isNotEmpty) _destinataireLieuController.text = userAddress;
        }
      }
    } catch (e) {
      print('⚠️ Erreur lors du chargement des données existantes: $e');
    }
  }

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
                const Text('Je confirme ma commande', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        side: const BorderSide(color: Color(0xFFF24E1E)),
                        foregroundColor: Color(0xFFF24E1E),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Sauvegarder le colis
                        await _saveParcel();

                        // Fermer le dialog
                        if (mounted) Navigator.of(context).pop();

                        // Petite pause pour laisser fermer le dialog
                        await Future.delayed(const Duration(milliseconds: 100));

                        // Navigation sûre + SnackBar
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const ParcelHomePage()),
                          );
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: const [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Votre demande de colis a été prise en compte avec succès !',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF4BB543),
                                  duration: const Duration(seconds: 4),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF24E1E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Future<void> _saveParcel() async {
    try {
      final userDetailsJson = LocalStorageFactory().getUserDetails();
      final userDetails = userDetailsJson is String
          ? jsonDecode(userDetailsJson)
          : userDetailsJson;

      final currentUserPhone = (userDetails['phoneNumber'] ?? '').toString();
      final ville = (userDetails['ville'] ?? widget.ville).toString();
      final action = ref.read(parcelActionProvider);

      // Récupération valeurs
      final expediteurNom = _expediteurNomController.text.trim();
      final expediteurLieu = _expediteurLieuController.text.trim();
      final expediteurPhone = _expediteurPhoneController.text.trim();

      final destinataireNom = _destinataireNomController.text.trim();
      final destinataireLieu = _destinataireLieuController.text.trim();
      final destinatairePhone = _destinatairePhoneController.text.trim();

      final descriptionColis = _descriptionController.text.trim();

      // Validation stricte
      if (expediteurNom.isEmpty ||
          expediteurLieu.isEmpty ||
          expediteurPhone.isEmpty ||
          destinataireNom.isEmpty ||
          destinataireLieu.isEmpty ||
          destinatairePhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez remplir tous les champs obligatoires'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Instructions
      String instructions = widget.typeProduit;
      if ((widget.colisDescription ?? '').isNotEmpty) {
        instructions += ' - ${widget.colisDescription}';
      }
      if (descriptionColis.isNotEmpty) {
        instructions += ' - $descriptionColis';
      }

      // Construction du Parcel
      final parcel = Parcel(
        id: _generateColisId(),
        // Champs "legacy"
        senderName: expediteurNom,
        receiverName: destinataireNom,
        status: 'reception',
        createdAt: DateTime.now(),
        address: expediteurLieu,                 // adresse expéditeur
        phone: destinatairePhone,                // téléphone destinataire (mieux que l'utiliser pour une adresse)
        phoneNumber: currentUserPhone,           // téléphone du user connecté
        instructions: instructions,
        ville: ville,
        colisDescription: widget.colisDescription,
        colisList: widget.colisList != null
            ? List<Map<String, dynamic>>.from(widget.colisList!)
            : null,

        // Champs détaillés et cohérents
        expediteurNom: expediteurNom,
        expediteurLieu: expediteurLieu,
        expediteurPhone: expediteurPhone,        // <-- AJOUT
        destinataireNom: destinataireNom,
        destinataireLieu: destinataireLieu,
        destinatairePhone: destinatairePhone,    // <-- AJOUT
        descriptionColis: descriptionColis,
        typeProduit: widget.typeProduit,
      );

      print('📦 === DÉBUT SAUVEGARDE COLIS ===');
      print('📦 ID: ${parcel.id}');
      print('📦 Expéditeur: $expediteurNom | $expediteurPhone | $expediteurLieu');
      print('📦 Destinataire: $destinataireNom | $destinatairePhone | $destinataireLieu');
      print('📦 Instructions: $instructions');
      print('📦 Ville: ${parcel.ville}');
      print('📦 Type produit: ${widget.typeProduit}');

      await action.addParcel.call(parcel);
      if (mounted) {
        print('✅ Colis sauvegardé avec succès dans Firebase');
      }
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde du colis: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
          widget.isReception ? 'Je reçois un colis' : 'J\'envoie un colis',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section principale avec bordure
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF24E1E), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre principal
                      Center(
                        child: Text(
                          widget.isReception ? 'Je reçois un Colis' : 'J\'envoie un Colis',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF24E1E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ====== Section Expéditeur
                      _buildSection(
                        title: 'Info Expéditeur:',
                        fields: [
                          _buildField(
                            label: 'Nom et Prénom',
                            controller: _expediteurNomController,
                          ),
                          _buildField(
                            label: 'Lieu de réception du colis',
                            controller: _expediteurLieuController,
                          ),
                          _buildField(
                            label: 'Numéro de téléphone de l\'expéditeur',
                            controller: _expediteurPhoneController,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ====== Section Destinataire
                      _buildSection(
                        title: 'Info Destinataire:',
                        fields: [
                          _buildField(
                            label: 'Nom et Prénom',
                            controller: _destinataireNomController,
                          ),
                          _buildField(
                            label: 'Lieu de livraison du colis',
                            controller: _destinataireLieuController,
                          ),
                          _buildField(
                            label: 'Numéro de téléphone du destinataire',
                            controller: _destinatairePhoneController,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Bouton de confirmation
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF24E1E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showConfirmDialog();
                      }
                    },
                    child: const Text(
                      'Confirmer',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _ParcelBottomNavBar(),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> fields,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF24E1E),
          ),
        ),
        const SizedBox(height: 12),
        ...fields,
      ],
    );
  }

  // Champ générique, sans incohérence de nommage ni onSaved inutile
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: '',
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFF24E1E), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: isRequired
              ? (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null
              : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ParcelBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping, color: Colors.deepOrange), label: 'Mes livraisons'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Menu principal'),
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



