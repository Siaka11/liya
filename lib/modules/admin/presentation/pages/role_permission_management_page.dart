import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@RoutePage()
class RolePermissionManagementPage extends StatefulWidget {
  const RolePermissionManagementPage({Key? key}) : super(key: key);

  @override
  State<RolePermissionManagementPage> createState() =>
      _RolePermissionManagementPageState();
}

class _RolePermissionManagementPageState
    extends State<RolePermissionManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _permissions = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _selectedRole = 'Tous';

  // Permissions disponibles
  final List<String> _availablePermissions = [
    'read_orders',
    'write_orders',
    'delete_orders',
    'read_parcels',
    'write_parcels',
    'delete_parcels',
    'read_users',
    'write_users',
    'delete_users',
    'read_restaurants',
    'write_restaurants',
    'delete_restaurants',
    'read_dishes',
    'write_dishes',
    'delete_dishes',
    'read_categories',
    'write_categories',
    'delete_categories',
    'read_reports',
    'write_reports',
    'read_settings',
    'write_settings',
    'admin_access',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Charger les rôles
      final rolesSnapshot = await _firestore.collection('roles').get();
      final roles = rolesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
          'permissions': List<String>.from(data['permissions'] ?? []),
          'isActive': data['isActive'] ?? true,
          'createdAt': data['createdAt'],
        };
      }).toList();

      // Charger les permissions
      final permissionsSnapshot =
          await _firestore.collection('permissions').get();
      final permissions = permissionsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
          'category': data['category'] ?? '',
          'isActive': data['isActive'] ?? true,
        };
      }).toList();

      // Charger les utilisateurs
      final usersSnapshot = await _firestore.collection('users').get();
      final users = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'phoneNumber': data['phoneNumber'] ?? '',
          'role': data['role'] ?? 'client',
          'isActive': data['isActive'] ?? true,
          'permissions': List<String>.from(data['permissions'] ?? []),
        };
      }).toList();

      setState(() {
        _roles = roles;
        _permissions = permissions;
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des rôles et permissions: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_selectedRole == 'Tous') return _users;
    return _users
        .where((user) => user['role'] == _selectedRole.toLowerCase())
        .toList();
  }

  Future<void> _addRole() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final selectedPermissions = <String>{};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter un rôle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du rôle',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Permissions:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._availablePermissions.map((permission) => CheckboxListTile(
                      title: Text(permission),
                      value: selectedPermissions.contains(permission),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedPermissions.add(permission);
                          } else {
                            selectedPermissions.remove(permission);
                          }
                        });
                      },
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await _saveRole(nameController.text,
                      descriptionController.text, selectedPermissions.toList());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveRole(
      String name, String description, List<String> permissions) async {
    try {
      await _firestore.collection('roles').add({
        'name': name,
        'description': description,
        'permissions': permissions,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rôle ajouté avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _editUserRole(Map<String, dynamic> user) async {
    final selectedRole = user['role'];
    final selectedPermissions = <String>{...user['permissions']};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Modifier le rôle de ${user['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    border: OutlineInputBorder(),
                  ),
                  items: ['client', 'delivery', 'admin'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      // Mettre à jour les permissions par défaut selon le rôle
                      selectedPermissions.clear();
                      if (value == 'admin') {
                        selectedPermissions.addAll(_availablePermissions);
                      } else if (value == 'delivery') {
                        selectedPermissions.addAll([
                          'read_orders',
                          'read_parcels',
                          'read_users',
                        ]);
                      } else {
                        selectedPermissions.addAll([
                          'read_orders',
                          'read_parcels',
                        ]);
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Permissions:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._availablePermissions.map((permission) => CheckboxListTile(
                      title: Text(permission),
                      value: selectedPermissions.contains(permission),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedPermissions.add(permission);
                          } else {
                            selectedPermissions.remove(permission);
                          }
                        });
                      },
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateUserRole(
                    user['id'], selectedRole, selectedPermissions.toList());
                Navigator.of(context).pop();
              },
              child: const Text('Mettre à jour'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserRole(
      String userId, String role, List<String> permissions) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'permissions': permissions,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rôle mis à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rôles et Permissions'),
          backgroundColor: const Color(0xFFF24E1E),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Rôles'),
              Tab(text: 'Utilisateurs'),
              Tab(text: 'Permissions'),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildRolesTab(),
                  _buildUsersTab(),
                  _buildPermissionsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildRolesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Rôles définis:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addRole,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un rôle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF24E1E),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _roles.length,
            itemBuilder: (context, index) {
              final role = _roles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(role['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role['description']),
                      const SizedBox(height: 4),
                      Text(
                        'Permissions: ${role['permissions'].length}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: role['isActive']
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role['isActive'] ? 'Actif' : 'Inactif',
                      style: TextStyle(
                        fontSize: 12,
                        color: role['isActive'] ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Filtrer par rôle: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedRole,
                items: ['Tous', 'Client', 'Delivery', 'Admin'].map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(user['role']),
                    child: Text(
                      user['name'][0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['phoneNumber']),
                      Text(
                        'Rôle: ${user['role'].toUpperCase()}',
                        style: TextStyle(
                          color: _getRoleColor(user['role']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _editUserRole(user),
                    icon: const Icon(Icons.edit),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availablePermissions.length,
      itemBuilder: (context, index) {
        final permission = _availablePermissions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.security),
            title: Text(permission),
            subtitle: Text(_getPermissionDescription(permission)),
          ),
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'delivery':
        return Colors.blue;
      case 'client':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPermissionDescription(String permission) {
    switch (permission) {
      case 'read_orders':
        return 'Lire les commandes';
      case 'write_orders':
        return 'Modifier les commandes';
      case 'delete_orders':
        return 'Supprimer les commandes';
      case 'read_parcels':
        return 'Lire les colis';
      case 'write_parcels':
        return 'Modifier les colis';
      case 'delete_parcels':
        return 'Supprimer les colis';
      case 'read_users':
        return 'Lire les utilisateurs';
      case 'write_users':
        return 'Modifier les utilisateurs';
      case 'delete_users':
        return 'Supprimer les utilisateurs';
      case 'read_restaurants':
        return 'Lire les restaurants';
      case 'write_restaurants':
        return 'Modifier les restaurants';
      case 'delete_restaurants':
        return 'Supprimer les restaurants';
      case 'read_dishes':
        return 'Lire les plats';
      case 'write_dishes':
        return 'Modifier les plats';
      case 'delete_dishes':
        return 'Supprimer les plats';
      case 'read_categories':
        return 'Lire les catégories';
      case 'write_categories':
        return 'Modifier les catégories';
      case 'delete_categories':
        return 'Supprimer les catégories';
      case 'read_reports':
        return 'Lire les rapports';
      case 'write_reports':
        return 'Modifier les rapports';
      case 'read_settings':
        return 'Lire les paramètres';
      case 'write_settings':
        return 'Modifier les paramètres';
      case 'admin_access':
        return 'Accès administrateur complet';
      default:
        return 'Permission non définie';
    }
  }
}
