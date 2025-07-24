import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/theme/theme.dart';
import '../../../../routes/app_router.gr.dart';
import '../widgets/admin_menu_card.dart';

@RoutePage()
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: const Text(
          'Administration',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // TODO: Notifications admin
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statistiques rapides
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF24E1E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tableau de bord',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Gestion complète de la plateforme',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Gestion des Restaurants
            const Text(
              '🍽️ Gestion des Restaurants',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF24E1E),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                AdminMenuCard(
                  title: 'Restaurants',
                  subtitle: 'Gérer les restaurants',
                  icon: Icons.restaurant,
                  color: Colors.orange,
                  onTap: () {
                    AutoRouter.of(context)
                        .push(const RestaurantManagementRoute());
                  },
                ),
                AdminMenuCard(
                  title: 'Plats',
                  subtitle: 'Gérer les plats',
                  icon: Icons.fastfood,
                  color: Colors.green,
                  onTap: () {
                    AutoRouter.of(context).push(const DishManagementRoute());
                  },
                ),
                AdminMenuCard(
                  title: 'Catégories',
                  subtitle: 'Gérer les catégories',
                  icon: Icons.category,
                  color: Colors.blue,
                  onTap: () {
                    // TODO: Navigation vers gestion catégories
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Images',
                  subtitle: 'Éditer les images',
                  icon: Icons.image,
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Navigation vers éditeur d'images
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section Gestion des Livraisons
            const Text(
              '🚚 Gestion des Livraisons',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF24E1E),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                AdminMenuCard(
                  title: 'Livreurs',
                  subtitle: 'Gérer les livreurs',
                  icon: Icons.delivery_dining,
                  color: Colors.teal,
                  onTap: () {
                    AutoRouter.of(context)
                        .push(const DeliveryUserManagementRoute());
                  },
                ),
                AdminMenuCard(
                  title: 'Commandes',
                  subtitle: 'Suivre les commandes',
                  icon: Icons.assignment,
                  color: Colors.indigo,
                  onTap: () {
                    // TODO: Navigation vers suivi commandes
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                //HomeDeliveryPage
                AdminMenuCard(
                  title: 'Assignations',
                  subtitle: 'Assigner les livraisons',
                  icon: Icons.people,
                  color: Colors.cyan,
                  onTap: () {
                    AutoRouter.of(context)
                        .push(const DeliveryAdminDashboardRoute());
                  },
                ),
                AdminMenuCard(
                  title: 'Statistiques',
                  subtitle: 'Voir les statistiques',
                  icon: Icons.analytics,
                  color: Colors.amber,
                  onTap: () {
                    // TODO: Navigation vers statistiques
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section Gestion des Utilisateurs
            const Text(
              '👥 Gestion des Utilisateurs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF24E1E),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                AdminMenuCard(
                  title: 'Clients',
                  subtitle: 'Gérer les clients',
                  icon: Icons.people_outline,
                  color: Colors.pink,
                  onTap: () {
                    // TODO: Navigation vers gestion clients
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Profils',
                  subtitle: 'Gérer les profils',
                  icon: Icons.person,
                  color: Colors.deepPurple,
                  onTap: () {
                    // TODO: Navigation vers gestion profils
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Rôles',
                  subtitle: 'Gérer les rôles',
                  icon: Icons.security,
                  color: Colors.red,
                  onTap: () {
                    // TODO: Navigation vers gestion rôles
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Permissions',
                  subtitle: 'Gérer les permissions',
                  icon: Icons.lock,
                  color: Colors.brown,
                  onTap: () {
                    // TODO: Navigation vers gestion permissions
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section Système et Configuration
            const Text(
              '⚙️ Système et Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF24E1E),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                AdminMenuCard(
                  title: 'Paramètres',
                  subtitle: 'Configuration générale',
                  icon: Icons.settings,
                  color: Colors.grey,
                  onTap: () {
                    // TODO: Navigation vers paramètres
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Logs',
                  subtitle: 'Voir les logs système',
                  icon: Icons.list_alt,
                  color: Colors.blueGrey,
                  onTap: () {
                    // TODO: Navigation vers logs
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Sauvegarde',
                  subtitle: 'Sauvegarder les données',
                  icon: Icons.backup,
                  color: Colors.lightGreen,
                  onTap: () {
                    // TODO: Navigation vers sauvegarde
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Maintenance',
                  subtitle: 'Mode maintenance',
                  icon: Icons.build,
                  color: Colors.orange,
                  onTap: () {
                    // TODO: Navigation vers maintenance
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section Rapports et Analytics
            const Text(
              '📊 Rapports et Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF24E1E),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                AdminMenuCard(
                  title: 'Ventes',
                  subtitle: 'Rapport des ventes',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  onTap: () {
                    // TODO: Navigation vers rapport ventes
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Performance',
                  subtitle: 'Performance des livreurs',
                  icon: Icons.speed,
                  color: Colors.lightBlue,
                  onTap: () {
                    // TODO: Navigation vers performance
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Satisfaction',
                  subtitle: 'Avis et évaluations',
                  icon: Icons.star,
                  color: Colors.yellow,
                  onTap: () {
                    // TODO: Navigation vers satisfaction
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Export',
                  subtitle: 'Exporter les données',
                  icon: Icons.file_download,
                  color: Colors.deepOrange,
                  onTap: () {
                    // TODO: Navigation vers export
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
