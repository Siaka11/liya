import 'dart:convert';
import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/local_storage_factory.dart';
import '../../../../../../core/routes/app_router.dart';
import '../../../../../../core/singletons.dart';
import '../../../../../auth/auth_provider.dart';
import '../../../../../auth/info_user_provider.dart';
import '../../../../../home/application/home_provider.dart';
import '../providers/profile_provider.dart';

@RoutePage(name: 'ProfileRoute')
class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual user ID
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';
    var userId = phoneNumber;
    final profileAsync = ref.watch(profileProvider(userId));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profil',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement help functionality
            },
            child: Text(
              ' Call center',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Erreur: [38;5;9m${error.toString()}[0m')),
        data: (profile) => Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
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
                              fontSize: 24,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                profile.email,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        /*IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {
                            // TODO: Implement profile edit
                          },
                        ),*/
                      ],
                    ),
                  ),

                  // Orders Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Commandes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.receipt_outlined),
                    title: Text('Mes commandes'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${profile.orders.length}'),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate to orders
                    },
                  ),

                  //Favoris
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Favoris',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.receipt_outlined),
                    title: Text('Mes favoris'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${profile.orders.length}'),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate to orders
                    },
                  ),
                  // Sell Section
/*              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Vendre',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),*/
/*              ListTile(
                leading: Icon(Icons.store_outlined),
                title: Text('Mes annonces'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to listings
                },
              ),
              ListTile(
                leading: Icon(Icons.bar_chart_outlined),
                title: Text('Mes ventes'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to sales
                },
              ),
              ListTile(
                leading: Icon(Icons.payments_outlined),
                title: Text('Paiements'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to payments
                },
              ),*/

                  // Account Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Compte et sécurité',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.contact_support_outlined),
                    title: Text('Contact'),
                    subtitle: Text(profile.phone ?? 'Ajouter un numéro'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to contact
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text('Adresses'),
                    subtitle: Text('${profile.address.length} adress'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to addresses
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('Adresses'),
                    subtitle: Text('${profile.email.length} adress'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to addresses
                    },
                  ),
/*              ListTile(
                leading: Icon(Icons.credit_card_outlined),
                title: Text('Moyens de paiement'),
                subtitle: Text('${profile.paymentMethods.length} méthodes'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to payment methods
                },
              ),*/
                  /*ListTile(
                    leading: Icon(Icons.card_giftcard_outlined),
                    title: Text('Codes promo'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to promo codes
                    },
                  ),*/
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.logout),
                    label: Text('Déconnexion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      // Efface le local storage et redirige vers la page de connexion
                      await ref.read(homeProvider.notifier).logout();
                      ref.invalidate(infoUserProvider);
                      await ref.read(authProvider.notifier).logout();
                      ref.invalidate(homeProvider);

                      if (context.mounted) {
                        context.router.replaceAll([const AuthRoute()]);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
