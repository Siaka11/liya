import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liya/modules/share_location_provider.dart';
import 'package:logger/logger.dart';

import '../core/loading_provider.dart';
import '../core/ui/components/custom_button.dart';
import '../core/ui/theme/theme.dart';


@RoutePage()
class ShareLocationPage extends ConsumerStatefulWidget {
  const ShareLocationPage({super.key});

  @override
  ConsumerState<ShareLocationPage> createState() => _ShareLocationPageState();
}

class _ShareLocationPageState extends ConsumerState<ShareLocationPage> {
  GoogleMapController? _mapController;
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();
  bool _showManualInput = false;
  bool _hasLocationPermission = false;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.w('Les services de localisation sont désactivés');
      setState(() {
        _hasLocationPermission = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        logger.w('Les permissions de localisation sont refusées');
        setState(() {
          _hasLocationPermission = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      logger.w('Les permissions de localisation sont refusées de manière permanente');
      setState(() {
        _hasLocationPermission = false;
      });
      return;
    }

    setState(() {
      _hasLocationPermission = true;
    });
    logger.i('Permissions de localisation accordées');
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    logger.i('Carte Google Maps créée');
  }

  void _updateCameraPosition(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(shareLocationProvider);
    final locationNotifier = ref.read(shareLocationProvider.notifier);
    final isLoading = ref.watch(loadingProvider);

    // Mettre à jour la position de la caméra lorsque la position change
    if (locationState.position != null) {
      _updateCameraPosition(locationState.position!);
    }

    return Scaffold(
      body: Stack(
        children: [
          // Carte Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: locationState.position ?? const LatLng(5.3599517, -4.0082563),
              zoom: 15,
            ),
            markers: locationState.position != null
                ? {
              Marker(
                markerId: const MarkerId('current_location'),
                position: locationState.position!,
                draggable: true,
                onDragEnd: (newPosition) {
                  locationNotifier.updatePosition(newPosition);
                },
              ),
            }
                : {},
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: _hasLocationPermission,
            onMapCreated: _onMapCreated,
            onTap: (position) {
              locationNotifier.updatePosition(position);
            },
          ),
          // Bouton pour afficher/masquer le formulaire manuel (déplacé pour ne pas masquer l'icône de localisation)
          Positioned(
            top: 50,
            left: 10, // Déplacé à gauche pour éviter de masquer l'icône de localisation
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showManualInput = !_showManualInput;
                });
              },
              child: Icon(_showManualInput ? Icons.close : Icons.edit_location),
            ),
          ),
          // Formulaire pour entrer manuellement les coordonnées
          if (_showManualInput)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white.withOpacity(0.9),
                child: Column(
                  children: [
                    TextField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          final latitude = double.parse(_latitudeController.text);
                          final longitude = double.parse(_longitudeController.text);
                          if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Coordonnées invalides. Latitude doit être entre -90 et 90, longitude entre -180 et 180.'),
                              ),
                            );
                            return;
                          }
                          locationNotifier.updatePosition(LatLng(latitude, longitude));
                          setState(() {
                            _showManualInput = false;
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez entrer des coordonnées valides.'),
                            ),
                          );
                        }
                      },
                      child: const Text('Mettre à jour'),
                    ),
                  ],
                ),
              ),
            ),
          // Superposition
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PARTAGEZ VOTRE POSITION",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          locationState.status == LocationStatus.Success
                              ? 'Votre position : ${locationState.address}'
                              : locationState.status == LocationStatus.Error
                              ? locationState.errorText
                              : 'Récupération de la position...',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => locationNotifier.cancel(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: UIColors.grey),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Annuler",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      CustomButton(
                        text: "Confirmer",
                        borderRadius: 30,
                        onPressedButton: isLoading || locationState.position == null
                            ? null
                            : () => locationNotifier.confirm(context),
                        bgColor: UIColors.defaultColor,
                        fontSize: 16,
                        paddingVertical: 15,
                        width: 50,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
