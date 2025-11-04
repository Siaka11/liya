import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:liya/core/ui/components/admin_menu_card.dart';
import 'package:liya/core/services/data_initializer.dart';

@RoutePage()
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: const Color(0xFFF24E1E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section des métriques
            /*Row(
              children: [
                Expanded(
                  child: AdminMenuCard(
                    title: 'Initialiser Popularité',
                    subtitle: 'Configurer les données de popularité',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                    onTap: () => _initializePopularitySystem(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminMenuCard(
                    title: 'Gestion des Utilisateurs',
                    subtitle: 'Gérer les comptes utilisateurs',
                    icon: Icons.people,
                    color: Colors.pink,
                    onTap: () {
                      AutoRouter.of(context).push(const UserManagementRoute());
                    },
                  ),
                ),
              ],
            ),*/

            const SizedBox(height: 32),

            // Section Gestion des Livraisons
            _buildSectionHeader('🚚 Gestion des Livraisons', Colors.orange),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                /*AdminMenuCard(
                  title: 'Livreurs',
                  subtitle: 'Gérer les livreurs',
                  icon: Icons.delivery_dining,
                  color: Colors.teal,
                  onTap: () {
                    AutoRouter.of(context)
                        .push(const DeliveryUserManagementRoute());
                  },
                ),*/
                AdminMenuCard(
                  title: 'Commandes',
                  subtitle: 'Suivre les commandes',
                  icon: Icons.assignment,
                  color: Colors.blue,
                  onTap: () {
                    AutoRouter.of(context).push(const OrderManagementRoute());
                  },
                ),
                AdminMenuCard(
                  title: 'Assignations',
                  subtitle: 'Assigner les livraisons',
                  icon: Icons.people,
                  color: Colors.lightBlue,
                  onTap: () {
                    AutoRouter.of(context)
                        .push(const AssignmentManagementRoute());
                  },
                ),
                AdminMenuCard(
                  title: 'Statistiques',
                  subtitle: 'Voir les statistiques',
                  icon: Icons.bar_chart,
                  color: Colors.yellow,
                  onTap: () {
                    AutoRouter.of(context).push(const StatisticsRoute());
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section Gestion des Restaurants
            _buildSectionHeader('🍽️ Gestion des Restaurants', Colors.orange),
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
                  icon: Icons.restaurant_menu,
                  color: Colors.green,
                  onTap: () {
                    AutoRouter.of(context).push(const DishManagementRoute());
                  },
                ),
               /* AdminMenuCard(
                  title: 'Promotions',
                  subtitle: 'Gérer les promotions',
                  icon: Icons.local_offer,
                  color: Colors.orange,
                  onTap: () {
                    AutoRouter.of(context)
                        .push(const PromotionManagementRoute());
                  },
                ),*/
                AdminMenuCard(
                  title: 'Catégories',
                  subtitle: 'Gérer les catégories',
                  icon: Icons.category,
                  color: Colors.blue,
                  onTap: () {
                    AutoRouter.of(context)
                        .push(const CategoryManagementRoute());
                  },
                ),
                /*AdminMenuCard(
                  title: 'Images',
                  subtitle: 'Éditer les images',
                  icon: Icons.image,
                  color: Colors.purple,
                  onTap: () {
                    AutoRouter.of(context).push(const ImageManagementRoute());
                  },
                ),*/
              ],
            ),

            const SizedBox(height: 32),

            // Section Gestion des Utilisateurs
            _buildSectionHeader('👥 Gestion des Utilisateurs', Colors.orange),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                AdminMenuCard(
                  title: 'Utilisateurs',
                  subtitle: 'Gérer les clients',
                  icon: Icons.people,
                  color: Colors.pink,
                  onTap: () {
                    AutoRouter.of(context).push(const UserManagementRoute());
                  },
                ),
/*                AdminMenuCard(
                  title: 'Profils',
                  subtitle: 'Gérer les profils',
                  icon: Icons.person,
                  color: Colors.purple,
                  onTap: () {
                    AutoRouter.of(context).push(const UserManagementRoute());
                  },
                ),
                AdminMenuCard(
                  title: 'Rôles',
                  subtitle: 'Gérer les rôles',
                  icon: Icons.security,
                  color: Colors.red,
                  onTap: () {
                    AutoRouter.of(context)
                        .push(const RolePermissionManagementRoute());
                  },
                ),
                AdminMenuCard(
                  title: 'Permissions',
                  subtitle: 'Gérer les permissions',
                  icon: Icons.lock,
                  color: Colors.brown,
                  onTap: () {
                    AutoRouter.of(context)
                        .push(const RolePermissionManagementRoute());
                  },
                ),*/
              ],
            ),

            const SizedBox(height: 32),

            // Section Système et Configuration
/*            _buildSectionHeader('⚙️ Système et Configuration', Colors.orange),
            const SizedBox(height: 16),
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
                    // TODO: Implémenter la page de paramètres
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Logs',
                  subtitle: 'Voir les logs système',
                  icon: Icons.list_alt,
                  color: Colors.grey,
                  onTap: () {
                    // TODO: Implémenter la page de logs
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Sauvegarde',
                  subtitle: 'Sauvegarder les données',
                  icon: Icons.backup,
                  color: Colors.green,
                  onTap: () {
                    // TODO: Implémenter la fonctionnalité de sauvegarde
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
                    // TODO: Implémenter le mode maintenance
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
              ],
            ),*/

            const SizedBox(height: 32),

            // Section Rapports et Analytics
            /*_buildSectionHeader('📊 Rapports et Analytics', Colors.orange),
            const SizedBox(height: 16),
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
                    AutoRouter.of(context).push(const StatisticsRoute());
                  },
                ),
                AdminMenuCard(
                  title: 'Performance',
                  subtitle: 'Performance des livreurs',
                  icon: Icons.speed,
                  color: Colors.blue,
                  onTap: () {
                    AutoRouter.of(context).push(const StatisticsRoute());
                  },
                ),
                AdminMenuCard(
                  title: 'Satisfaction',
                  subtitle: 'Avis et évaluations',
                  icon: Icons.star,
                  color: Colors.yellow,
                  onTap: () {
                    // TODO: Implémenter la page de satisfaction
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                AdminMenuCard(
                  title: 'Export',
                  subtitle: 'Exporter les données',
                  icon: Icons.download,
                  color: Colors.red,
                  onTap: () {
                    // TODO: Implémenter l'export de données
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
              ],
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Initialise le système de popularité
  Future<void> _initializePopularitySystem(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Initialisation du système de popularité...'),
          ],
        ),
      ),
    );

    try {
      await DataInitializer.initializePopularitySystem();

      Navigator.of(context).pop(); // Fermer le dialog de chargement

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Système de popularité initialisé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      // Afficher les statistiques
      await DataInitializer.showPopularityStats();
    } catch (e) {
      Navigator.of(context).pop(); // Fermer le dialog de chargement

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'initialisation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
