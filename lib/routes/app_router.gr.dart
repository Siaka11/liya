// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i46;
import 'package:flutter/material.dart' as _i47;
import 'package:liya/core/test_beverages.dart' as _i44;
import 'package:liya/core/test_users_management.dart' as _i45;
import 'package:liya/modules/admin/features/dishes/data/models/dish_model.dart'
    as _i49;
import 'package:liya/modules/admin/features/dishes/presentation/pages/dish_image_editor_page.dart'
    as _i16;
import 'package:liya/modules/admin/features/dishes/presentation/pages/dish_list_page.dart'
    as _i17;
import 'package:liya/modules/admin/features/dishes/presentation/pages/restaurant_select_page.dart'
    as _i39;
import 'package:liya/modules/admin/presentation/pages/admin_dashboard_page.dart'
    as _i2;
import 'package:liya/modules/admin/presentation/pages/delivery_user_management_page.dart'
    as _i14;
import 'package:liya/modules/admin/presentation/pages/dish_management_page.dart'
    as _i18;
import 'package:liya/modules/admin/presentation/pages/order_management_page.dart'
    as _i31;
import 'package:liya/modules/admin/presentation/pages/restaurant_management_page.dart'
    as _i38;
import 'package:liya/modules/auth/auth_page.dart' as _i5;
import 'package:liya/modules/auth/info_user_page.dart' as _i23;
import 'package:liya/modules/auth/otp_page.dart' as _i32;
import 'package:liya/modules/delivery/domain/entities/delivery_order.dart'
    as _i48;
import 'package:liya/modules/delivery/presentation/pages/delivery_admin_dashboard_page.dart'
    as _i8;
import 'package:liya/modules/delivery/presentation/pages/delivery_assignment_page.dart'
    as _i9;
import 'package:liya/modules/delivery/presentation/pages/delivery_dashboard_page.dart'
    as _i10;
import 'package:liya/modules/delivery/presentation/pages/delivery_detail_page.dart'
    as _i11;
import 'package:liya/modules/delivery/presentation/pages/delivery_list_page.dart'
    as _i12;
import 'package:liya/modules/delivery/presentation/pages/delivery_profile_page.dart'
    as _i13;
import 'package:liya/modules/delivery/presentation/pages/earnings_page.dart'
    as _i19;
import 'package:liya/modules/delivery/presentation/pages/home_delivery_page.dart'
    as _i20;
import 'package:liya/modules/delivery/presentation/pages/splash_delivery_page.dart'
    as _i42;
import 'package:liya/modules/delivery/presentation/pages/status_page.dart'
    as _i43;
import 'package:liya/modules/home/domain/entities/home_option.dart' as _i50;
import 'package:liya/modules/home/presentation/pages/home_page.dart' as _i21;
import 'package:liya/modules/parcel/feature/domain/entities/parcel.dart'
    as _i52;
import 'package:liya/modules/parcel/feature/presentation/pages/add_parcel_page.dart'
    as _i1;
import 'package:liya/modules/parcel/feature/presentation/pages/lieu_page.dart'
    as _i24;
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_detail_page.dart'
    as _i33;
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_home_page.dart'
    as _i34;
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_list_page.dart'
    as _i35;
import 'package:liya/modules/restaurant/features/card/presentation/pages/cart_page.dart'
    as _i6;
import 'package:liya/modules/restaurant/features/checkout/presentation/pages/checkout_page.dart'
    as _i7;
import 'package:liya/modules/restaurant/features/home/presentation/pages/all_dishes_page.dart'
    as _i3;
import 'package:liya/modules/restaurant/features/home/presentation/pages/all_restaurants_page.dart'
    as _i4;
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart'
    as _i15;
import 'package:liya/modules/restaurant/features/home/presentation/pages/home_restaurant.dart'
    as _i22;
import 'package:liya/modules/restaurant/features/home/presentation/pages/modern_dish_detail_page.dart'
    as _i26;
import 'package:liya/modules/restaurant/features/home/presentation/pages/modern_home_restaurant.dart'
    as _i27;
import 'package:liya/modules/restaurant/features/home/presentation/pages/modern_restaurant_detail_page.dart'
    as _i28;
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart'
    as _i37;
