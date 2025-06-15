import 'package:liya/modules/home/domain/entities/home_option.dart';

abstract class HomeRepository {
  Future<List<HomeOption>> getHomeOptions();
}