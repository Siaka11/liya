// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i30;
import 'package:flutter/material.dart' as _i31;
import 'package:liya/core/test_beverages.dart' as _i29;
import 'package:liya/modules/admin/features/dishes/data/models/dish_model.dart'
    as _i32;
import 'package:liya/modules/admin/features/dishes/presentation/pages/dish_image_editor_page.dart'
    as _i8;
import 'package:liya/modules/admin/features/dishes/presentation/pages/dish_list_page.dart'
    as _i9;
import 'package:liya/modules/admin/features/dishes/presentation/pages/restaurant_select_page.dart'
    as _i26;
import 'package:liya/modules/auth/auth_page.dart' as _i4;
import 'package:liya/modules/auth/info_user_page.dart' as _i12;
import 'package:liya/modules/auth/otp_page.dart' as _i20;
import 'package:liya/modules/home/domain/entities/home_option.dart' as _i33;
import 'package:liya/modules/home/presentation/pages/home_page.dart' as _i10;
import 'package:liya/modules/parcel/feature/domain/entities/parcel.dart'
    as _i35;
import 'package:liya/modules/parcel/feature/presentation/pages/add_parcel_page.dart'
    as _i1;
import 'package:liya/modules/parcel/feature/presentation/pages/lieu_page.dart'
    as _i13;
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_detail_page.dart'
    as _i21;
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_home_page.dart'
    as _i22;
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_list_page.dart'
    as _i23;
import 'package:liya/modules/restaurant/features/card/presentation/pages/cart_page.dart'
    as _i5;
import 'package:liya/modules/restaurant/features/checkout/presentation/pages/checkout_page.dart'
    as _i6;
import 'package:liya/modules/restaurant/features/home/presentation/pages/all_dishes_page.dart'
    as _i2;
import 'package:liya/modules/restaurant/features/home/presentation/pages/all_restaurants_page.dart'
    as _i3;
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart'
    as _i7;
import 'package:liya/modules/restaurant/features/home/presentation/pages/home_restaurant.dart'
    as _i11;
import 'package:liya/modules/restaurant/features/home/presentation/pages/modern_dish_detail_page.dart'
    as _i15;
import 'package:liya/modules/restaurant/features/home/presentation/pages/modern_home_restaurant.dart'
    as _i16;
import 'package:liya/modules/restaurant/features/home/presentation/pages/modern_restaurant_detail_page.dart'
    as _i17;
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart'
    as _i25;
import 'package:liya/modules/restaurant/features/like/presentation/pages/liked_dishes_page.dart'
    as _i14;
import 'package:liya/modules/restaurant/features/order/domain/entities/order.dart'
    as _i34;
import 'package:liya/modules/restaurant/features/order/presentation/pages/order_detail_page.dart'
    as _i18;
import 'package:liya/modules/restaurant/features/order/presentation/pages/order_list_page.dart'
    as _i19;
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart'
    as _i24;
import 'package:liya/modules/restaurant/features/search/presentation/pages/search_page.dart'
    as _i27;
import 'package:liya/modules/share_location_page.dart' as _i28;