import 'package:liya/modules/restaurant/features/like/presentation/pages/liked_dishes_page.dart'
    as _i25;
import 'package:liya/modules/restaurant/features/order/domain/entities/order.dart'
    as _i51;
import 'package:liya/modules/restaurant/features/order/presentation/pages/order_detail_page.dart'
    as _i29;
import 'package:liya/modules/restaurant/features/order/presentation/pages/order_list_page.dart'
    as _i30;
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart'
    as _i36;
import 'package:liya/modules/restaurant/features/search/presentation/pages/search_page.dart'
    as _i40;
import 'package:liya/modules/share_location_page.dart' as _i41;

abstract class $AppRouter extends _i46.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i46.PageFactory> pagesMap = {
    AddParcelRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AddParcelPage(),
      );
    },
    AdminDashboardRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.AdminDashboardPage(),
      );
    },
    AllDishesRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.AllDishesPage(),
      );
    },
    AllRestaurantsRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.AllRestaurantsPage(),
      );
    },
    AuthRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.AuthPage(),
      );
    },
    CartRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.CartPage(),
      );
    },
    CheckoutRoute.name: (routeData) {
      final args = routeData.argsAs<CheckoutRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.CheckoutPage(
          key: args.key,
          restaurantName: args.restaurantName,
          cartItems: args.cartItems,
        ),
      );
    },
    DeliveryAdminDashboardRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.DeliveryAdminDashboardPage(),
      );
    },
    DeliveryAssignmentRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.DeliveryAssignmentPage(),
      );
    },
    DeliveryDashboardRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.DeliveryDashboardPage(),
      );
    },
    DeliveryDetailRoute.name: (routeData) {
      final args = routeData.argsAs<DeliveryDetailRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i11.DeliveryDetailPage(
          key: args.key,
          order: args.order,
        ),
      );
    },
    DeliveryListRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i12.DeliveryListPage(),
      );
    },
    DeliveryProfileRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i13.DeliveryProfilePage(),
      );
    },
    DeliveryUserManagementRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i14.DeliveryUserManagementPage(),
      );
    },
    DishDetailRoute.name: (routeData) {
      final args = routeData.argsAs<DishDetailRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i15.DishDetailPage(
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
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i16.DishImageEditorPage(
          key: args.key,
          dish: args.dish,
        ),
      );
    },
    DishListRoute.name: (routeData) {
      final args = routeData.argsAs<DishListRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i17.DishListPage(
          key: args.key,
          restaurantId: args.restaurantId,
        ),
      );
    },
    DishManagementRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i18.DishManagementPage(),
      );
    },
    EarningsRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i19.EarningsPage(),
      );
    },
    HomeDeliveryRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i20.HomeDeliveryPage(),
      );
    },
    HomeRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i21.HomePage(),
      );
    },
    HomeRestaurantRoute.name: (routeData) {
      final args = routeData.argsAs<HomeRestaurantRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i22.HomeRestaurantPage(
          key: args.key,
          option: args.option,
        ),
      );
    },
    InfoUserRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i23.InfoUserPage(),
      );
    },
    LieuRoute.name: (routeData) {
      final args = routeData.argsAs<LieuRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i24.LieuPage(
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
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i25.LikedDishesPage(),
      );
    },
    ModernDishDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ModernDishDetailRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i26.ModernDishDetailPage(
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
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i27.ModernHomeRestaurantPage(
          key: args.key,
          option: args.option,
        ),
      );
    },
    ModernRestaurantDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ModernRestaurantDetailRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i28.ModernRestaurantDetailPage(
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
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i29.OrderDetailPage(
          key: args.key,
          order: args.order,
        ),
      );
    },
    OrderListRoute.name: (routeData) {
      final args = routeData.argsAs<OrderListRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i30.OrderListPage(
          key: args.key,
          phoneNumber: args.phoneNumber,
        ),
      );
    },
    OrderManagementRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i31.OrderManagementPage(),
      );
    },
    OtpRoute.name: (routeData) {
      final args = routeData.argsAs<OtpRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i32.OtpPage(
          args.verificationId,
          key: args.key,
        ),
      );
    },
    ParcelDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ParcelDetailRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i33.ParcelDetailPage(
          key: args.key,
          parcel: args.parcel,
        ),
      );
    },
    ParcelHomeRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i34.ParcelHomePage(),
      );
    },
    ParcelListRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i35.ParcelListPage(),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i36.ProfilePage(),
      );
    },
    RestaurantDetailRoute.name: (routeData) {
      final args = routeData.argsAs<RestaurantDetailRouteArgs>();
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i37.RestaurantDetailPage(
          key: args.key,
          id: args.id,
          name: args.name,
          description: args.description,
          coverImage: args.coverImage,
        ),
      );
    },
    RestaurantManagementRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i38.RestaurantManagementPage(),
      );
    },
    RestaurantSelectRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i39.RestaurantSelectPage(),
      );
    },
    SearchRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i40.SearchPage(),
      );
    },
    ShareLocationRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i41.ShareLocationPage(),
      );
    },
    SplashDeliveryRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i42.SplashDeliveryPage(),
      );
    },
    StatusRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i43.StatusPage(),
      );
    },
    TestBeveragesRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i44.TestBeveragesPage(),
      );
    },
    TestUsersManagementRoute.name: (routeData) {
      return _i46.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i45.TestUsersManagementPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.AddParcelPage]
