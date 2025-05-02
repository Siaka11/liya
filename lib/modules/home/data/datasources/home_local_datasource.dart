import 'package:liya/modules/home/data/models/home_option_model.dart';

abstract class HomeLocalDataSource {
  Future<List<HomeOptionModel>> getHomeOptions();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource{
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
      const HomeOptionModel(
        title: 'Je veux livrer',
        icon: 'delivery_dining',
      ),
      const HomeOptionModel(
        title: 'Faire des courses',
        icon: 'shopping_cart',
      ),
      const HomeOptionModel(
        title: 'Administrateur',
        icon: 'admin_panel_settings',
      ),
    ];
  }
}