abstract class $AppRouter extends _i30.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i30.PageFactory> pagesMap = {
    AddParcelRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AddParcelPage(),
      );
    },
    AllDishesRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.AllDishesPage(),
      );
    },
    AllRestaurantsRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.AllRestaurantsPage(),
      );
    },
    AuthRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.AuthPage(),
      );
    },
    CartRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.CartPage(),
      );
    },
    CheckoutRoute.name: (routeData) {
      final args = routeData.argsAs<CheckoutRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i6.CheckoutPage(
          key: args.key,
          restaurantName: args.restaurantName,
          cartItems: args.cartItems,
        ),
      );
    },
    DishDetailRoute.name: (routeData) {
      final args = routeData.argsAs<DishDetailRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.DishDetailPage(
          key: args.key,
          id: args.id,
          restaurantId: args.restaurantId,
          name: args.name,
          price: args.price,
          imageUrl: args.imageUrl,
          rating: args.rating,
          description: args.description,
        ),
      );
    },
    DishImageEditorRoute.name: (routeData) {
      final args = routeData.argsAs<DishImageEditorRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.DishImageEditorPage(
          key: args.key,
          dish: args.dish,
        ),
      );
    },
    DishListRoute.name: (routeData) {
      final args = routeData.argsAs<DishListRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i9.DishListPage(
          key: args.key,
          restaurantId: args.restaurantId,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.HomePage(),
      );
    },
    HomeRestaurantRoute.name: (routeData) {
      final args = routeData.argsAs<HomeRestaurantRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i11.HomeRestaurantPage(
          key: args.key,
          option: args.option,
        ),
      );
    },
    InfoUserRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i12.InfoUserPage(),
      );
    },
    LieuRoute.name: (routeData) {
      final args = routeData.argsAs<LieuRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i13.LieuPage(
          key: args.key,
          phoneNumber: args.phoneNumber,
          typeProduit: args.typeProduit,
          isReception: args.isReception,
          ville: args.ville,
          colisDescription: args.colisDescription,
          colisList: args.colisList,
        ),
      );
    },
    LikedDishesRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i14.LikedDishesPage(),
      );
    },
    ModernDishDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ModernDishDetailRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i15.ModernDishDetailPage(
          id: args.id,
          restaurantId: args.restaurantId,
          name: args.name,
          price: args.price,
          imageUrl: args.imageUrl,
          rating: args.rating,
          description: args.description,
        ),
      );
    },
    ModernHomeRestaurantRoute.name: (routeData) {
      final args = routeData.argsAs<ModernHomeRestaurantRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i16.ModernHomeRestaurantPage(
          key: args.key,
          option: args.option,
        ),
      );
    },
    ModernRestaurantDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ModernRestaurantDetailRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i17.ModernRestaurantDetailPage(
          key: args.key,
          id: args.id,
          name: args.name,
          description: args.description,
          coverImage: args.coverImage,
        ),
      );
    },
    OrderDetailRoute.name: (routeData) {
      final args = routeData.argsAs<OrderDetailRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i18.OrderDetailPage(
          key: args.key,
          order: args.order,
        ),
      );
    },
    OrderListRoute.name: (routeData) {
      final args = routeData.argsAs<OrderListRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i19.OrderListPage(
          key: args.key,
          phoneNumber: args.phoneNumber,
        ),
      );
    },
    OtpRoute.name: (routeData) {
      final args = routeData.argsAs<OtpRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i20.OtpPage(
          args.verificationId,
          key: args.key,
        ),
      );
    },
    ParcelDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ParcelDetailRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i21.ParcelDetailPage(
          key: args.key,
          parcel: args.parcel,
        ),
      );
    },
    ParcelHomeRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i22.ParcelHomePage(),
      );
    },
    ParcelListRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i23.ParcelListPage(),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i24.ProfilePage(),
      );
    },
    RestaurantDetailRoute.name: (routeData) {
      final args = routeData.argsAs<RestaurantDetailRouteArgs>();
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i25.RestaurantDetailPage(
          key: args.key,
          id: args.id,
          name: args.name,
          description: args.description,
          coverImage: args.coverImage,
        ),
      );
    },
    RestaurantSelectRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i26.RestaurantSelectPage(),
      );
    },
    SearchRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i27.SearchPage(),
      );
    },
    ShareLocationRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i28.ShareLocationPage(),
      );
    },
    TestBeveragesRoute.name: (routeData) {
      return _i30.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i29.TestBeveragesPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.AddParcelPage]
class AddParcelRoute extends _i30.PageRouteInfo<void> {
  const AddParcelRoute({List<_i30.PageRouteInfo>? children})
      : super(
          AddParcelRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddParcelRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i2.AllDishesPage]
class AllDishesRoute extends _i30.PageRouteInfo<void> {
  const AllDishesRoute({List<_i30.PageRouteInfo>? children})
      : super(
          AllDishesRoute.name,
          initialChildren: children,
        );

  static const String name = 'AllDishesRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i3.AllRestaurantsPage]
class AllRestaurantsRoute extends _i30.PageRouteInfo<void> {
  const AllRestaurantsRoute({List<_i30.PageRouteInfo>? children})
      : super(
          AllRestaurantsRoute.name,
          initialChildren: children,
        );

  static const String name = 'AllRestaurantsRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i4.AuthPage]
class AuthRoute extends _i30.PageRouteInfo<void> {
  const AuthRoute({List<_i30.PageRouteInfo>? children})
      : super(
          AuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i5.CartPage]
class CartRoute extends _i30.PageRouteInfo<void> {
  const CartRoute({List<_i30.PageRouteInfo>? children})
      : super(
          CartRoute.name,
          initialChildren: children,
        );