class AddParcelRoute extends _i46.PageRouteInfo<void> {
  const AddParcelRoute({List<_i46.PageRouteInfo>? children})
      : super(
          AddParcelRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddParcelRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i2.AdminDashboardPage]
class AdminDashboardRoute extends _i46.PageRouteInfo<void> {
  const AdminDashboardRoute({List<_i46.PageRouteInfo>? children})
      : super(
          AdminDashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'AdminDashboardRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i3.AllDishesPage]
class AllDishesRoute extends _i46.PageRouteInfo<void> {
  const AllDishesRoute({List<_i46.PageRouteInfo>? children})
      : super(
          AllDishesRoute.name,
          initialChildren: children,
        );

  static const String name = 'AllDishesRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i4.AllRestaurantsPage]
class AllRestaurantsRoute extends _i46.PageRouteInfo<void> {
  const AllRestaurantsRoute({List<_i46.PageRouteInfo>? children})
      : super(
          AllRestaurantsRoute.name,
          initialChildren: children,
        );

  static const String name = 'AllRestaurantsRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i5.AuthPage]
class AuthRoute extends _i46.PageRouteInfo<void> {
  const AuthRoute({List<_i46.PageRouteInfo>? children})
      : super(
          AuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i6.CartPage]
class CartRoute extends _i46.PageRouteInfo<void> {
  const CartRoute({List<_i46.PageRouteInfo>? children})
      : super(
          CartRoute.name,
          initialChildren: children,
        );

  static const String name = 'CartRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i7.CheckoutPage]
class CheckoutRoute extends _i46.PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    _i47.Key? key,
    required String restaurantName,
    required List<Map<String, dynamic>> cartItems,
    List<_i46.PageRouteInfo>? children,
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

  static const _i46.PageInfo<CheckoutRouteArgs> page =
      _i46.PageInfo<CheckoutRouteArgs>(name);
}

class CheckoutRouteArgs {
  const CheckoutRouteArgs({
    this.key,
    required this.restaurantName,
    required this.cartItems,
  });

  final _i47.Key? key;

  final String restaurantName;

  final List<Map<String, dynamic>> cartItems;

  @override
  String toString() {
    return 'CheckoutRouteArgs{key: $key, restaurantName: $restaurantName, cartItems: $cartItems}';
  }
}

/// generated route for
/// [_i8.DeliveryAdminDashboardPage]
class DeliveryAdminDashboardRoute extends _i46.PageRouteInfo<void> {
  const DeliveryAdminDashboardRoute({List<_i46.PageRouteInfo>? children})
      : super(
          DeliveryAdminDashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryAdminDashboardRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i9.DeliveryAssignmentPage]
class DeliveryAssignmentRoute extends _i46.PageRouteInfo<void> {
  const DeliveryAssignmentRoute({List<_i46.PageRouteInfo>? children})
      : super(
          DeliveryAssignmentRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryAssignmentRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i10.DeliveryDashboardPage]
class DeliveryDashboardRoute extends _i46.PageRouteInfo<void> {
  const DeliveryDashboardRoute({List<_i46.PageRouteInfo>? children})
      : super(
          DeliveryDashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryDashboardRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i11.DeliveryDetailPage]
class DeliveryDetailRoute extends _i46.PageRouteInfo<DeliveryDetailRouteArgs> {
  DeliveryDetailRoute({
    _i47.Key? key,
    required _i48.DeliveryOrder order,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          DeliveryDetailRoute.name,
          args: DeliveryDetailRouteArgs(
            key: key,
            order: order,
          ),
          initialChildren: children,
        );

  static const String name = 'DeliveryDetailRoute';

  static const _i46.PageInfo<DeliveryDetailRouteArgs> page =
      _i46.PageInfo<DeliveryDetailRouteArgs>(name);
}

class DeliveryDetailRouteArgs {
  const DeliveryDetailRouteArgs({
    this.key,
    required this.order,
  });

  final _i47.Key? key;

  final _i48.DeliveryOrder order;

  @override
  String toString() {
    return 'DeliveryDetailRouteArgs{key: $key, order: $order}';
  }
}

/// generated route for
/// [_i12.DeliveryListPage]
class DeliveryListRoute extends _i46.PageRouteInfo<void> {
  const DeliveryListRoute({List<_i46.PageRouteInfo>? children})
      : super(
          DeliveryListRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryListRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i13.DeliveryProfilePage]
class DeliveryProfileRoute extends _i46.PageRouteInfo<void> {
  const DeliveryProfileRoute({List<_i46.PageRouteInfo>? children})
      : super(
          DeliveryProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryProfileRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i14.DeliveryUserManagementPage]
class DeliveryUserManagementRoute extends _i46.PageRouteInfo<void> {
  const DeliveryUserManagementRoute({List<_i46.PageRouteInfo>? children})
      : super(
          DeliveryUserManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryUserManagementRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i15.DishDetailPage]
class DishDetailRoute extends _i46.PageRouteInfo<DishDetailRouteArgs> {
  DishDetailRoute({
    _i47.Key? key,
    required String id,
    required String restaurantId,
    required String name,
    required String price,
    required String imageUrl,
    required String rating,
    required String description,
    List<_i46.PageRouteInfo>? children,
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

  static const _i46.PageInfo<DishDetailRouteArgs> page =
      _i46.PageInfo<DishDetailRouteArgs>(name);
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

  final _i47.Key? key;

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
/// [_i16.DishImageEditorPage]
class DishImageEditorRoute
    extends _i46.PageRouteInfo<DishImageEditorRouteArgs> {
  DishImageEditorRoute({
    _i47.Key? key,
    required _i49.DishModel dish,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          DishImageEditorRoute.name,
          args: DishImageEditorRouteArgs(
            key: key,
            dish: dish,
          ),
          initialChildren: children,
        );

  static const String name = 'DishImageEditorRoute';

  static const _i46.PageInfo<DishImageEditorRouteArgs> page =
      _i46.PageInfo<DishImageEditorRouteArgs>(name);
}

class DishImageEditorRouteArgs {
  const DishImageEditorRouteArgs({
    this.key,
    required this.dish,
  });

  final _i47.Key? key;

  final _i49.DishModel dish;

  @override
  String toString() {
    return 'DishImageEditorRouteArgs{key: $key, dish: $dish}';
  }
}

/// generated route for
/// [_i17.DishListPage]
class DishListRoute extends _i46.PageRouteInfo<DishListRouteArgs> {
  DishListRoute({
    _i47.Key? key,
    required String restaurantId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          DishListRoute.name,
          args: DishListRouteArgs(
            key: key,
            restaurantId: restaurantId,
          ),
          initialChildren: children,
        );

  static const String name = 'DishListRoute';

  static const _i46.PageInfo<DishListRouteArgs> page =
      _i46.PageInfo<DishListRouteArgs>(name);
}

class DishListRouteArgs {
  const DishListRouteArgs({
    this.key,
    required this.restaurantId,
  });

  final _i47.Key? key;

  final String restaurantId;

  @override
  String toString() {
    return 'DishListRouteArgs{key: $key, restaurantId: $restaurantId}';
  }
}

/// generated route for
/// [_i18.DishManagementPage]
class DishManagementRoute extends _i46.PageRouteInfo<void> {
  const DishManagementRoute({List<_i46.PageRouteInfo>? children})
      : super(
          DishManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'DishManagementRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i19.EarningsPage]
class EarningsRoute extends _i46.PageRouteInfo<void> {
  const EarningsRoute({List<_i46.PageRouteInfo>? children})
      : super(
          EarningsRoute.name,
          initialChildren: children,
        );

  static const String name = 'EarningsRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i20.HomeDeliveryPage]
class HomeDeliveryRoute extends _i46.PageRouteInfo<void> {
  const HomeDeliveryRoute({List<_i46.PageRouteInfo>? children})
      : super(
          HomeDeliveryRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeDeliveryRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i21.HomePage]
class HomeRoute extends _i46.PageRouteInfo<void> {
  const HomeRoute({List<_i46.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i22.HomeRestaurantPage]
class HomeRestaurantRoute extends _i46.PageRouteInfo<HomeRestaurantRouteArgs> {
  HomeRestaurantRoute({
    _i47.Key? key,
    required _i50.HomeOption option,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          HomeRestaurantRoute.name,
          args: HomeRestaurantRouteArgs(
            key: key,
            option: option,
          ),
          initialChildren: children,
        );

  static const String name = 'HomeRestaurantRoute';

  static const _i46.PageInfo<HomeRestaurantRouteArgs> page =
      _i46.PageInfo<HomeRestaurantRouteArgs>(name);
}

class HomeRestaurantRouteArgs {
  const HomeRestaurantRouteArgs({
    this.key,
    required this.option,
  });

  final _i47.Key? key;

  final _i50.HomeOption option;

  @override
  String toString() {
    return 'HomeRestaurantRouteArgs{key: $key, option: $option}';
  }
}

/// generated route for
/// [_i23.InfoUserPage]
class InfoUserRoute extends _i46.PageRouteInfo<void> {
  const InfoUserRoute({List<_i46.PageRouteInfo>? children})
      : super(
          InfoUserRoute.name,
          initialChildren: children,
        );

  static const String name = 'InfoUserRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i24.LieuPage]
class LieuRoute extends _i46.PageRouteInfo<LieuRouteArgs> {
  LieuRoute({
    _i47.Key? key,
    required String phoneNumber,
    required String typeProduit,
    bool isReception = false,
    required String ville,
    String? colisDescription,
    List<dynamic>? colisList,
    List<_i46.PageRouteInfo>? children,
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

  static const _i46.PageInfo<LieuRouteArgs> page =
      _i46.PageInfo<LieuRouteArgs>(name);
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

  final _i47.Key? key;

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
/// [_i25.LikedDishesPage]
class LikedDishesRoute extends _i46.PageRouteInfo<void> {
  const LikedDishesRoute({List<_i46.PageRouteInfo>? children})
      : super(
          LikedDishesRoute.name,
          initialChildren: children,
        );

  static const String name = 'LikedDishesRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i26.ModernDishDetailPage]
class ModernDishDetailRoute
    extends _i46.PageRouteInfo<ModernDishDetailRouteArgs> {
  ModernDishDetailRoute({
    required String id,
    required String restaurantId,
    required String name,
    required String price,
    required String imageUrl,
    required String rating,
    required String description,
    List<_i46.PageRouteInfo>? children,
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

  static const _i46.PageInfo<ModernDishDetailRouteArgs> page =
      _i46.PageInfo<ModernDishDetailRouteArgs>(name);
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
/// [_i27.ModernHomeRestaurantPage]
class ModernHomeRestaurantRoute
    extends _i46.PageRouteInfo<ModernHomeRestaurantRouteArgs> {
  ModernHomeRestaurantRoute({
    _i47.Key? key,
    required _i50.HomeOption option,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ModernHomeRestaurantRoute.name,
          args: ModernHomeRestaurantRouteArgs(
            key: key,
            option: option,
          ),
          initialChildren: children,
        );

  static const String name = 'ModernHomeRestaurantRoute';

  static const _i46.PageInfo<ModernHomeRestaurantRouteArgs> page =
      _i46.PageInfo<ModernHomeRestaurantRouteArgs>(name);
}

class ModernHomeRestaurantRouteArgs {
  const ModernHomeRestaurantRouteArgs({
    this.key,
    required this.option,
  });

  final _i47.Key? key;

  final _i50.HomeOption option;

  @override
  String toString() {
    return 'ModernHomeRestaurantRouteArgs{key: $key, option: $option}';
  }
}

/// generated route for
/// [_i28.ModernRestaurantDetailPage]
class ModernRestaurantDetailRoute
    extends _i46.PageRouteInfo<ModernRestaurantDetailRouteArgs> {
  ModernRestaurantDetailRoute({
    _i47.Key? key,
    required String id,
    required String name,
    required String description,
    required String coverImage,
    List<_i46.PageRouteInfo>? children,
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

  static const _i46.PageInfo<ModernRestaurantDetailRouteArgs> page =
      _i46.PageInfo<ModernRestaurantDetailRouteArgs>(name);
}

class ModernRestaurantDetailRouteArgs {
  const ModernRestaurantDetailRouteArgs({
    this.key,
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
  });

  final _i47.Key? key;

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
/// [_i29.OrderDetailPage]
class OrderDetailRoute extends _i46.PageRouteInfo<OrderDetailRouteArgs> {
  OrderDetailRoute({
    _i47.Key? key,
    required _i51.Order order,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          OrderDetailRoute.name,
          args: OrderDetailRouteArgs(
            key: key,
            order: order,
          ),
          initialChildren: children,
        );

  static const String name = 'OrderDetailRoute';

  static const _i46.PageInfo<OrderDetailRouteArgs> page =
      _i46.PageInfo<OrderDetailRouteArgs>(name);
}

class OrderDetailRouteArgs {
  const OrderDetailRouteArgs({
    this.key,
    required this.order,
  });

  final _i47.Key? key;

  final _i51.Order order;

  @override
  String toString() {
    return 'OrderDetailRouteArgs{key: $key, order: $order}';
  }
}

/// generated route for
/// [_i30.OrderListPage]
class OrderListRoute extends _i46.PageRouteInfo<OrderListRouteArgs> {
  OrderListRoute({
    _i47.Key? key,
    required String phoneNumber,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          OrderListRoute.name,
          args: OrderListRouteArgs(
            key: key,
            phoneNumber: phoneNumber,
          ),
          initialChildren: children,
        );

  static const String name = 'OrderListRoute';

  static const _i46.PageInfo<OrderListRouteArgs> page =
      _i46.PageInfo<OrderListRouteArgs>(name);
}

class OrderListRouteArgs {
  const OrderListRouteArgs({
    this.key,
    required this.phoneNumber,
  });

  final _i47.Key? key;

  final String phoneNumber;

  @override
  String toString() {
    return 'OrderListRouteArgs{key: $key, phoneNumber: $phoneNumber}';
  }
}

/// generated route for
/// [_i31.OrderManagementPage]
class OrderManagementRoute extends _i46.PageRouteInfo<void> {
  const OrderManagementRoute({List<_i46.PageRouteInfo>? children})
      : super(
          OrderManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'OrderManagementRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i32.OtpPage]
class OtpRoute extends _i46.PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    required String verificationId,
    _i47.Key? key,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          OtpRoute.name,
          args: OtpRouteArgs(
            verificationId: verificationId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'OtpRoute';

  static const _i46.PageInfo<OtpRouteArgs> page =
      _i46.PageInfo<OtpRouteArgs>(name);
}

class OtpRouteArgs {
  const OtpRouteArgs({
    required this.verificationId,
    this.key,
  });

  final String verificationId;

  final _i47.Key? key;

  @override
  String toString() {
    return 'OtpRouteArgs{verificationId: $verificationId, key: $key}';
  }
}

/// generated route for
/// [_i33.ParcelDetailPage]
class ParcelDetailRoute extends _i46.PageRouteInfo<ParcelDetailRouteArgs> {
  ParcelDetailRoute({
    _i47.Key? key,
    required _i52.Parcel parcel,
    List<_i46.PageRouteInfo>? children,
  }) : super(
          ParcelDetailRoute.name,
          args: ParcelDetailRouteArgs(
            key: key,
            parcel: parcel,
          ),
          initialChildren: children,
        );

  static const String name = 'ParcelDetailRoute';

  static const _i46.PageInfo<ParcelDetailRouteArgs> page =
      _i46.PageInfo<ParcelDetailRouteArgs>(name);
}

class ParcelDetailRouteArgs {
  const ParcelDetailRouteArgs({
    this.key,
    required this.parcel,
  });

  final _i47.Key? key;

  final _i52.Parcel parcel;

  @override
  String toString() {
    return 'ParcelDetailRouteArgs{key: $key, parcel: $parcel}';
  }
}

/// generated route for
/// [_i34.ParcelHomePage]
class ParcelHomeRoute extends _i46.PageRouteInfo<void> {
  const ParcelHomeRoute({List<_i46.PageRouteInfo>? children})
      : super(
          ParcelHomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'ParcelHomeRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i35.ParcelListPage]
class ParcelListRoute extends _i46.PageRouteInfo<void> {
  const ParcelListRoute({List<_i46.PageRouteInfo>? children})
      : super(
          ParcelListRoute.name,
          initialChildren: children,
        );

  static const String name = 'ParcelListRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i36.ProfilePage]
class ProfileRoute extends _i46.PageRouteInfo<void> {
  const ProfileRoute({List<_i46.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i37.RestaurantDetailPage]
class RestaurantDetailRoute
    extends _i46.PageRouteInfo<RestaurantDetailRouteArgs> {
  RestaurantDetailRoute({
    _i47.Key? key,
    required String id,
    required String name,
    required String description,
    required String coverImage,
    List<_i46.PageRouteInfo>? children,
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

  static const _i46.PageInfo<RestaurantDetailRouteArgs> page =
      _i46.PageInfo<RestaurantDetailRouteArgs>(name);
}

class RestaurantDetailRouteArgs {
  const RestaurantDetailRouteArgs({
    this.key,
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
  });

  final _i47.Key? key;

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
/// [_i38.RestaurantManagementPage]
class RestaurantManagementRoute extends _i46.PageRouteInfo<void> {
  const RestaurantManagementRoute({List<_i46.PageRouteInfo>? children})
      : super(
          RestaurantManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'RestaurantManagementRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i39.RestaurantSelectPage]
class RestaurantSelectRoute extends _i46.PageRouteInfo<void> {
  const RestaurantSelectRoute({List<_i46.PageRouteInfo>? children})
      : super(
          RestaurantSelectRoute.name,
          initialChildren: children,
        );

  static const String name = 'RestaurantSelectRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i40.SearchPage]
class SearchRoute extends _i46.PageRouteInfo<void> {
  const SearchRoute({List<_i46.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i41.ShareLocationPage]
class ShareLocationRoute extends _i46.PageRouteInfo<void> {
  const ShareLocationRoute({List<_i46.PageRouteInfo>? children})
      : super(
          ShareLocationRoute.name,
          initialChildren: children,
        );

  static const String name = 'ShareLocationRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i42.SplashDeliveryPage]
class SplashDeliveryRoute extends _i46.PageRouteInfo<void> {
  const SplashDeliveryRoute({List<_i46.PageRouteInfo>? children})
      : super(
          SplashDeliveryRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashDeliveryRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i43.StatusPage]
class StatusRoute extends _i46.PageRouteInfo<void> {
  const StatusRoute({List<_i46.PageRouteInfo>? children})
      : super(
          StatusRoute.name,
          initialChildren: children,
        );

  static const String name = 'StatusRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i44.TestBeveragesPage]
class TestBeveragesRoute extends _i46.PageRouteInfo<void> {
  const TestBeveragesRoute({List<_i46.PageRouteInfo>? children})
      : super(
          TestBeveragesRoute.name,
          initialChildren: children,
        );

  static const String name = 'TestBeveragesRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}

/// generated route for
/// [_i45.TestUsersManagementPage]
class TestUsersManagementRoute extends _i46.PageRouteInfo<void> {
  const TestUsersManagementRoute({List<_i46.PageRouteInfo>? children})
      : super(
          TestUsersManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'TestUsersManagementRoute';

  static const _i46.PageInfo<void> page = _i46.PageInfo<void>(name);
}
