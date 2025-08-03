import 'dart:convert';

import 'package:liya/modules/home/data/models/home_option_model.dart';

import '../../../../core/local_storage_factory.dart';
import '../../../../core/singletons.dart';

abstract class HomeLocalDataSource {
  Future<List<HomeOptionModel>> getHomeOptions();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<List<HomeOptionModel>> getHomeOptions() async {
    // Lire les données utilisateur à chaque appel pour avoir les données à jour
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    Map<String, dynamic> userDetails;

    try {
      userDetails = userDetailsJson is String
          ? jsonDecode(userDetailsJson)
          : userDetailsJson;
    } catch (e) {
      print('❌ Erreur parsing userDetails: $e');
      userDetails = {};
    }

    final String? role = userDetails['role'];
    print('🔄 Role de l\'utilisateur (mis à jour): $role');

    return [
      const HomeOptionModel(
        title: 'Je commande un plat',
        icon: 'fastfood',
      ),
      const HomeOptionModel(
        title: "J'expédie un colis",
        icon: 'local_shipping',
      ),
      if (role == 'admin' || role == 'livreur') ...[
        const HomeOptionModel(
          title: 'Je livre',
          icon: 'delivery_dining',
        ),
      ],
      if (role == 'admin') ...[
        const HomeOptionModel(
          title: 'Administrateur',
          icon: 'admin_panel_settings',
        ),
      ],
    ];
  }
}
