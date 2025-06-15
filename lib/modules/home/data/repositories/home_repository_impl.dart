

import 'package:liya/modules/home/domain/entities/home_option.dart';
import 'package:liya/modules/home/domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource homeLocalDataSource;

  HomeRepositoryImpl(this.homeLocalDataSource);

  @override
  Future<List<HomeOption>> getHomeOptions() async{
    return await homeLocalDataSource.getHomeOptions();
  }


}