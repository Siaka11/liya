import '../repositories/parcel_repository.dart';

class UpdateParcelStatus {
  final ParcelRepository repository;
  UpdateParcelStatus(this.repository);

  Future<void> call(String parcelId, String status, {double? prix}) {
    return repository.updateParcelStatus(parcelId, status, prix: prix);
  }
}
