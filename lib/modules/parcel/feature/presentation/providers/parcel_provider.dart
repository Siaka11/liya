import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/usecases/get_parcels.dart';
import '../../data/repositories/parcel_repository_impl.dart';
import '../../data/datasources/parcel_remote_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final parcelProvider = StreamProvider<List<Parcel>>((ref) {
  final repository = ParcelRepositoryImpl(
    ParcelRemoteDataSource(FirebaseFirestore.instance),
  );
  return GetParcels(repository)();
});
