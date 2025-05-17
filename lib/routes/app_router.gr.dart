// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;
import 'package:liya/modules/auth/auth_page.dart' as _i1;
import 'package:liya/modules/auth/info_user_page.dart' as _i5;
import 'package:liya/modules/auth/otp_page.dart' as _i6;
import 'package:liya/modules/home/domain/entities/home_option.dart' as _i11;
import 'package:liya/modules/home/presentation/pages/home_page.dart' as _i3;
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart'
    as _i2;
import 'package:liya/modules/restaurant/features/home/presentation/pages/home_restaurant.dart'
    as _i4;
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart'
    as _i7;
import 'package:liya/modules/share_location_page.dart' as _i8;

abstract class $AppRouter extends _i9.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i9.PageFactory> pagesMap = {
    AuthRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AuthPage(),
      );
    },
    DishDetailRoute.name: (routeData) {
      final args = routeData.argsAs<DishDetailRouteArgs>();
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.DishDetailPage(
          name: args.name,
          price: args.price,
          imageUrl: args.imageUrl,
          restaurantId: args.restaurantId,
          rating: args.rating,
          id: args.id,
          description: args.description,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.HomePage(),
      );
    },
    HomeRestaurantRoute.name: (routeData) {
      final args = routeData.argsAs<HomeRestaurantRouteArgs>();
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.HomeRestaurantPage(
          key: args.key,
          option: args.option,
        ),
      );
    },
    InfoUserRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.InfoUserPage(),
      );
    },
    OtpRoute.name: (routeData) {
      final args = routeData.argsAs<OtpRouteArgs>();
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i6.OtpPage(
          args.verificationId,
          key: args.key,
        ),
      );
    },
    RestaurantDetailRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<RestaurantDetailRouteArgs>(
          orElse: () => RestaurantDetailRouteArgs(
                id: pathParams.getString('id'),
                name: pathParams.getString('name'),
                description: pathParams.getString('description'),
              ));
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.RestaurantDetailPage(
          key: args.key,
          id: args.id,
          name: args.name,
          description: args.description,
        ),
      );
    },
    ShareLocationRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.ShareLocationPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.AuthPage]
class AuthRoute extends _i9.PageRouteInfo<void> {
  const AuthRoute({List<_i9.PageRouteInfo>? children})
      : super(
          AuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i2.DishDetailPage]
class DishDetailRoute extends _i9.PageRouteInfo<DishDetailRouteArgs> {
  DishDetailRoute({
    required String name,
    required String price,
    required String imageUrl,
    required String restaurantId,
    required String rating,
    required String id,
    required String description,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          DishDetailRoute.name,
          args: DishDetailRouteArgs(
            name: name,
            price: price,
            imageUrl: imageUrl,
            restaurantId: restaurantId,
            rating: rating,
            id: id,
            description: description,
          ),
          initialChildren: children,
        );

  static const String name = 'DishDetailRoute';

  static const _i9.PageInfo<DishDetailRouteArgs> page =
      _i9.PageInfo<DishDetailRouteArgs>(name);
}

class DishDetailRouteArgs {
  const DishDetailRouteArgs({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
    required this.rating,
    required this.id,
    required this.description,
  });

  final String name;

  final String price;

  final String imageUrl;

  final String restaurantId;

  final String rating;

  final String id;

  final String description;

  @override
  String toString() {
    return 'DishDetailRouteArgs{name: $name, price: $price, imageUrl: $imageUrl, restaurantId: $restaurantId, rating: $rating, id: $id, description: $description}';
  }
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i9.PageRouteInfo<void> {
  const HomeRoute({List<_i9.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i4.HomeRestaurantPage]
class HomeRestaurantRoute extends _i9.PageRouteInfo<HomeRestaurantRouteArgs> {
  HomeRestaurantRoute({
    _i10.Key? key,
    required _i11.HomeOption option,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          HomeRestaurantRoute.name,
          args: HomeRestaurantRouteArgs(
            key: key,
            option: option,
          ),
          initialChildren: children,
        );

  static const String name = 'HomeRestaurantRoute';

  static const _i9.PageInfo<HomeRestaurantRouteArgs> page =
      _i9.PageInfo<HomeRestaurantRouteArgs>(name);
}

class HomeRestaurantRouteArgs {
  const HomeRestaurantRouteArgs({
    this.key,
    required this.option,
  });

  final _i10.Key? key;

  final _i11.HomeOption option;

  @override
  String toString() {
    return 'HomeRestaurantRouteArgs{key: $key, option: $option}';
  }
}

/// generated route for
/// [_i5.InfoUserPage]
class InfoUserRoute extends _i9.PageRouteInfo<void> {
  const InfoUserRoute({List<_i9.PageRouteInfo>? children})
      : super(
          InfoUserRoute.name,
          initialChildren: children,
        );

  static const String name = 'InfoUserRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i6.OtpPage]
class OtpRoute extends _i9.PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    required String verificationId,
    _i10.Key? key,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          OtpRoute.name,
          args: OtpRouteArgs(
            verificationId: verificationId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'OtpRoute';

  static const _i9.PageInfo<OtpRouteArgs> page =
      _i9.PageInfo<OtpRouteArgs>(name);
}

class OtpRouteArgs {
  const OtpRouteArgs({
    required this.verificationId,
    this.key,
  });

  final String verificationId;

  final _i10.Key? key;

  @override
  String toString() {
    return 'OtpRouteArgs{verificationId: $verificationId, key: $key}';
  }
}

/// generated route for
/// [_i7.RestaurantDetailPage]
class RestaurantDetailRoute
    extends _i9.PageRouteInfo<RestaurantDetailRouteArgs> {
  RestaurantDetailRoute({
    _i10.Key? key,
    required String id,
    required String name,
    required String description,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          RestaurantDetailRoute.name,
          args: RestaurantDetailRouteArgs(
            key: key,
            id: id,
            name: name,
            description: description,
          ),
          rawPathParams: {
            'id': id,
            'name': name,
            'description': description,
          },
          initialChildren: children,
        );

  static const String name = 'RestaurantDetailRoute';

  static const _i9.PageInfo<RestaurantDetailRouteArgs> page =
      _i9.PageInfo<RestaurantDetailRouteArgs>(name);
}

class RestaurantDetailRouteArgs {
  const RestaurantDetailRouteArgs({
    this.key,
    required this.id,
    required this.name,
    required this.description,
  });

  final _i10.Key? key;

  final String id;

  final String name;

  final String description;

  @override
  String toString() {
    return 'RestaurantDetailRouteArgs{key: $key, id: $id, name: $name, description: $description}';
  }
}

/// generated route for
/// [_i8.ShareLocationPage]
class ShareLocationRoute extends _i9.PageRouteInfo<void> {
  const ShareLocationRoute({List<_i9.PageRouteInfo>? children})
      : super(
          ShareLocationRoute.name,
          initialChildren: children,
        );

  static const String name = 'ShareLocationRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}
