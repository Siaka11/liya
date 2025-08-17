import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../../../../../core/local_storage_factory.dart';
import '../../../../../../core/singletons.dart';
import '../../../../../../core/services/location_permission_service.dart';

class DeliveryAddressPage extends ConsumerStatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const DeliveryAddressPage({
    Key? key,
    this.initialLocation,
    this.initialAddress,
  }) : super(key: key);

  @override
  ConsumerState<DeliveryAddressPage> createState() =>
      _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends ConsumerState<DeliveryAddressPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;
  Set<Marker> _markers = {};
  TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Utiliser la position initiale ou la position actuelle
      if (widget.initialLocation != null) {
        _selectedLocation = widget.initialLocation;
        _selectedAddress = widget.initialAddress ?? '';
      } else {
        // Utiliser le nouveau service de permissions
        final hasPermission = await LocationPermissionService.requestLocationPermission();
        if (hasPermission) {
          // Obtenir la position actuelle avec le nouveau service
          final position = await LocationPermissionService.getCurrentPosition();
          if (position != null) {
            _selectedLocation = LatLng(position.latitude, position.longitude);
            // Obtenir l'adresse
            await _getAddressFromCoordinates(_selectedLocation!);
          } else {
            // Position par défaut si échec
            _selectedLocation = const LatLng(5.3600, -4.0083);
            _selectedAddress = 'Abidjan, Côte d\'Ivoire';
          }
        } else {
          // Position par défaut si pas de permission
          _selectedLocation = const LatLng(5.3600, -4.0083);
          _selectedAddress = 'Abidjan, Côte d\'Ivoire';
        }
      }

      _updateMarkers();
      _addressController.text = _selectedAddress;
    } catch (e) {
      print('❌ Erreur initialisation: $e');
      // Position par défaut (Abidjan)
      _selectedLocation = const LatLng(5.3600, -4.0083);
      _selectedAddress = 'Abidjan, Côte d\'Ivoire';
      _updateMarkers();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    try {
      print('🌍 Géocodage pour: ${location.latitude}, ${location.longitude}');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final addressParts = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((element) => element != null && element.isNotEmpty).toList();

        _selectedAddress = addressParts.join(', ');

        print('✅ Adresse trouvée: $_selectedAddress');
      } else {
        _selectedAddress = 'Adresse non disponible';
        print('⚠️ Aucune adresse trouvée');
      }
    } catch (e) {
      print('❌ Erreur géocodage: $e');
      _selectedAddress = 'Adresse non disponible';
    }
  }

  void _updateMarkers() {
    if (_selectedLocation == null) return;

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _selectedLocation!,
        draggable: true,
        onDragEnd: (newPosition) {
          _selectedLocation = newPosition;
          _getAddressFromCoordinates(newPosition).then((_) {
            _addressController.text = _selectedAddress;
            setState(() {});
          });
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Adresse de livraison',
          snippet: _selectedAddress,
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _saveAddressToFirestore() async {
    if (_selectedLocation == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer les détails utilisateur
      final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
      final userDetails = userDetailsJson is String
          ? jsonDecode(userDetailsJson)
          : userDetailsJson;

      // Vérifier que userDetails est une Map
      if (userDetails is! Map<String, dynamic>) {
        throw 'Format de données utilisateur invalide';
      }

      final phoneNumber = userDetails['phoneNumber']?.toString() ?? '';

      if (phoneNumber.isEmpty) {
        throw 'Numéro de téléphone non trouvé';
      }

      print('📱 Sauvegarde pour le numéro: $phoneNumber');
      print(
          '📍 Coordonnées: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}');
      print('🏠 Adresse: $_selectedAddress');

      // Sauvegarder dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .update({
        'delivery_address': _selectedAddress,
        'delivery_latitude': _selectedLocation!.latitude,
        'delivery_longitude': _selectedLocation!.longitude,
        'updated_at': FieldValue.serverTimestamp(),
      });

      print('✅ Sauvegarde Firestore réussie');

      // Sauvegarder localement aussi
      await LocalStorageFactory().setUserLocation(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        address: _selectedAddress,
      );

      print('✅ Sauvegarde locale réussie');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Adresse sauvegardée !'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop({
        'address': _selectedAddress,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      });
    } catch (e) {
      print('❌ Erreur sauvegarde: $e');
      print('❌ Type d\'erreur: ${e.runtimeType}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Centrer sur la position actuelle
  Future<void> _centerOnCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Utiliser le nouveau service de permissions
      final hasPermission =
          await LocationPermissionService.requestLocationPermission();
      if (!hasPermission) {
        // Afficher un dialogue pour demander à l'utilisateur d'ouvrir les paramètres
        final shouldOpenSettings = await _showLocationPermissionDialog();
        if (shouldOpenSettings) {
          await LocationPermissionService.openAppSettings();
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtenir la position actuelle avec le nouveau service
      final position = await LocationPermissionService.getCurrentPosition();

      if (position == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'obtenir votre position actuelle'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = newLocation;
        _isLoading = false;
      });

      // Obtenir l'adresse
      await _getAddressFromCoordinates(newLocation);
      _addressController.text = _selectedAddress;
      _updateMarkers();

      // Animer la carte vers la nouvelle position
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newLocation,
              zoom: 16.0,
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur récupération position: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: Impossible d\'obtenir votre position'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carte Google Maps
          _isLoading || _selectedLocation == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Chargement de la carte...'),
                    ],
                  ),
                )
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 16.0,
                  ),
                  markers: _markers,
                  onTap: (LatLng location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                    _getAddressFromCoordinates(location).then((_) {
                      _addressController.text = _selectedAddress;
                      _updateMarkers();
                    });
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),

          // Bouton retour
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),

          // Bouton de localisation personnalisé
          Positioned(
            top: 120,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _centerOnCurrentLocation,
                icon: Icon(Icons.my_location),
                tooltip: 'Ma position actuelle',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),

          // Carte d'adresse en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicateur de glissement
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Titre
                    Text(
                      'Où devons-nous livrer ?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Adresse actuelle
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adresse de livraison',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _selectedAddress,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.edit,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Instructions
                    /*Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      */ /*child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
*/ /**/ /*                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Appuyez sur la carte pour changer l\'adresse ou déplacez le marqueur rouge',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),*/ /**/ /*
                        ],
                      ),*/ /*
                    ),*/
                    SizedBox(height: 20),

                    // Bouton de sauvegarde
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAddressToFirestore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Sauvegarde...'),
                                ],
                              )
                            : Text(
                                'Confirmer cette adresse',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialogue pour demander à l'utilisateur d'ouvrir les paramètres
  Future<bool> _showLocationPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permission de localisation requise'),
              content: const Text(
                'Pour utiliser votre position actuelle, nous avons besoin de votre permission de localisation. '
                'Voulez-vous ouvrir les paramètres de l\'application ?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Ouvrir les paramètres'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
