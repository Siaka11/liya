// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i13;
import 'package:flutter/material.dart' as _i14;
import 'package:liya/modules/auth/auth_page.dart' as _i1;
import 'package:liya/modules/auth/info_user_page.dart' as _i7;
import 'package:liya/modules/auth/otp_page.dart' as _i8;
import 'package:liya/modules/home/domain/entities/home_option.dart' as _i15;
import 'package:liya/modules/home/presentation/pages/home_page.dart' as _i5;
import 'package:liya/modules/restaurant/features/card/presentation/pages/cart_page.dart'
    as _i2;
import 'package:liya/modules/restaurant/features/checkout/presentation/pages/checkout_page.dart'
    as _i3;
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart'
    as _i4;
import 'package:liya/modules/restaurant/features/home/presentation/pages/home_restaurant.dart'
    as _i6;
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart'
    as _i10;
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart'
    as _i9;
import 'package:liya/modules/restaurant/features/search/presentation/pages/search_page.dart'
    as _i11;
import 'package:liya/modules/share_location_page.dart' as _i12;

abstract class $AppRouter extends _i13.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i13.PageFactory> pagesMap = {
    AuthRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AuthPage(),
      );
    },
    CartRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.CartPage(),
      );
    },
    CheckoutRoute.name: (routeData) {
      final args = routeData.argsAs<CheckoutRouteArgs>();
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i3.CheckoutPage(
          key: args.key,
          restaurantName: args.restaurantName,
          cartItems: args.cartItems,
        ),
      );
    },
    DishDetailRoute.name: (routeData) {
      final args = routeData.argsAs<DishDetailRouteArgs>();
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.DishDetailPage(
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
    HomeRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.HomePage(),
      );
    },
    HomeRestaurantRoute.name: (routeData) {
      final args = routeData.argsAs<HomeRestaurantRouteArgs>();
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i6.HomeRestaurantPage(
          key: args.key,
          option: args.option,
        ),
      );
    },
    InfoUserRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.InfoUserPage(),
      );
    },
    OtpRoute.name: (routeData) {
      final args = routeData.argsAs<OtpRouteArgs>();
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.OtpPage(
          args.verificationId,
          key: args.key,
        ),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.ProfilePage(),
      );
    },
    RestaurantDetailRoute.name: (routeData) {
      final args = routeData.argsAs<RestaurantDetailRouteArgs>();
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i10.RestaurantDetailPage(
          key: args.key,
          id: args.id,
          name: args.name,
          description: args.description,
        ),
      );
    },
    SearchRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.SearchPage(),
      );
    },
    ShareLocationRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i12.ShareLocationPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.AuthPage]
class AuthRoute extends _i13.PageRouteInfo<void> {
  const AuthRoute({List<_i13.PageRouteInfo>? children})
      : super(
          AuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i2.CartPage]
class CartRoute extends _i13.PageRouteInfo<void> {
  const CartRoute({List<_i13.PageRouteInfo>? children})
      : super(
          CartRoute.name,
          initialChildren: children,
        );

  static const String name = 'CartRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i3.CheckoutPage]
class CheckoutRoute extends _i13.PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    _i14.Key? key,
    required String restaurantName,
    required List<Map<String, dynamic>> cartItems,
    List<_i13.PageRouteInfo>? children,
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

  static const _i13.PageInfo<CheckoutRouteArgs> page =
      _i13.PageInfo<CheckoutRouteArgs>(name);
}

class CheckoutRouteArgs {
  const CheckoutRouteArgs({
    this.key,
    required this.restaurantName,
    required this.cartItems,
  });

  final _i14.Key? key;

  final String restaurantName;

  final List<Map<String, dynamic>> cartItems;

