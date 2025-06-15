import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/usecases/add_parcel.dart';
import '../../domain/usecases/update_parcel_status.dart';
import '../../data/repositories/parcel_repository_impl.dart';
import '../../data/datasources/parcel_remote_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final parcelActionProvider = Provider<_ParcelActionService>((ref) {
  final repository = ParcelRepositoryImpl(
    ParcelRemoteDataSource(FirebaseFirestore.instance),
  );
  return _ParcelActionService(
    addParcel: AddParcel(repository),
    updateParcelStatus: UpdateParcelStatus(repository),
  );
});

class _ParcelActionService {
  final AddParcel addParcel;
  final UpdateParcelStatus updateParcelStatus;
  _ParcelActionService(
      {required this.addParcel, required this.updateParcelStatus});
}
