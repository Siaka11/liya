import 'dart:convert';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../core/local_storage_factory.dart';
import '../../../../../../core/singletons.dart';
import '../../../../../../routes/app_router.gr.dart';
import '../../../../../auth/auth_provider.dart';
import '../../../../../auth/info_user_provider.dart';
import '../../../../../home/application/home_provider.dart';
import '../../../home/presentation/widget/navigation_footer.dart';
import '../providers/profile_provider.dart';
import '../../../../../../core/services/account_management_service.dart';

@RoutePage(name: 'ProfileRoute')
class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  // Demander la permission CALL_PHONE au runtime
  Future<bool> _requestCallPermission() async {
    final status = await Permission.phone.status;
    if (status.isGranted) {
      return true;
    } else {
      final result = await Permission.phone.request();
      return result.isGranted;
    }
  }

  Future<void> _callNumber(BuildContext context, String number) async {
    final Uri phoneUri = Uri.parse('tel:$number');

    try {
      final hasPermission = await _requestCallPermission();

      if (!hasPermission) {
        // Permission refusée, proposer de copier le numéro
        _showCopySnackBar(context, number);
        return;
      }

      if (await canLaunchUrl(phoneUri)) {
        final launched = await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          _showCopySnackBar(context, number);
        }
      } else {
        _showCopySnackBar(context, number);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'appel : $e')),
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
          onPressed: () {
            Clipboard.setData(ClipboardData(text: number));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Numéro copié dans le presse-papiers')),
            );
          },
        ),
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
    final profileAsync = ref.watch(profileProvider(phoneNumber));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const SizedBox(),
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.deepOrange),
        ),
        actions: [
          TextButton(
            onPressed: () => _callNumber(context, '+2250700846546'),
            child: const Text(
              'Call center',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Erreur: ${error.toString()}')),
        data: (profile) => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section profil
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            profile.name.isNotEmpty
                                ? profile.name
                                    .substring(0, min(2, profile.name.length))
                                : '??',
                            style: TextStyle(
                                fontSize: 24, color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                profile.email,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Commandes
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Commandes',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_outlined),
                    title: const Text('Mes commandes'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${profile.orders.length}'),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      // TODO: Naviguer vers les commandes
                    },
                  ),

                  // Favoris
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Favoris',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite_border),
                    title: const Text('Mes favoris'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${profile.orders.length}'),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      // TODO: Naviguer vers les favoris
                    },
                  ),

                  // Compte et sécurité
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Compte et sécurité',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.contact_support_outlined),
                    title: const Text('Contact'),
                    subtitle: Text(profile.phone ?? 'Ajouter un numéro'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Naviguer vers contact
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Adresses'),
                    subtitle: Text(
                        '${profile.address.length} adress${profile.address.length > 1 ? "es" : ""}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Naviguer vers adresses
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Déconnexion'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Utiliser le nouveau service de gestion des comptes
                          await AccountManagementService.showLogoutDialog(
                              context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavigationFooter(),
    );
  }
}
