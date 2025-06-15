import '../repositories/parcel_repository.dart';
import '../entities/parcel.dart';

class GetParcels {
  final ParcelRepository repository;
  GetParcels(this.repository);

  Stream<List<Parcel>> call() {
    return repository.getParcels();
  }
}
