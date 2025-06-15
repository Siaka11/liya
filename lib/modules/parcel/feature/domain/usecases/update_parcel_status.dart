import '../repositories/parcel_repository.dart';

class UpdateParcelStatus {
  final ParcelRepository repository;
  UpdateParcelStatus(this.repository);

  Future<void> call(String parcelId, String status) {
    return repository.updateParcelStatus(parcelId, status);
  }
}
