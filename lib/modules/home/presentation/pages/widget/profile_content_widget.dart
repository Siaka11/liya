import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/local_storage_factory.dart';
import '../../../../../core/singletons.dart';
import '../../../../../core/services/phone_call_service.dart';
import '../../../../../routes/app_router.dart';
import '../../../../../core/services/account_management_service.dart';
import '../../../../../routes/app_router.gr.dart';
import '../../../../auth/auth_provider.dart';
import '../../../../auth/info_user_provider.dart';
import '../../../../restaurant/features/profile/presentation/providers/profile_provider.dart';
import '../../../application/home_provider.dart';

class ProfileContentWidget extends ConsumerWidget {
  final VoidCallback? onClose;

  const ProfileContentWidget({Key? key, this.onClose}) : super(key: key);

  Future<void> _callNumber(BuildContext context, String number) async {
    try {
      debugPrint('Tentative d\'appel vers: $number');

      final success = await PhoneCallService.makeCall(number);

      if (!success) {
        _showCopySnackBar(context, number);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'appel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'appel : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCopySnackBar(BuildContext context, String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Impossible d\'ouvrir l\'application Téléphone.\nNuméro : $number'),
        action: SnackBarAction(
          label: 'Copier',
          onPressed: () async {
            await PhoneCallService.copyToClipboard(number);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Numéro copié dans le presse-papiers'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';
    var userId = phoneNumber;
    final profileAsync = ref.watch(profileProvider(userId));

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header avec bouton fermer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profil',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _callNumber(context, '+2250700846546'),
                      child: const Text(
                        'Call center',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Contenu du profil
          Expanded(
            child: profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (user) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Section informations utilisateur
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.deepOrange.withOpacity(0.1),
                            child: Text(
                              (user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U'),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Nom - utiliser seulement user.name car lastName n'existe pas
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Numéro de téléphone - gérer la nullabilité
                          Text(
                            user.phoneNumber ?? 'Aucun numéro',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Actions supplémentaires
                    _buildActionTile(
                      icon: Icons.phone,
                      title: 'Appeler le support',
                      subtitle: '+225 07 00 84 65 46',
                      onTap: () => _callNumber(context, '+2250700846546'),
                    ),
                    const SizedBox(height: 12),
                    _buildActionTile(
                      icon: Icons.location_on,
                      title: 'Adresse',
                      subtitle:
                          user.address?.toString() ?? 'Aucune adresse définie',
                      onTap: () {
                        // Logique pour modifier l'adresse
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionTile(
                      icon: Icons.email,
                      title: 'Email',
                      subtitle: user.email.isNotEmpty
                          ? user.email
                          : 'Aucun email défini',
                      onTap: () {
                        // Logique pour modifier l'email
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionTile(
                      icon: Icons.logout,
                      title: 'Déconnexion',
                      subtitle: 'Se déconnecter de l\'application',
                      isDestructive: true,
                      onTap: () async {
                        _showLogoutDialog(context, ref);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.deepOrange,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, WidgetRef ref, dynamic user) {
    // Implémentation de la boîte de dialogue d'édition
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le profil'),
        content:
            const Text('Fonctionnalité d\'édition du profil à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    // Utiliser le nouveau service de gestion des comptes
    AccountManagementService.showLogoutDialog(context);
  }
}
