import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../routes/app_router.gr.dart';
import '../providers/parcel_action_provider.dart';
import '../../domain/entities/parcel.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/services/connection_manager.dart';
import 'package:liya/core/ui/widgets/connection_status_widget.dart';
import 'dart:convert';
import 'parcel_home_page.dart';

@RoutePage()
class LieuPageControllersFixed extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String typeProduit;
  final bool isReception;
  final String ville;
  final String? colisDescription;
  final List<dynamic>? colisList;

  const LieuPageControllersFixed({
    super.key,
    required this.phoneNumber,
    required this.typeProduit,
    this.isReception = false,
    required this.ville,
    this.colisDescription,
    this.colisList,
  });

  @override
  ConsumerState<LieuPageControllersFixed> createState() =>
      _LieuPageControllersFixedState();
}

class _LieuPageControllersFixedState
    extends ConsumerState<LieuPageControllersFixed> {
  final _formKey = GlobalKey<FormState>();

  // ====== CONTRÔLEURS COMPLÈTEMENT ISOLÉS ======
  // Chaque contrôleur a un nom unique et distinct
  final _expediteurNomCtrl = TextEditingController();
  final _expediteurLieuCtrl = TextEditingController();
  final _expediteurPhoneCtrl = TextEditingController();

  final _destinataireNomCtrl = TextEditingController();
  final _destinataireLieuCtrl = TextEditingController();
  final _destinatairePhoneCtrl = TextEditingController();

  final _descriptionCtrl = TextEditingController();

  String _selectedVille = '';
  final ConnectionManager _connectionManager = ConnectionManager();

  @override
  void initState() {
    super.initState();
    _selectedVille = widget.ville;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectionManager.setCurrentContext(context);
    });
    _loadExistingData();
  }

  @override
  void dispose() {
    // Libération explicite de chaque contrôleur
    _expediteurNomCtrl.dispose();
    _expediteurLieuCtrl.dispose();
    _expediteurPhoneCtrl.dispose();
    _destinataireNomCtrl.dispose();
    _destinataireLieuCtrl.dispose();
    _destinatairePhoneCtrl.dispose();
    _descriptionCtrl.dispose();
    _connectionManager.clearCurrentContext();
    super.dispose();
  }

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
          if (userFullName.isNotEmpty) {
            _expediteurNomCtrl.text = userFullName;
          }
          if (userPhone.isNotEmpty) {
            _expediteurPhoneCtrl.text = userPhone;
          }
          if (userAddress.isNotEmpty) {
            _expediteurLieuCtrl.text = userAddress;
          }
        } else {
          // Cas "Je reçois un colis" : l'utilisateur est le destinataire
          if (userFullName.isNotEmpty) {
            _destinataireNomCtrl.text = userFullName;
          }
          if (userPhone.isNotEmpty) {
            _destinatairePhoneCtrl.text = userPhone;
          }
          if (userAddress.isNotEmpty) {
            _destinataireLieuCtrl.text = userAddress;
          }
        }
      }
    } catch (e) {
      print('⚠️ Erreur lors du chargement des données existantes: $e');
    }
  }

  void _showConfirmDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirmer votre commande',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Voulez-vous finaliser votre demande de colis ?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton Confirmer
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _saveParcel();

                      await Future.delayed(const Duration(milliseconds: 100));

                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const ParcelHomePage()),
                          (route) => false,
                        );

                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Votre demande de colis a été prise en compte avec succès !',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Color(0xFF4BB543),
                                duration: Duration(seconds: 4),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                margin: EdgeInsets.all(16),
                              ),
                            );
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF24E1E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirmer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Bouton Annuler
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveParcel() async {
    try {
      final userDetailsJson = LocalStorageFactory().getUserDetails();
      final userDetails = userDetailsJson is String
          ? jsonDecode(userDetailsJson)
          : userDetailsJson;

      final currentUserPhone = (userDetails['phoneNumber'] ?? '').toString();
      final ville = _selectedVille;
      final action = ref.read(parcelActionProvider);

      // Récupération valeurs avec contrôleurs uniques
      final expediteurNom = _expediteurNomCtrl.text.trim();
      final expediteurLieu = _expediteurLieuCtrl.text.trim();
      final expediteurPhone = _expediteurPhoneCtrl.text.trim();

      final destinataireNom = _destinataireNomCtrl.text.trim();
      final destinataireLieu = _destinataireLieuCtrl.text.trim();
      final destinatairePhone = _destinatairePhoneCtrl.text.trim();

      final descriptionColis = _descriptionCtrl.text.trim();

      String instructions = widget.typeProduit;
      if ((widget.colisDescription ?? '').isNotEmpty) {
        instructions += ' - ${widget.colisDescription}';
      }
      if (descriptionColis.isNotEmpty) {
        instructions += ' - $descriptionColis';
      }

      final parcel = Parcel(
        id: _generateColisId(),
        senderName: expediteurNom,
        receiverName: destinataireNom,
        status: 'reception',
        createdAt: DateTime.now(),
        address: expediteurLieu,
        phone: destinatairePhone,
        phoneNumber: currentUserPhone,
        instructions: instructions,
        ville: ville,
        colisDescription: widget.colisDescription,
        colisList: widget.colisList != null
            ? List<Map<String, dynamic>>.from(widget.colisList!)
            : null,
        expediteurNom: expediteurNom,
        expediteurLieu: expediteurLieu,
        expediteurPhone: expediteurPhone,
        destinataireNom: destinataireNom,
        destinataireLieu: destinataireLieu,
        destinatairePhone: destinatairePhone,
        descriptionColis: descriptionColis,
        typeProduit: widget.typeProduit,
      );

      print('📦 === SAUVEGARDE COLIS (CONTRÔLEURS FIXÉS) ===');
      print(
          '📦 Expéditeur: $expediteurNom | $expediteurPhone | $expediteurLieu');
      print(
          '📦 Destinataire: $destinataireNom | $destinatairePhone | $destinataireLieu');

      // Préparer les données de colis
      final parcelData = {
        'phoneNumber': widget.phoneNumber,
        'typeProduit': widget.typeProduit,
        'isReception': widget.isReception,
        'ville': ville,
        'colisDescription': widget.colisDescription,
        'colisList': widget.colisList,
        'expediteurNom': expediteurNom,
        'expediteurLieu': expediteurLieu,
        'expediteurPhone': expediteurPhone,
        'destinataireNom': destinataireNom,
        'destinataireLieu': destinataireLieu,
        'destinatairePhone': destinatairePhone,
        'descriptionColis': descriptionColis,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _connectionManager.saveParcelData(parcelData);

      await _connectionManager.executeWithConnectionHandling(
        () => action.addParcel.call(parcel),
        operationType: 'parcel_save',
        fallbackData: parcelData,
      );

      if (mounted) {
        print('✅ Colis sauvegardé avec succès');
        await _connectionManager.clearOfflineData();
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ConnectionStatusWidget(
                showWhenConnected: false,
                showWhenDisconnected: true,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          widget.isReception
                              ? 'Je reçois un Colis'
                              : 'J\'envoie un Colis',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF24E1E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ====== Section Expéditeur ======
                      _buildSection(
                        title: 'Info Expéditeur:',
                        fields: [
                          _buildSimpleField(
                            label: 'Nom et Prénom',
                            controller: _expediteurNomCtrl,
                          ),
                          _buildSimpleField(
                            label: 'Lieu de réception du colis',
                            controller: _expediteurLieuCtrl,
                          ),
                          _buildSimpleField(
                            label: 'Numéro de téléphone de l\'expéditeur',
                            controller: _expediteurPhoneCtrl,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ====== Section Destinataire ======
                      _buildSection(
                        title: 'Info Destinataire:',
                        fields: [
                          _buildSimpleField(
                            label: 'Nom et Prénom',
                            controller: _destinataireNomCtrl,
                          ),
                          _buildSimpleField(
                            label: 'Lieu de livraison du colis',
                            controller: _destinataireLieuCtrl,
                          ),
                          _buildSimpleField(
                            label: 'Numéro de téléphone du destinataire',
                            controller: _destinatairePhoneCtrl,
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
                      // Validation manuelle
                      if (_expediteurNomCtrl.text.trim().isEmpty ||
                          _expediteurLieuCtrl.text.trim().isEmpty ||
                          _expediteurPhoneCtrl.text.trim().isEmpty ||
                          _destinataireNomCtrl.text.trim().isEmpty ||
                          _destinataireLieuCtrl.text.trim().isEmpty ||
                          _destinatairePhoneCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Veuillez remplir tous les champs obligatoires'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      _showConfirmDialog();
                    },
                    child: const Text(
                      'Confirmer',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildSection({required String title, required List<Widget> fields}) {
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

  // Champ simple sans Google Places pour éviter les conflits
  Widget _buildSimpleField({
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
            hintText: 'Tapez ici...',
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
        BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, color: Colors.deepOrange),
            label: 'Mes livraisons'),
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Menu principal'),
      ],
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          AutoRouter.of(context).replace(const HomeRoute());
        } else if (index == 1) {
          AutoRouter.of(context).replace(const ParcelHomeRoute());
        } else if (index == 2) {
          AutoRouter.of(context).replace(const HomeRoute());
        }
      },
    );
  }
}
