import 'package:liya/modules/home/domain/entities/home_option.dart';

class HomeOptionModel extends HomeOption {

  const HomeOptionModel({
    required super.title,
    required super.icon,
    String location = '',
    String availability = '',
  }) : super(

    location: location,
    availability: availability,
  );

  factory HomeOptionModel.fromJson(Map<String, dynamic> json) {
    return HomeOptionModel(
      title: json['title'] as String,
      icon: json['icon'] as String,
      location: json['location'] as String? ?? '',
      availability: json['availability'] as String? ?? '',
    );

  }
}


abstract class HomeLocalDataSource {
  Future<List<HomeOptionModel>> getHomeOptions();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<List<HomeOptionModel>> getHomeOptions() async {
    // Données statiques (peut être remplacé par une API)
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
        title: 'Vos livreurs disponibles',
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