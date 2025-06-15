import '../entities/parcel.dart';

abstract class ParcelRepository {
  Stream<List<Parcel>> getParcels();
  Future<void> addParcel(Parcel parcel);
  Future<void> updateParcelStatus(String parcelId, String status);
}
