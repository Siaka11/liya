
import 'package:liya/modules/home/domain/repositories/home_repository.dart';

import 'package:liya/modules/home/domain/entities/home_option.dart';

class GetHomeOptions {
  final HomeRepository homeRepository;

  GetHomeOptions(this.homeRepository);

  Future<List<HomeOption>> call() async {
    return await homeRepository.getHomeOptions();
  }

}