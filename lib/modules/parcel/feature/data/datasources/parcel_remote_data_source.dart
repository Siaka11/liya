import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parcel_model.dart';

class ParcelRemoteDataSource {
  final FirebaseFirestore firestore;
  ParcelRemoteDataSource(this.firestore);

  Stream<List<ParcelModel>> getParcels() {
    return firestore
        .collection('parcels')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ParcelModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addParcel(ParcelModel parcel) async {
    await firestore.collection('parcels').doc(parcel.id).set(parcel.toMap());
  }

  Future<void> updateParcelStatus(String parcelId, String status,
      {double? prix}) async {
    final updateData = <String, dynamic>{'status': status};
    if (prix != null) {
      updateData['prix'] = prix;
    }
    await firestore.collection('parcels').doc(parcelId).update(updateData);
  }
}
