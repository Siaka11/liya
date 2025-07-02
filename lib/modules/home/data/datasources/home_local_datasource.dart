import 'dart:convert';

import 'package:liya/modules/home/data/models/home_option_model.dart';

import '../../../../core/local_storage_factory.dart';
import '../../../../core/singletons.dart';

abstract class HomeLocalDataSource {
  Future<List<HomeOptionModel>> getHomeOptions();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  late final Map<String, dynamic> userDetails;
  late final String? role;

  HomeLocalDataSourceImpl() {
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    role = userDetails['role'];
    print('Role de l\'utilisateur : $role');
  }



  @override
  Future<List<HomeOptionModel>> getHomeOptions() async {
    return [
      const HomeOptionModel(
        title: 'Je veux commander un plat',
        icon: 'fastfood',
      ),
      const HomeOptionModel(
        title: 'Je veux expédier un colis',
        icon: 'local_shipping',
      ),
      if(role == 'admin' || role == 'livreur')
      const HomeOptionModel(
        title: 'Je veux livrer',
        icon: 'delivery_dining',
      ),
      /*const HomeOptionModel(
        title: 'Faire des courses',
        icon: 'shopping_cart',
      ),*/
      if (role == 'admin') ...[
        const HomeOptionModel(
          title: 'Administrateur',
          icon: 'admin_panel_settings',
        ),
      ],
    ];
  }
}