  @override
  String toString() {
    return 'CheckoutRouteArgs{key: $key, restaurantName: $restaurantName, cartItems: $cartItems}';
  }
}

/// generated route for
/// [_i4.DishDetailPage]
class DishDetailRoute extends _i13.PageRouteInfo<DishDetailRouteArgs> {
  DishDetailRoute({
    required String id,
    required String restaurantId,
    required String name,
    required String price,
    required String imageUrl,
    required String rating,
    required String description,
    List<_i13.PageRouteInfo>? children,
  }) : super(
          DishDetailRoute.name,
          args: DishDetailRouteArgs(
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

  static const _i13.PageInfo<DishDetailRouteArgs> page =
      _i13.PageInfo<DishDetailRouteArgs>(name);
}

class DishDetailRouteArgs {
  const DishDetailRouteArgs({
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
    return 'DishDetailRouteArgs{id: $id, restaurantId: $restaurantId, name: $name, price: $price, imageUrl: $imageUrl, rating: $rating, description: $description}';
  }
}

/// generated route for
/// [_i5.HomePage]
class HomeRoute extends _i13.PageRouteInfo<void> {
  const HomeRoute({List<_i13.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i6.HomeRestaurantPage]
class HomeRestaurantRoute extends _i13.PageRouteInfo<HomeRestaurantRouteArgs> {
  HomeRestaurantRoute({
    _i14.Key? key,
    required _i15.HomeOption option,
    List<_i13.PageRouteInfo>? children,
  }) : super(
          HomeRestaurantRoute.name,
          args: HomeRestaurantRouteArgs(
            key: key,
            option: option,
          ),
          initialChildren: children,
        );

  static const String name = 'HomeRestaurantRoute';

  static const _i13.PageInfo<HomeRestaurantRouteArgs> page =
      _i13.PageInfo<HomeRestaurantRouteArgs>(name);
}

class HomeRestaurantRouteArgs {
  const HomeRestaurantRouteArgs({
    this.key,
    required this.option,
  });

  final _i14.Key? key;

  final _i15.HomeOption option;

  @override
  String toString() {
    return 'HomeRestaurantRouteArgs{key: $key, option: $option}';
  }
}

/// generated route for
/// [_i7.InfoUserPage]
class InfoUserRoute extends _i13.PageRouteInfo<void> {
  const InfoUserRoute({List<_i13.PageRouteInfo>? children})
      : super(
          InfoUserRoute.name,
          initialChildren: children,
        );

  static const String name = 'InfoUserRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i8.OtpPage]
class OtpRoute extends _i13.PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    required String verificationId,
    _i14.Key? key,
    List<_i13.PageRouteInfo>? children,
  }) : super(
          OtpRoute.name,
          args: OtpRouteArgs(
            verificationId: verificationId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'OtpRoute';

  static const _i13.PageInfo<OtpRouteArgs> page =
      _i13.PageInfo<OtpRouteArgs>(name);
}

class OtpRouteArgs {
  const OtpRouteArgs({
    required this.verificationId,
    this.key,
  });

  final String verificationId;

  final _i14.Key? key;

  @override
  String toString() {
    return 'OtpRouteArgs{verificationId: $verificationId, key: $key}';
  }
}

/// generated route for
/// [_i9.ProfilePage]
class ProfileRoute extends _i13.PageRouteInfo<void> {
  const ProfileRoute({List<_i13.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i10.RestaurantDetailPage]
class RestaurantDetailRoute
    extends _i13.PageRouteInfo<RestaurantDetailRouteArgs> {
  RestaurantDetailRoute({
    _i14.Key? key,
    required String id,
    required String name,
    required String description,
    List<_i13.PageRouteInfo>? children,
  }) : super(
          RestaurantDetailRoute.name,
          args: RestaurantDetailRouteArgs(
            key: key,
            id: id,
            name: name,
            description: description,
          ),
          initialChildren: children,
        );

  static const String name = 'RestaurantDetailRoute';

  static const _i13.PageInfo<RestaurantDetailRouteArgs> page =
      _i13.PageInfo<RestaurantDetailRouteArgs>(name);
}

class RestaurantDetailRouteArgs {
  const RestaurantDetailRouteArgs({
    this.key,
    required this.id,
    required this.name,
    required this.description,
  });

  final _i14.Key? key;

  final String id;

  final String name;

  final String description;

  @override
  String toString() {
    return 'RestaurantDetailRouteArgs{key: $key, id: $id, name: $name, description: $description}';
  }
}

/// generated route for
/// [_i11.SearchPage]
class SearchRoute extends _i13.PageRouteInfo<void> {
  const SearchRoute({List<_i13.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i12.ShareLocationPage]
class ShareLocationRoute extends _i13.PageRouteInfo<void> {
  const ShareLocationRoute({List<_i13.PageRouteInfo>? children})
      : super(
          ShareLocationRoute.name,
          initialChildren: children,
        );

  static const String name = 'ShareLocationRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}
