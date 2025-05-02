import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:liya/core/singletons.dart';
import 'package:liya/modules/auth/auth_service.dart';
import 'package:liya/routes/app_router.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:logger/logger.dart';
import '../../core/loading_provider.dart';


enum LocationStatus { Empty, Loading, Success, Error }

class ShareLocationState {
  final LatLng? position;
  final String address;
  final LocationStatus status;
  final String errorText;

  const ShareLocationState({
    this.position,
    this.address = '',
    this.status = LocationStatus.Empty,
    this.errorText = '',
  });

  ShareLocationState copyWith({
    LatLng? position,
    String? address,
    LocationStatus? status,
    String? errorText,
  }) {
    return ShareLocationState(
      position: position ?? this.position,
      address: address ?? this.address,
      status: status ?? this.status,
      errorText: errorText ?? this.errorText,
    );
  }
}

class ShareLocationNotifier extends StateNotifier<ShareLocationState> {
  final Ref ref;
  final logger = Logger();

  ShareLocationNotifier(this.ref) : super(const ShareLocationState()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    state = state.copyWith(status: LocationStatus.Loading);
    ref.read(loadingProvider.notifier).start();
    logger.i('Début de la récupération de la localisation');

    try {
      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w('Les services de localisation sont désactivés');
        throw Exception('Les services de localisation sont désactivés. Veuillez les activer.');
      }

      // Vérifier et demander les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        logger.i('Demande de permission de localisation');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          logger.w('Les permissions de localisation sont refusées');
          throw Exception('Les permissions de localisation sont refusées.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        logger.w('Les permissions de localisation sont refusées de manière permanente');
        throw Exception(
            'Les permissions de localisation sont refusées de manière permanente. Veuillez modifier les paramètres.');
      }

      // Vérifier la précision de la localisation (optionnel, mais utile pour Android)
      if (Platform.isAndroid) {
        LocationAccuracyStatus accuracy = await Geolocator.getLocationAccuracy();
        if (accuracy == LocationAccuracyStatus.reduced) {
          logger.w('La précision de la localisation est réduite');
        }
      }

      // Récupérer la position
      logger.i('Récupération de la position actuelle...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Délai dépassé lors de la récupération de la position.');
      });

      LatLng latLng = LatLng(position.latitude, position.longitude);
      logger.i('Position récupérée : ${latLng.latitude}, ${latLng.longitude}');

      // Convertir en adresse
      await _updateAddressForPosition(latLng);
    } catch (e) {
      logger.e('Erreur lors de la récupération de la localisation', error: e);
      state = state.copyWith(
        status: LocationStatus.Error,
        errorText: e.toString(),
      );
    } finally {
      ref.read(loadingProvider.notifier).complete();
      logger.i('Fin de la récupération de la localisation');
    }
  }

  Future<void> _updateAddressForPosition(LatLng position) async {
    try {
      logger.i('Conversion des coordonnées en adresse...');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Délai dépassé lors de la conversion en adresse.');
      });

      String address = placemarks.isNotEmpty
          ? '${placemarks.first.subLocality ?? ''} ${placemarks.first.locality ?? ''}'.trim()
          : 'Adresse inconnue';
      if (address.isEmpty) address = 'Adresse inconnue';
      logger.i('Adresse récupérée : $address');

      state = state.copyWith(
        position: position,
        address: address,
        status: LocationStatus.Success,
        errorText: '',
      );
    } catch (e) {
      logger.e('Erreur lors de la conversion en adresse', error: e);
      state = state.copyWith(
        status: LocationStatus.Error,
        errorText: e.toString(),
      );
    }
  }

  Future<void> updatePosition(LatLng newPosition) async {
    state = state.copyWith(status: LocationStatus.Loading);
    ref.read(loadingProvider.notifier).start();
    logger.i('Mise à jour de la position : ${newPosition.latitude}, ${newPosition.longitude}');

    try {
      await _updateAddressForPosition(newPosition);
    } finally {
      ref.read(loadingProvider.notifier).complete();
      logger.i('Fin de la mise à jour de la position');
    }
  }

  Future<void> confirm(BuildContext context) async {
    if (state.position == null) {
      state = state.copyWith(
        status: LocationStatus.Error,
        errorText: 'Position non disponible.',
      );
      logger.w('Position non disponible lors de la confirmation');
      return;
    }

    ref.read(loadingProvider.notifier).start();
    logger.i('Début de la confirmation de la localisation');
    try {
      await AuthService().saveUserLocation(
        latitude: state.position!.latitude,
        longitude: state.position!.longitude,
        address: state.address,
        onSuccess: () {
          logger.i('Localisation sauvegardée avec succès');
          singleton<AppRouter>().replace(const HomeRoute());
        },
        onError: (error) {
          logger.e('Erreur lors de la sauvegarde de la localisation', error: error);
          state = state.copyWith(
            status: LocationStatus.Error,
            errorText: error,
          );
        },
      );
    } catch (e) {
      logger.e('Erreur lors de la confirmation', error: e);
      state = state.copyWith(
        status: LocationStatus.Error,
        errorText: e.toString(),
      );
    } finally {
      ref.read(loadingProvider.notifier).complete();
      logger.i('Fin de la confirmation de la localisation');
    }
  }

  void cancel(BuildContext context) {
    logger.i('Annulation de la partage de localisation');
    context.router.pop();
  }
}

final shareLocationProvider = StateNotifierProvider<ShareLocationNotifier, ShareLocationState>(
      (ref) => ShareLocationNotifier(ref),
);