  static const String name = 'CartRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i6.CheckoutPage]
class CheckoutRoute extends _i30.PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    _i31.Key? key,
    required String restaurantName,
    required List<Map<String, dynamic>> cartItems,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          CheckoutRoute.name,
          args: CheckoutRouteArgs(
            key: key,
            restaurantName: restaurantName,
            cartItems: cartItems,
          ),
          initialChildren: children,
        );

  static const String name = 'CheckoutRoute';

  static const _i30.PageInfo<CheckoutRouteArgs> page =
      _i30.PageInfo<CheckoutRouteArgs>(name);
}

class CheckoutRouteArgs {
  const CheckoutRouteArgs({
    this.key,
    required this.restaurantName,
    required this.cartItems,
  });

  final _i31.Key? key;

  final String restaurantName;

  final List<Map<String, dynamic>> cartItems;

  @override
  String toString() {
    return 'CheckoutRouteArgs{key: $key, restaurantName: $restaurantName, cartItems: $cartItems}';
  }
}

/// generated route for
/// [_i7.DishDetailPage]
class DishDetailRoute extends _i30.PageRouteInfo<DishDetailRouteArgs> {
  DishDetailRoute({
    _i31.Key? key,
    required String id,
    required String restaurantId,
    required String name,
    required String price,
    required String imageUrl,
    required String rating,
    required String description,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          DishDetailRoute.name,
          args: DishDetailRouteArgs(
            key: key,
            id: id,
            restaurantId: restaurantId,
            name: name,
            price: price,
            imageUrl: imageUrl,
            rating: rating,
            description: description,
          ),
          initialChildren: children,
        );

  static const String name = 'DishDetailRoute';

  static const _i30.PageInfo<DishDetailRouteArgs> page =
      _i30.PageInfo<DishDetailRouteArgs>(name);
}

class DishDetailRouteArgs {
  const DishDetailRouteArgs({
    this.key,
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.description,
  });

  final _i31.Key? key;

  final String id;

  final String restaurantId;

  final String name;

  final String price;

  final String imageUrl;

  final String rating;

  final String description;

