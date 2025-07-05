import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/services/image_upload_service.dart';
import '../../../../routes/app_router.gr.dart';
import 'restaurant_edit_page.dart';

@RoutePage()
class RestaurantManagementPage extends ConsumerStatefulWidget {
  const RestaurantManagementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RestaurantManagementPage> createState() =>
      _RestaurantManagementPageState();
}

class _RestaurantManagementPageState
    extends ConsumerState<RestaurantManagementPage> {
  List<Map<String, dynamic>> restaurants = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedCity = 'all';
  String selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();

      setState(() {
        restaurants = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Nom inconnu',
            'description': data['description'] ?? 'Description inconnue',
            'address': data['address'] ?? 'Adresse inconnue',
            'city': data['city'] ?? 'Ville inconnue',
            'country': data['country'] ?? 'Côte d\'ivoire',
            'phone': data['phone'] ?? 'Téléphone inconnu',
            'email': data['email'] ?? 'Email inconnu',
            'latitude': data['latitude']?.toDouble() ?? 0.0,
            'longitude': data['longitude']?.toDouble() ?? 0.0,
            'openingHours': data['openingHours'] ?? {},
            'coverImage': data['coverImage'] ?? '',
            'isActive': data['isActive'] ?? true,
            'createdAt': data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredRestaurants {
    return restaurants.where((restaurant) {
      final matchesSearch = searchQuery.isEmpty ||
          restaurant['name']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          restaurant['address']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          restaurant['city']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      final matchesCity =
          selectedCity == 'all' || restaurant['city'] == selectedCity;
      final matchesStatus = selectedStatus == 'all' ||
          (selectedStatus == 'active' && restaurant['isActive']) ||
          (selectedStatus == 'inactive' && !restaurant['isActive']);

      return matchesSearch && matchesCity && matchesStatus;
    }).toList();
  }

  List<String> get cities {
    final cities =
        restaurants.map((r) => r['city'].toString()).toSet().toList();
    cities.sort();
    return cities;
  }

  Future<void> _toggleRestaurantStatus(
      String restaurantId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .update({'isActive': !currentStatus});

      await _loadRestaurants();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut du restaurant mis à jour'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteRestaurant(
      String restaurantId, String restaurantName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer le restaurant "$restaurantName" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId)
            .delete();

        await _loadRestaurants();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restaurant supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddEditRestaurantDialog([Map<String, dynamic>? restaurant]) {
    final isEditing = restaurant != null;
    final formKey = GlobalKey<FormState>();

    // Contrôleurs pour le formulaire
    final nameController =
        TextEditingController(text: restaurant?['name'] ?? '');
    final descriptionController =
        TextEditingController(text: restaurant?['description'] ?? '');
    final addressController =
        TextEditingController(text: restaurant?['address'] ?? '');
    final cityController =
        TextEditingController(text: restaurant?['city'] ?? '');
    final phoneController =
        TextEditingController(text: restaurant?['phone'] ?? '');
    final emailController =
        TextEditingController(text: restaurant?['email'] ?? '');
    final latitudeController =
        TextEditingController(text: restaurant?['latitude']?.toString() ?? '');
    final longitudeController =
        TextEditingController(text: restaurant?['longitude']?.toString() ?? '');

    // Horaires d'ouverture
    Map<String, String> openingHours =
        Map<String, String>.from(restaurant?['openingHours'] ??
            {
              'mon': '11:00-22:00',
              'tue': '11:00-22:00',
              'wed': '11:00-22:00',
              'thu': '11:00-22:00',
              'fri': '11:00-23:00',
              'sat': '11:00-23:00',
              'sun': '12:00-21:00',
            });

    String? selectedImagePath;
    String currentImageUrl = restaurant?['coverImage'] ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
              isEditing ? 'Modifier le restaurant' : 'Ajouter un restaurant'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image du restaurant
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            selectedImagePath = image.path;
                            currentImageUrl = '';
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: selectedImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(selectedImagePath!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : currentImageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      currentImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.restaurant,
                                                  size: 50, color: Colors.grey),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo,
                                          size: 50, color: Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Cliquez pour ajouter une image',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nom du restaurant
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du restaurant *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Description
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    // Adresse
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'adresse est requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Ville
                    TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ville *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La ville est requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Téléphone
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Coordonnées GPS
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: latitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: longitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Horaires d'ouverture
                    const Text(
                      'Horaires d\'ouverture',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...openingHours.entries.map((entry) {
                      final day = entry.key;
                      final time = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(_getDayName(day)),
                            ),
                            Expanded(
                              child: TextFormField(
                                initialValue: time,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'ex: 11:00-22:00',
                                ),
                                onChanged: (value) {
                                  openingHours[day] = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final restaurantData = {
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'address': addressController.text,
                      'city': cityController.text,
                      'country': 'Côte d\'ivoire',
                      'phone': phoneController.text,
                      'email': emailController.text,
                      'latitude':
                          double.tryParse(latitudeController.text) ?? 0.0,
                      'longitude':
                          double.tryParse(longitudeController.text) ?? 0.0,
                      'openingHours': openingHours,
                      'isActive': restaurant?['isActive'] ?? true,
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    // Upload image if selected
                    if (selectedImagePath != null) {
                      try {
                        restaurantData['coverImage'] =
                            await ImageUploadService.uploadImage(
                                selectedImagePath!, 'restaurants');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Erreur lors de l\'upload de l\'image: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    } else if (currentImageUrl.isNotEmpty) {
                      restaurantData['coverImage'] = currentImageUrl;
                    }

                    if (isEditing) {
                      await FirebaseFirestore.instance
                          .collection('restaurants')
                          .doc(restaurant!['id'])
                          .update(restaurantData);
                    } else {
                      restaurantData['createdAt'] =
                          FieldValue.serverTimestamp();
                      await FirebaseFirestore.instance
                          .collection('restaurants')
                          .add(restaurantData);
                    }

                    Navigator.of(context).pop();
                    await _loadRestaurants();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing
                            ? 'Restaurant modifié avec succès'
                            : 'Restaurant ajouté avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Modifier' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(String day) {
    switch (day) {
      case 'mon':
        return 'Lundi';
      case 'tue':
        return 'Mardi';
      case 'wed':
        return 'Mercredi';
      case 'thu':
        return 'Jeudi';
      case 'fri':
        return 'Vendredi';
      case 'sat':
        return 'Samedi';
      case 'sun':
        return 'Dimanche';
      default:
        return day;
    }
  }

  void _showRestaurantDetails(Map<String, dynamic> restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de ${restaurant['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (restaurant['coverImage'] != null &&
                  restaurant['coverImage'].isNotEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(restaurant['coverImage']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Nom', restaurant['name']),
              _buildDetailRow('Description', restaurant['description']),
              _buildDetailRow('Adresse', restaurant['address']),
              _buildDetailRow('Ville', restaurant['city']),
              _buildDetailRow('Pays', restaurant['country']),
              _buildDetailRow('Téléphone', restaurant['phone']),
              _buildDetailRow('Email', restaurant['email']),
              _buildDetailRow('Latitude', restaurant['latitude'].toString()),
              _buildDetailRow('Longitude', restaurant['longitude'].toString()),
              _buildDetailRow(
                  'Statut', restaurant['isActive'] ? 'Actif' : 'Inactif'),
              const SizedBox(height: 8),
              const Text('Horaires d\'ouverture:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...(restaurant['openingHours'] as Map<String, dynamic>)
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text('${_getDayName(entry.key)}: ${entry.value}'),
                    ),
                  ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: const Text(
          'Gestion des Restaurants',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF24E1E),
        onPressed: () async {
          final result = await context.router.push(RestaurantEditRoute());
          if (result == true) _loadRestaurants();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredRestaurants.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun restaurant trouvé',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRestaurants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final r = filteredRestaurants[index];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 0.05,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          final result = await context.router
                              .push(RestaurantEditRoute(restaurantId: r['id']));
                          if (result == true) _loadRestaurants();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // IMAGE
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: r['coverImage'] != null &&
                                      r['coverImage'].isNotEmpty
                                  ? Image.network(r['coverImage'],
                                      width: 100, height: 180, fit: BoxFit.cover)
                                  : Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.restaurant,
                                          size: 40, color: Colors.grey),
                                    ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            r['name'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: r['isActive']
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            r['isActive'] ? 'Actif' : 'Inactif',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      r['description'],
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black87),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${r['address']}, ${r['city']}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(r['phone'],
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(r['openingHours']['mon'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Switch(
                                  value: r['isActive'],
                                  onChanged: (v) => _toggleRestaurantStatus(
                                      r['id'], r['isActive']),
                                  activeColor: Colors.green,
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'details') {
                                      _showRestaurantDetails(r);
                                    } else if (value == 'edit') {
                                      context.router.push(RestaurantEditRoute(
                                          restaurantId: r['id']));
                                    } else if (value == 'delete') {
                                      _deleteRestaurant(r['id'], r['name']);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'details',
                                      child: Row(
                                        children: [
                                          Icon(Icons.info, size: 20),
                                          SizedBox(width: 8),
                                          Text('Détails')
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Modifier')
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              size: 20, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Supprimer',
                                              style:
                                                  TextStyle(color: Colors.red))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
