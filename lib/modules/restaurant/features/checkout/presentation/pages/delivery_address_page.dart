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

import 'package:google_places_flutter/model/prediction.dart'; // Pour utiliser Prediction
import 'package:google_places_flutter/google_places_flutter.dart';

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
  final Set<Marker> _markers = {};
  final TextEditingController _addressController = TextEditingController();

  final String googleMapsApiKey = 'AIzaSyAxPHuGGcj4WP9HWzkXoowH0zL4UC7tvIs';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);

    try {
      if (widget.initialLocation != null) {
        _selectedLocation = widget.initialLocation;
        _selectedAddress = widget.initialAddress ?? '';
      } else {
        final hasPermission =
            await LocationPermissionService.requestLocationPermission();

        if (hasPermission) {
          final pos = await LocationPermissionService.getCurrentPosition();
          if (pos != null) {
            _selectedLocation = LatLng(pos.latitude, pos.longitude);
            await _getAddressFromCoordinates(_selectedLocation!);
          }
        }

        // Valeur par défaut si échec
        _selectedLocation ??= const LatLng(5.3600, -4.0083);
        _selectedAddress = _selectedAddress.isNotEmpty
            ? _selectedAddress
            : "Abidjan, Côte d'Ivoire";
      }

      _updateMarkers();
    } catch (e) {
      print('❌ Erreur init location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _selectedAddress = [place.street, place.locality, place.country]
            .where((e) => e != null && e.isNotEmpty)
            .join(', ');
      } else {
        _selectedAddress = "Adresse non disponible";
      }
    } catch (_) {
      _selectedAddress = "Adresse non disponible";
    }
  }

  void _updateMarkers() {
    if (_selectedLocation == null) return;

    _markers
      ..clear()
      ..add(
        Marker(
          markerId: const MarkerId('selected'),
          position: _selectedLocation!,
          draggable: true,
          onDragEnd: (newPos) async {
            _selectedLocation = newPos;
            await _getAddressFromCoordinates(newPos);
            _refreshUI();
          },
        ),
      );

    _refreshUI();
  }

  void _refreshUI() {
    setState(() {
      _addressController.text = _selectedAddress;
    });
  }

  Future<void> _saveAddressToFirestore() async {
    if (_selectedLocation == null) return;

    setState(() => _isLoading = true);

    try {
      final userJson = singleton<LocalStorageFactory>().getUserDetails();
      final userDetails = userJson is String ? jsonDecode(userJson) : userJson;

      if (userDetails is! Map<String, dynamic>) throw "User data invalid";
      final phone = userDetails["phoneNumber"]?.toString() ?? "";
      if (phone.isEmpty) throw "Numéro de téléphone manquant";

      await FirebaseFirestore.instance.collection("users").doc(phone).update({
        "delivery_address": _selectedAddress,
        "delivery_latitude": _selectedLocation!.latitude,
        "delivery_longitude": _selectedLocation!.longitude,
        "updated_at": FieldValue.serverTimestamp(),
      });

      await LocalStorageFactory().setUserLocation(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        address: _selectedAddress,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("✅ Adresse sauvegardée"),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop({
          "address": _selectedAddress,
          "latitude": _selectedLocation!.latitude,
          "longitude": _selectedLocation!.longitude,
        });
      }
    } catch (e) {
      print("❌ Firestore save error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _centerOnCurrentLocation() async {
    final hasPermission =
        await LocationPermissionService.requestLocationPermission();
    if (!hasPermission) {
      final openSettings = await _showLocationPermissionDialog();
      if (openSettings) await LocationPermissionService.openAppSettings();
      return;
    }

    final pos = await LocationPermissionService.getCurrentPosition();
    if (pos == null) return;

    _selectedLocation = LatLng(pos.latitude, pos.longitude);
    await _getAddressFromCoordinates(_selectedLocation!);
    _updateMarkers();

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedLocation!, 16),
    );
  }

  void _onPlaceSelected(Prediction prediction) async {
    try {
      final loc = await locationFromAddress(prediction.description ?? "");
      if (loc.isNotEmpty) {
        _selectedLocation = LatLng(loc.first.latitude, loc.first.longitude);
        _selectedAddress = prediction.description ?? "";
        _updateMarkers();

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 16),
        );
      }
    } catch (e) {
      print("❌ Place select error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading || _selectedLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (c) => _mapController = c,
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 16,
                  ),
                  markers: _markers,
                  onTap: (loc) async {
                    _selectedLocation = loc;
                    await _getAddressFromCoordinates(loc);
                    _updateMarkers();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),

          // Bouton retour
          Positioned(
            top: 50,
            left: 16,
            child:
                _circleButton(Icons.arrow_back, () => Navigator.pop(context)),
          ),

          // Bouton localisation
          Positioned(
            top: 50,
            right: 16,
            child: _circleButton(Icons.my_location, _centerOnCurrentLocation),
          ),

          // Champ recherche
          Positioned(
            top: 120,
            left: 16,
            right: 16,
            child: GooglePlaceAutoCompleteTextField(
              boxDecoration: BoxDecoration(color: Colors.white),
              textEditingController: _addressController,
              googleAPIKey: googleMapsApiKey,
              debounceTime: 800,
              isLatLngRequired: true,
              countries: const ["ci"],
              inputDecoration: InputDecoration(
                hintText: "Rechercher une adresse...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                prefixIcon: const Icon(Icons.search),
              ),
              getPlaceDetailWithLatLng: _onPlaceSelected,
              itemClick: (prediction) {
                _addressController.text = prediction.description ?? "";
                _onPlaceSelected(prediction);
              },
            ),
          ),

          // Bottom sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedAddress,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveAddressToFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Text("Confirmer cette adresse"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: IconButton(onPressed: onTap, icon: Icon(icon)),
    );
  }

  Future<bool> _showLocationPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Permission requise"),
            content: const Text(
                "Activez la localisation pour utiliser cette fonctionnalité."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Annuler")),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Ouvrir les paramètres")),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