  @override
  String toString() {
    return 'DishDetailRouteArgs{key: $key, id: $id, restaurantId: $restaurantId, name: $name, price: $price, imageUrl: $imageUrl, rating: $rating, description: $description}';
  }
}

/// generated route for
/// [_i8.DishImageEditorPage]
class DishImageEditorRoute
    extends _i30.PageRouteInfo<DishImageEditorRouteArgs> {
  DishImageEditorRoute({
    _i31.Key? key,
    required _i32.DishModel dish,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          DishImageEditorRoute.name,
          args: DishImageEditorRouteArgs(
            key: key,
            dish: dish,
          ),
          initialChildren: children,
        );

  static const String name = 'DishImageEditorRoute';

  static const _i30.PageInfo<DishImageEditorRouteArgs> page =
      _i30.PageInfo<DishImageEditorRouteArgs>(name);
}

class DishImageEditorRouteArgs {
  const DishImageEditorRouteArgs({
    this.key,
    required this.dish,
  });

  final _i31.Key? key;

  final _i32.DishModel dish;

  @override
  String toString() {
    return 'DishImageEditorRouteArgs{key: $key, dish: $dish}';
  }
}

/// generated route for
/// [_i9.DishListPage]
class DishListRoute extends _i30.PageRouteInfo<DishListRouteArgs> {
  DishListRoute({
    _i31.Key? key,
    required String restaurantId,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          DishListRoute.name,
          args: DishListRouteArgs(
            key: key,
            restaurantId: restaurantId,
          ),
          initialChildren: children,
        );

  static const String name = 'DishListRoute';

  static const _i30.PageInfo<DishListRouteArgs> page =
      _i30.PageInfo<DishListRouteArgs>(name);
}

class DishListRouteArgs {
  const DishListRouteArgs({
    this.key,
    required this.restaurantId,
  });

  final _i31.Key? key;

  final String restaurantId;

  @override
  String toString() {
    return 'DishListRouteArgs{key: $key, restaurantId: $restaurantId}';
  }
}

/// generated route for
/// [_i10.HomePage]
class HomeRoute extends _i30.PageRouteInfo<void> {
  const HomeRoute({List<_i30.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i11.HomeRestaurantPage]
class HomeRestaurantRoute extends _i30.PageRouteInfo<HomeRestaurantRouteArgs> {
  HomeRestaurantRoute({
    _i31.Key? key,
    required _i33.HomeOption option,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          HomeRestaurantRoute.name,
          args: HomeRestaurantRouteArgs(
            key: key,
            option: option,
          ),
          initialChildren: children,
        );

  static const String name = 'HomeRestaurantRoute';

  static const _i30.PageInfo<HomeRestaurantRouteArgs> page =
      _i30.PageInfo<HomeRestaurantRouteArgs>(name);
}

class HomeRestaurantRouteArgs {
  const HomeRestaurantRouteArgs({
    this.key,
    required this.option,
  });

  final _i31.Key? key;

  final _i33.HomeOption option;

  @override
  String toString() {
    return 'HomeRestaurantRouteArgs{key: $key, option: $option}';
  }
}

/// generated route for
/// [_i12.InfoUserPage]
class InfoUserRoute extends _i30.PageRouteInfo<void> {
  const InfoUserRoute({List<_i30.PageRouteInfo>? children})
      : super(
          InfoUserRoute.name,
          initialChildren: children,
        );

  static const String name = 'InfoUserRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i13.LieuPage]
class LieuRoute extends _i30.PageRouteInfo<LieuRouteArgs> {
  LieuRoute({
    _i31.Key? key,
    required String phoneNumber,
    required String typeProduit,
    bool isReception = false,
    required String ville,
    String? colisDescription,
    List<dynamic>? colisList,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          LieuRoute.name,
          args: LieuRouteArgs(
            key: key,
            phoneNumber: phoneNumber,
            typeProduit: typeProduit,
            isReception: isReception,
            ville: ville,
            colisDescription: colisDescription,
            colisList: colisList,
          ),
          initialChildren: children,
        );

  static const String name = 'LieuRoute';

  static const _i30.PageInfo<LieuRouteArgs> page =
      _i30.PageInfo<LieuRouteArgs>(name);
}

class LieuRouteArgs {
  const LieuRouteArgs({
    this.key,
    required this.phoneNumber,
    required this.typeProduit,
    this.isReception = false,
    required this.ville,
    this.colisDescription,
    this.colisList,
  });

  final _i31.Key? key;

  final String phoneNumber;

  final String typeProduit;

  final bool isReception;

  final String ville;

  final String? colisDescription;

  final List<dynamic>? colisList;

  @override
  String toString() {
    return 'LieuRouteArgs{key: $key, phoneNumber: $phoneNumber, typeProduit: $typeProduit, isReception: $isReception, ville: $ville, colisDescription: $colisDescription, colisList: $colisList}';
  }
}

/// generated route for
/// [_i14.LikedDishesPage]
class LikedDishesRoute extends _i30.PageRouteInfo<void> {
  const LikedDishesRoute({List<_i30.PageRouteInfo>? children})
      : super(
          LikedDishesRoute.name,
          initialChildren: children,
        );

  static const String name = 'LikedDishesRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i15.ModernDishDetailPage]
class ModernDishDetailRoute
    extends _i30.PageRouteInfo<ModernDishDetailRouteArgs> {
  ModernDishDetailRoute({
    required String id,
    required String restaurantId,
    required String name,
    required String price,
    required String imageUrl,
    required String rating,
    required String description,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          ModernDishDetailRoute.name,
          args: ModernDishDetailRouteArgs(
            id: id,
            restaurantId: restaurantId,
            name: name,
            price: price,
            imageUrl: imageUrl,
            rating: rating,
            description: description,
          ),
          initialChildren: children,
        );

  static const String name = 'ModernDishDetailRoute';

  static const _i30.PageInfo<ModernDishDetailRouteArgs> page =
      _i30.PageInfo<ModernDishDetailRouteArgs>(name);
}

class ModernDishDetailRouteArgs {
  const ModernDishDetailRouteArgs({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.description,
  });

  final String id;

  final String restaurantId;

  final String name;

  final String price;

  final String imageUrl;

  final String rating;

  final String description;

  @override
  String toString() {
    return 'ModernDishDetailRouteArgs{id: $id, restaurantId: $restaurantId, name: $name, price: $price, imageUrl: $imageUrl, rating: $rating, description: $description}';
  }
}

/// generated route for
/// [_i16.ModernHomeRestaurantPage]
class ModernHomeRestaurantRoute
    extends _i30.PageRouteInfo<ModernHomeRestaurantRouteArgs> {
  ModernHomeRestaurantRoute({
    _i31.Key? key,
    required _i33.HomeOption option,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          ModernHomeRestaurantRoute.name,
          args: ModernHomeRestaurantRouteArgs(
            key: key,
            option: option,
          ),
          initialChildren: children,
        );

  static const String name = 'ModernHomeRestaurantRoute';

  static const _i30.PageInfo<ModernHomeRestaurantRouteArgs> page =
      _i30.PageInfo<ModernHomeRestaurantRouteArgs>(name);
}

class ModernHomeRestaurantRouteArgs {
  const ModernHomeRestaurantRouteArgs({
    this.key,
    required this.option,
  });

  final _i31.Key? key;

  final _i33.HomeOption option;

  @override
  String toString() {
    return 'ModernHomeRestaurantRouteArgs{key: $key, option: $option}';
  }
}

/// generated route for
/// [_i17.ModernRestaurantDetailPage]
class ModernRestaurantDetailRoute
    extends _i30.PageRouteInfo<ModernRestaurantDetailRouteArgs> {
  ModernRestaurantDetailRoute({
    _i31.Key? key,
    required String id,
    required String name,
    required String description,
    required String coverImage,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          ModernRestaurantDetailRoute.name,
          args: ModernRestaurantDetailRouteArgs(
            key: key,
            id: id,
            name: name,
            description: description,
            coverImage: coverImage,
          ),
          initialChildren: children,
        );

  static const String name = 'ModernRestaurantDetailRoute';

  static const _i30.PageInfo<ModernRestaurantDetailRouteArgs> page =
      _i30.PageInfo<ModernRestaurantDetailRouteArgs>(name);
}

class ModernRestaurantDetailRouteArgs {
  const ModernRestaurantDetailRouteArgs({
    this.key,
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
  });

  final _i31.Key? key;

  final String id;

  final String name;

  final String description;

  final String coverImage;

  @override
  String toString() {
    return 'ModernRestaurantDetailRouteArgs{key: $key, id: $id, name: $name, description: $description, coverImage: $coverImage}';
  }
}

/// generated route for
/// [_i18.OrderDetailPage]
class OrderDetailRoute extends _i30.PageRouteInfo<OrderDetailRouteArgs> {
  OrderDetailRoute({
    _i31.Key? key,
    required _i34.Order order,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          OrderDetailRoute.name,
          args: OrderDetailRouteArgs(
            key: key,
            order: order,
          ),
          initialChildren: children,
        );

  static const String name = 'OrderDetailRoute';

  static const _i30.PageInfo<OrderDetailRouteArgs> page =
      _i30.PageInfo<OrderDetailRouteArgs>(name);
}

class OrderDetailRouteArgs {
  const OrderDetailRouteArgs({
    this.key,
    required this.order,
  });

  final _i31.Key? key;

  final _i34.Order order;

  @override
  String toString() {
    return 'OrderDetailRouteArgs{key: $key, order: $order}';
  }
}

/// generated route for
/// [_i19.OrderListPage]
class OrderListRoute extends _i30.PageRouteInfo<OrderListRouteArgs> {
  OrderListRoute({
    _i31.Key? key,
    required String phoneNumber,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          OrderListRoute.name,
          args: OrderListRouteArgs(
            key: key,
            phoneNumber: phoneNumber,
          ),
          initialChildren: children,
        );

  static const String name = 'OrderListRoute';

  static const _i30.PageInfo<OrderListRouteArgs> page =
      _i30.PageInfo<OrderListRouteArgs>(name);
}

class OrderListRouteArgs {
  const OrderListRouteArgs({
    this.key,
    required this.phoneNumber,
  });

  final _i31.Key? key;

  final String phoneNumber;

  @override
  String toString() {
    return 'OrderListRouteArgs{key: $key, phoneNumber: $phoneNumber}';
  }
}

/// generated route for
/// [_i20.OtpPage]
class OtpRoute extends _i30.PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    required String verificationId,
    _i31.Key? key,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          OtpRoute.name,
          args: OtpRouteArgs(
            verificationId: verificationId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'OtpRoute';

  static const _i30.PageInfo<OtpRouteArgs> page =
      _i30.PageInfo<OtpRouteArgs>(name);
}

class OtpRouteArgs {
  const OtpRouteArgs({
    required this.verificationId,
    this.key,
  });

  final String verificationId;

  final _i31.Key? key;

  @override
  String toString() {
    return 'OtpRouteArgs{verificationId: $verificationId, key: $key}';
  }
}

/// generated route for
/// [_i21.ParcelDetailPage]
class ParcelDetailRoute extends _i30.PageRouteInfo<ParcelDetailRouteArgs> {
  ParcelDetailRoute({
    _i31.Key? key,
    required _i35.Parcel parcel,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          ParcelDetailRoute.name,
          args: ParcelDetailRouteArgs(
            key: key,
            parcel: parcel,
          ),
          initialChildren: children,
        );

  static const String name = 'ParcelDetailRoute';

  static const _i30.PageInfo<ParcelDetailRouteArgs> page =
      _i30.PageInfo<ParcelDetailRouteArgs>(name);
}

class ParcelDetailRouteArgs {
  const ParcelDetailRouteArgs({
    this.key,
    required this.parcel,
  });

  final _i31.Key? key;

  final _i35.Parcel parcel;

  @override
  String toString() {
    return 'ParcelDetailRouteArgs{key: $key, parcel: $parcel}';
  }
}

/// generated route for
/// [_i22.ParcelHomePage]
class ParcelHomeRoute extends _i30.PageRouteInfo<void> {
  const ParcelHomeRoute({List<_i30.PageRouteInfo>? children})
      : super(
          ParcelHomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'ParcelHomeRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i23.ParcelListPage]
class ParcelListRoute extends _i30.PageRouteInfo<void> {
  const ParcelListRoute({List<_i30.PageRouteInfo>? children})
      : super(
          ParcelListRoute.name,
          initialChildren: children,
        );

  static const String name = 'ParcelListRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i24.ProfilePage]
class ProfileRoute extends _i30.PageRouteInfo<void> {
  const ProfileRoute({List<_i30.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i25.RestaurantDetailPage]
class RestaurantDetailRoute
    extends _i30.PageRouteInfo<RestaurantDetailRouteArgs> {
  RestaurantDetailRoute({
    _i31.Key? key,
    required String id,
    required String name,
    required String description,
    required String coverImage,
    List<_i30.PageRouteInfo>? children,
  }) : super(
          RestaurantDetailRoute.name,
          args: RestaurantDetailRouteArgs(
            key: key,
            id: id,
            name: name,
            description: description,
            coverImage: coverImage,
          ),
          initialChildren: children,
        );

  static const String name = 'RestaurantDetailRoute';

  static const _i30.PageInfo<RestaurantDetailRouteArgs> page =
      _i30.PageInfo<RestaurantDetailRouteArgs>(name);
}

class RestaurantDetailRouteArgs {
  const RestaurantDetailRouteArgs({
    this.key,
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
  });

  final _i31.Key? key;

  final String id;

  final String name;

  final String description;

  final String coverImage;

  @override
  String toString() {
    return 'RestaurantDetailRouteArgs{key: $key, id: $id, name: $name, description: $description, coverImage: $coverImage}';
  }
}

/// generated route for
/// [_i26.RestaurantSelectPage]
class RestaurantSelectRoute extends _i30.PageRouteInfo<void> {
  const RestaurantSelectRoute({List<_i30.PageRouteInfo>? children})
      : super(
          RestaurantSelectRoute.name,
          initialChildren: children,
        );

  static const String name = 'RestaurantSelectRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i27.SearchPage]
class SearchRoute extends _i30.PageRouteInfo<void> {
  const SearchRoute({List<_i30.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i28.ShareLocationPage]
class ShareLocationRoute extends _i30.PageRouteInfo<void> {
  const ShareLocationRoute({List<_i30.PageRouteInfo>? children})
      : super(
          ShareLocationRoute.name,
          initialChildren: children,
        );

  static const String name = 'ShareLocationRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}

/// generated route for
/// [_i29.TestBeveragesPage]
class TestBeveragesRoute extends _i30.PageRouteInfo<void> {
  const TestBeveragesRoute({List<_i30.PageRouteInfo>? children})
      : super(
          TestBeveragesRoute.name,
          initialChildren: children,
        );

  static const String name = 'TestBeveragesRoute';

  static const _i30.PageInfo<void> page = _i30.PageInfo<void>(name);
}
