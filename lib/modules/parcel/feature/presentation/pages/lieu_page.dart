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

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _communeController.dispose();
    _quartierController.dispose();
    _secteurController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Charger les données existantes si disponibles
  void _loadExistingData() {
    try {
      // Récupérer les données utilisateur depuis LocalStorage
      final userDetailsJson = LocalStorageFactory().getUserDetails();
      if (userDetailsJson != null) {
        final userDetails = userDetailsJson is String
            ? jsonDecode(userDetailsJson)
            : userDetailsJson;

        // Pré-remplir avec les données utilisateur si disponibles
        final userName = userDetails['name'] ?? '';
        final userLastName = userDetails['lastName'] ?? '';
        final userFullName = '$userName $userLastName'.trim();

        if (userFullName.isNotEmpty) {
          // Si c'est un envoi, pré-remplir l'expéditeur
          if (!widget.isReception) {
            _communeController.text = userFullName;
          } else {
            // Si c'est une réception, pré-remplir le destinataire
            _secteurController.text = userFullName;
          }
        }

        // Pré-remplir l'adresse si disponible
        final userAddress = userDetails['address'] ?? '';
        if (userAddress.isNotEmpty) {
          if (!widget.isReception) {
            _quartierController.text = userAddress;
          } else {
            _phoneController.text = userAddress;
          }
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
                      onPressed: () async {
                        // Sauvegarder le colis
                        _saveParcel();

                        // Fermer le dialog
                        Navigator.of(context).pop();

                        // Attendre que le dialog soit complètement fermé
                        await Future.delayed(const Duration(milliseconds: 100));

                        // Navigation simple et sûre
                        if (mounted) {
                          print('🚀 Navigation simple vers ParcelHomePage...');

                          // Utiliser une navigation simple sans conflit
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const ParcelHomePage(),
                            ),
                          );

                          // Afficher le SnackBar après la navigation
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.white),
                                      const SizedBox(width: 12),
                                      const Expanded(
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
    try {
      final userDetailsJson = LocalStorageFactory().getUserDetails();
      final userDetails = userDetailsJson is String
          ? jsonDecode(userDetailsJson)
          : userDetailsJson;
      final phoneNumber = (userDetails['phoneNumber'] ?? '').toString();
      final ville = (userDetails['ville'] ?? widget.ville).toString();
      final action = ref.read(parcelActionProvider);

      // Récupérer les valeurs des contrôleurs avec les nouveaux noms
      final expediteurNom = _communeController.text.trim();
      final expediteurLieu = _quartierController.text.trim();
      final destinataireNom = _secteurController.text.trim();
      final destinataireLieu = _phoneController.text.trim();
      final descriptionColis = _descriptionController.text.trim();

      // Validation des champs requis
      if (expediteurNom.isEmpty ||
          expediteurLieu.isEmpty ||
          destinataireNom.isEmpty ||
          destinataireLieu.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez remplir tous les champs obligatoires'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Créer l'adresse complète avec les nouveaux champs
      final expediteurAddress = expediteurLieu;
      final destinataireAddress = destinataireLieu;

      // Créer les instructions avec description si disponible
      String instructions = widget.typeProduit;
      if (widget.colisDescription != null &&
          widget.colisDescription!.isNotEmpty) {
        instructions += ' - ${widget.colisDescription}';
      }
      if (descriptionColis.isNotEmpty) {
        instructions += ' - $descriptionColis';
      }

      final parcel = Parcel(
        id: _generateColisId(),
        senderName: expediteurNom, // Nom de l'expéditeur
        receiverName: destinataireNom, // Nom du destinataire
        status: 'reception', // Correction du statut
        createdAt: DateTime.now(),
        address: expediteurAddress, // Lieu de réception
        phone:
            destinataireAddress, // Lieu de livraison (utilise le champ phone temporairement)
        phoneNumber: phoneNumber,
        instructions: instructions,
        ville: widget.ville,
        colisDescription: widget.colisDescription,
        colisList: widget.colisList != null
            ? List<Map<String, dynamic>>.from(widget.colisList!)
            : null,
        // Nouveaux champs pour les informations complètes
        expediteurNom: expediteurNom,
        expediteurLieu: expediteurLieu,
        destinataireNom: destinataireNom,
        destinataireLieu: destinataireLieu,
        descriptionColis: descriptionColis,
        typeProduit: widget.typeProduit,
      );

      print('📦 === DÉBUT SAUVEGARDE COLIS ===');
      print('📦 ID: ${parcel.id}');
      print('📦 Expéditeur: $expediteurNom');
      print('📦 Lieu réception: $expediteurAddress');
      print('📦 Destinataire: $destinataireNom');
      print('📦 Lieu livraison: $destinataireAddress');
      print('📦 Instructions: $instructions');
      print('📦 Ville: ${parcel.ville}');
      print('📦 Type produit: ${widget.typeProduit}');

      // Sauvegarder dans Firebase
      await action.addParcel.call(parcel);

      if (mounted) {
        // Sauvegarde réussie - la navigation se fait depuis le bouton
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
            style: const TextStyle(color: Colors.white)),
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
                    border:
                        Border.all(color: const Color(0xFFF24E1E), width: 2),
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
                          'J\'envoie un Colis',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF24E1E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section Expéditeur
                      _buildSection(
                        title: 'Info Expéditeur:',
                        fields: [
                          _buildField(
                            label: 'Nom et Prénom',
                            controller: _communeController,
                            hint: '',
                            onSaved: (v) => commune = v ?? '',
                          ),
                          _buildField(
                            label: 'Lieu de réception du colis',
                            controller: _quartierController,
                            hint: '',
                            onSaved: (v) => quartier = v ?? '',
                          ),
                          _buildField(
                            label: 'Numéro de téléphone',
                            controller: _phoneController,
                            hint: '',
                            onSaved: (v) => phone = v ?? '',
                            isRequired: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Section Destinataire
                      _buildSection(
                        title: 'Info Destinataire:',
                        fields: [
                          _buildField(
                            label: 'Nom et Prénom',
                            controller: _secteurController,
                            hint: '',
                            onSaved: (v) => secteur = v ?? '',
                          ),
                          _buildField(
                            label: 'Lieu de livraison du colis',
                            controller: _quartierController,
                            hint: '',
                            onSaved: (v) => quartier = v ?? '',
                          ),
                          _buildField(
                            label: 'Numéro de téléphone',
                            controller: _phoneController,
                            hint: '',
                            onSaved: (v) => phone = v ?? '',
                            isRequired: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Champ description optionnel
                      if (widget.colisDescription != null)
                        _buildField(
                          label: 'Description du colis',
                          controller: _descriptionController,
                          hint: 'Instructions spéciales...',
                          onSaved: (v) => description = v ?? '',
                          isRequired: false,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section "Je reçois un colis" (référence)
                if (widget.isReception) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Je reçois un colis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        /* Text(
                          'Pareil - Les informations sont identiques à celles de l\'expédition',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                          ),
                        ),*/
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

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
                        _formKey.currentState!.save();
                        _showConfirmDialog();
                      }
                    },
                    child: const Text(
                      'Confirmer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Function(String?) onSaved,
    bool isRequired = true,
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
          decoration: InputDecoration(
            hintText: hint,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: isRequired
              ? (v) => v == null || v.isEmpty ? 'Champ requis' : null
              : null,
          onSaved: onSaved,
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
