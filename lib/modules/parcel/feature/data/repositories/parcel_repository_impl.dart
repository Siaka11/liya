import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/services/notification_service.dart';
import '../datasources/parcel_remote_data_source.dart';
import '../models/parcel_model.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/repositories/parcel_repository.dart';

class ParcelRepositoryImpl implements ParcelRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final ParcelRemoteDataSource remoteDataSource;
  ParcelRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<Parcel>> getParcels() {
    return remoteDataSource.getParcels();
  }

  @override
  Future<void> addParcel(Parcel parcel) async {
    try {
      final parcelModel = ParcelModel(
        id: parcel.id,
        senderName: parcel.expediteurNom ?? 'Expéditeur',
        receiverName: parcel.destinataireNom ?? 'Destinataire',
        phoneNumber: parcel.phoneNumber,
        status: parcel.status,
        prix: parcel.prix,
        createdAt: parcel.createdAt,
        expediteurNom: parcel.expediteurNom,
        expediteurLieu: parcel.expediteurLieu,
        destinataireNom: parcel.destinataireNom,
        destinataireLieu: parcel.destinataireLieu,
        descriptionColis: parcel.descriptionColis,
        typeProduit: parcel.typeProduit,
        colisDescription: parcel.colisDescription,
        colisList: parcel.colisList,
      );

      await _firestore
          .collection('parcels')
          .doc(parcel.id)
          .set(parcelModel.toMap());

      print('✅ Colis ${parcel.id} créé avec succès');

      // Envoyer la notification aux admins
      await _notificationService.notifyNewParcelToAdmin(
        parcelId: parcel.id,
        senderName: parcel.expediteurNom ?? 'Client',
        total: parcel.prix ?? 0.0,
      );

      print('📱 Notification nouveau colis envoyée aux admins');
    } catch (e) {
      print('❌ Erreur lors de la création du colis: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateParcelStatus(String parcelId, String status,
      {double? prix}) async {
    await remoteDataSource.updateParcelStatus(parcelId, status, prix: prix);
  }
}
