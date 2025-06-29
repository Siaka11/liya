import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:liya/modules/restaurant/features/home/domain/entities/home_option.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/home_restaurant.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart';

import '../../modules/admin/features/dishes/data/models/dish_model.dart';
import '../../modules/admin/features/dishes/presentation/pages/dish_image_editor_page.dart';
import '../../modules/admin/features/dishes/presentation/pages/dish_list_page.dart';
import '../../modules/admin/features/dishes/presentation/pages/restaurant_select_page.dart';
import '../../modules/auth/auth_page.dart';
import '../../modules/auth/info_user_page.dart';
import '../../modules/auth/otp_page.dart';
import '../../modules/home/domain/entities/home_option.dart';
import '../../modules/home/presentation/pages/home_page.dart';
import '../../modules/parcel/feature/domain/entities/parcel.dart';
import '../../modules/parcel/feature/presentation/pages/add_parcel_page.dart';
import '../../modules/parcel/feature/presentation/pages/lieu_page.dart';
import '../../modules/parcel/feature/presentation/pages/parcel_detail_page.dart';
import '../../modules/parcel/feature/presentation/pages/parcel_home_page.dart';
import '../../modules/parcel/feature/presentation/pages/parcel_list_page.dart';
import '../../modules/restaurant/features/card/presentation/pages/cart_page.dart';
import '../../modules/restaurant/features/checkout/presentation/pages/checkout_page.dart';
import '../../modules/restaurant/features/home/presentation/pages/all_dishes_page.dart';
import '../../modules/restaurant/features/home/presentation/pages/all_restaurants_page.dart';
import '../../modules/restaurant/features/home/presentation/pages/modern_dish_detail_page.dart';
import '../../modules/restaurant/features/home/presentation/pages/modern_home_restaurant.dart';
import '../../modules/restaurant/features/home/presentation/pages/modern_restaurant_detail_page.dart';
import '../../modules/restaurant/features/like/presentation/pages/liked_dishes_page.dart';
import '../../modules/restaurant/features/order/domain/entities/order.dart';
import '../../modules/restaurant/features/order/presentation/pages/order_detail_page.dart';
import '../../modules/restaurant/features/order/presentation/pages/order_list_page.dart';
import '../../modules/restaurant/features/profile/presentation/pages/profile_page.dart';
import '../../modules/restaurant/features/search/presentation/pages/search_page.dart';
import '../../modules/share_location_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRestaurantRoute.page, initial: true),
        AutoRoute(page: DishDetailRoute.page),
        AutoRoute(page: RestaurantDetailRoute.page),
      ];
}
