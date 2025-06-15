import '../entities/parcel.dart';
import '../repositories/parcel_repository.dart';

class AddParcel {
  final ParcelRepository repository;
  AddParcel(this.repository);

  Future<void> call(Parcel parcel) {
    return repository.addParcel(parcel);
  }
}
