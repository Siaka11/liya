import '../../domain/entities/parcel.dart';
import '../../domain/repositories/parcel_repository.dart';
import '../datasources/parcel_remote_data_source.dart';
import '../models/parcel_model.dart';

class ParcelRepositoryImpl implements ParcelRepository {
  final ParcelRemoteDataSource remoteDataSource;
  ParcelRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<Parcel>> getParcels() {
    return remoteDataSource.getParcels();
  }

  @override
  Future<void> addParcel(Parcel parcel) async {
    await remoteDataSource.addParcel(ParcelModel(
      id: parcel.id,
      senderName: parcel.senderName,
      receiverName: parcel.receiverName,
      status: parcel.status,
      createdAt: parcel.createdAt,
      address: parcel.address,
      phone: parcel.phone,
      phoneNumber: parcel.phoneNumber,
      instructions: parcel.instructions,
      ville: parcel.ville,
    ));
  }

  @override
  Future<void> updateParcelStatus(String parcelId, String status,
      {double? prix}) async {
    await remoteDataSource.updateParcelStatus(parcelId, status, prix: prix);
  }
}
