// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i56;
import 'package:flutter/material.dart' as _i57;
import 'package:liya/core/test_beverages.dart' as _i53;
import 'package:liya/core/test_users_management.dart' as _i54;
import 'package:liya/modules/admin/features/dishes/data/models/dish_model.dart'
    as _i59;
import 'package:liya/modules/admin/features/dishes/presentation/pages/dish_image_editor_page.dart'
    as _i20;
import 'package:liya/modules/admin/features/dishes/presentation/pages/dish_list_page.dart'
    as _i21;
import 'package:liya/modules/admin/features/dishes/presentation/pages/restaurant_select_page.dart'
    as _i46;
import 'package:liya/modules/admin/presentation/pages/add_dish_page.dart'
    as _i1;
import 'package:liya/modules/admin/presentation/pages/admin_dashboard_page.dart'
    as _i3;
import 'package:liya/modules/admin/presentation/pages/assignment_management_page.dart'
    as _i6;
import 'package:liya/modules/admin/presentation/pages/category_management_page.dart'
    as _i9;
import 'package:liya/modules/admin/presentation/pages/delivery_user_management_page.dart'
    as _i18;
import 'package:liya/modules/admin/presentation/pages/dish_management_page.dart'
    as _i22;
import 'package:liya/modules/admin/presentation/pages/image_management_page.dart'
    as _i27;
import 'package:liya/modules/admin/presentation/pages/order_management_page.dart'
    as _i37;
import 'package:liya/modules/admin/presentation/pages/restaurant_edit_page.dart'
    as _i44;
import 'package:liya/modules/admin/presentation/pages/restaurant_management_page.dart'
    as _i45;
import 'package:liya/modules/admin/presentation/pages/role_permission_management_page.dart'
    as _i47;
import 'package:liya/modules/admin/presentation/pages/statistics_page.dart'
    as _i51;
import 'package:liya/modules/admin/presentation/pages/user_management_page.dart'
    as _i55;
import 'package:liya/modules/auth/auth_page.dart' as _i7;
import 'package:liya/modules/auth/info_user_page.dart' as _i28;
import 'package:liya/modules/auth/otp_page.dart' as _i38;
import 'package:liya/modules/delivery/domain/entities/delivery_order.dart'
    as _i58;
import 'package:liya/modules/delivery/presentation/pages/delivery_admin_dashboard_page.dart'
    as _i11;
import 'package:liya/modules/delivery/presentation/pages/delivery_assignment_page.dart'
    as _i12;
import 'package:liya/modules/delivery/presentation/pages/delivery_dashboard_page.dart'
    as _i13;
import 'package:liya/modules/delivery/presentation/pages/delivery_detail_page.dart'
    as _i14;
import 'package:liya/modules/delivery/presentation/pages/delivery_list_page.dart'
    as _i15;
import 'package:liya/modules/delivery/presentation/pages/delivery_orders_page.dart'
    as _i16;
import 'package:liya/modules/delivery/presentation/pages/delivery_profile_page.dart'
    as _i17;
import 'package:liya/modules/delivery/presentation/pages/earnings_page.dart'
    as _i23;
import 'package:liya/modules/delivery/presentation/pages/home_delivery_page.dart'
    as _i24;
import 'package:liya/modules/delivery/presentation/pages/splash_delivery_page.dart'
    as _i50;
import 'package:liya/modules/delivery/presentation/pages/status_page.dart'
    as _i52;
import 'package:liya/modules/home/domain/entities/home_option.dart' as _i60;
import 'package:liya/modules/home/presentation/pages/home_page.dart' as _i25;
import 'package:liya/modules/parcel/feature/domain/entities/parcel.dart'
    as _i62;
import 'package:liya/modules/parcel/feature/presentation/pages/add_parcel_page.dart'
    as _i2;
import 'package:liya/modules/parcel/feature/presentation/pages/lieu_page.dart'
    as _i29;
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_detail_page.dart'
    as _i39;
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_home_page.dart'
    as _i40;
import 'package:liya/modules/parcel/feature/presentation/pages/parcel_list_page.dart'
    as _i41;
import 'package:liya/modules/restaurant/features/card/presentation/pages/cart_page.dart'
    as _i8;
import 'package:liya/modules/restaurant/features/checkout/presentation/pages/checkout_page.dart'
    as _i10;
import 'package:liya/modules/restaurant/features/home/presentation/pages/all_dishes_page.dart'
    as _i4;
import 'package:liya/modules/restaurant/features/home/presentation/pages/all_restaurants_page.dart'
    as _i5;
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart'
    as _i19;
import 'package:liya/modules/restaurant/features/home/presentation/pages/home_restaurant.dart'
    as _i26;
import 'package:liya/modules/restaurant/features/home/presentation/pages/modern_dish_detail_page.dart'
    as _i31;
import 'package:liya/modules/restaurant/features/home/presentation/pages/modern_home_restaurant.dart'
    as _i32;
import 'package:liya/modules/restaurant/features/home/presentation/pages/modern_restaurant_detail_page.dart'
    as _i33;
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart'
    as _i43;
import 'package:liya/modules/restaurant/features/like/presentation/pages/liked_dishes_page.dart'
    as _i30;
import 'package:liya/modules/restaurant/features/notifications/presentation/pages/notifications_page.dart'
    as _i34;
import 'package:liya/modules/restaurant/features/order/domain/entities/order.dart'
    as _i61;
import 'package:liya/modules/restaurant/features/order/presentation/pages/order_detail_page.dart'
    as _i35;
import 'package:liya/modules/restaurant/features/order/presentation/pages/order_list_page.dart'
    as _i36;
import 'package:liya/modules/restaurant/features/profile/presentation/pages/profile_page.dart'
    as _i42;
import 'package:liya/modules/restaurant/features/search/presentation/pages/search_page.dart'
    as _i48;
import 'package:liya/modules/share_location_page.dart' as _i49;

abstract class $AppRouter extends _i56.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i56.PageFactory> pagesMap = {
    AddDishRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AddDishPage(),
      );
    },
    AddParcelRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.AddParcelPage(),
      );
    },
    AdminDashboardRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.AdminDashboardPage(),
      );
    },
    AllDishesRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.AllDishesPage(),
      );
    },
    AllRestaurantsRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.AllRestaurantsPage(),
      );
    },
    AssignmentManagementRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.AssignmentManagementPage(),
      );
    },
    AuthRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.AuthPage(),
      );
    },
    CartRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.CartPage(),
      );
    },
    CategoryManagementRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.CategoryManagementPage(),
      );
    },
    CheckoutRoute.name: (routeData) {
      final args = routeData.argsAs<CheckoutRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i10.CheckoutPage(
          key: args.key,
          restaurantName: args.restaurantName,
          cartItems: args.cartItems,
        ),
      );
    },
    DeliveryAdminDashboardRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.DeliveryAdminDashboardPage(),
      );
    },
    DeliveryAssignmentRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i12.DeliveryAssignmentPage(),
      );
    },
    DeliveryDashboardRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i13.DeliveryDashboardPage(),
      );
    },
    DeliveryDetailRoute.name: (routeData) {
      final args = routeData.argsAs<DeliveryDetailRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i14.DeliveryDetailPage(
          key: args.key,
          order: args.order,
        ),
      );
    },
    DeliveryListRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i15.DeliveryListPage(),
      );
    },
    DeliveryOrdersRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i16.DeliveryOrdersPage(),
      );
    },
    DeliveryProfileRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i17.DeliveryProfilePage(),
      );
    },
    DeliveryUserManagementRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i18.DeliveryUserManagementPage(),
      );
    },
    DishDetailRoute.name: (routeData) {
      final args = routeData.argsAs<DishDetailRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i19.DishDetailPage(
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
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i20.DishImageEditorPage(
          key: args.key,
          dish: args.dish,
        ),
      );
    },
    DishListRoute.name: (routeData) {
      final args = routeData.argsAs<DishListRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i21.DishListPage(
          key: args.key,
          restaurantId: args.restaurantId,
        ),
      );
    },
    DishManagementRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i22.DishManagementPage(),
      );
    },
    EarningsRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i23.EarningsPage(),
      );
    },
    HomeDeliveryRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i24.HomeDeliveryPage(),
      );
    },
    HomeRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i25.HomePage(),
      );
    },
    HomeRestaurantRoute.name: (routeData) {
      final args = routeData.argsAs<HomeRestaurantRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i26.HomeRestaurantPage(
          key: args.key,
          option: args.option,
        ),
      );
    },
    ImageManagementRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i27.ImageManagementPage(),
      );
    },
    InfoUserRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i28.InfoUserPage(),
      );
    },
    LieuRoute.name: (routeData) {
      final args = routeData.argsAs<LieuRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i29.LieuPage(
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
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i30.LikedDishesPage(),
      );
    },
    ModernDishDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ModernDishDetailRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i31.ModernDishDetailPage(
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
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i32.ModernHomeRestaurantPage(
          key: args.key,
          option: args.option,
        ),
      );
    },
    ModernRestaurantDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ModernRestaurantDetailRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i33.ModernRestaurantDetailPage(
          key: args.key,
          id: args.id,
          name: args.name,
          description: args.description,
          coverImage: args.coverImage,
        ),
      );
    },
    NotificationsRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i34.NotificationsPage(),
      );
    },
    OrderDetailRoute.name: (routeData) {
      final args = routeData.argsAs<OrderDetailRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i35.OrderDetailPage(
          key: args.key,
          order: args.order,
        ),
      );
    },
    OrderListRoute.name: (routeData) {
      final args = routeData.argsAs<OrderListRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i36.OrderListPage(
          key: args.key,
          phoneNumber: args.phoneNumber,
        ),
      );
    },
    OrderManagementRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i37.OrderManagementPage(),
      );
    },
    OtpRoute.name: (routeData) {
      final args = routeData.argsAs<OtpRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i38.OtpPage(
          args.verificationId,
          key: args.key,
        ),
      );
    },
    ParcelDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ParcelDetailRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i39.ParcelDetailPage(
          key: args.key,
          parcel: args.parcel,
        ),
      );
    },
    ParcelHomeRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i40.ParcelHomePage(),
      );
    },
    ParcelListRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i41.ParcelListPage(),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i42.ProfilePage(),
      );
    },
    RestaurantDetailRoute.name: (routeData) {
      final args = routeData.argsAs<RestaurantDetailRouteArgs>();
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i43.RestaurantDetailPage(
          key: args.key,
          id: args.id,
          name: args.name,
          description: args.description,
          coverImage: args.coverImage,
        ),
      );
    },
    RestaurantEditRoute.name: (routeData) {
      final args = routeData.argsAs<RestaurantEditRouteArgs>(
          orElse: () => const RestaurantEditRouteArgs());
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i44.RestaurantEditPage(
          key: args.key,
          restaurantId: args.restaurantId,
        ),
      );
    },
    RestaurantManagementRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i45.RestaurantManagementPage(),
      );
    },
    RestaurantSelectRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i46.RestaurantSelectPage(),
      );
    },
    RolePermissionManagementRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i47.RolePermissionManagementPage(),
      );
    },
    SearchRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i48.SearchPage(),
      );
    },
    ShareLocationRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i49.ShareLocationPage(),
      );
    },
    SplashDeliveryRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i50.SplashDeliveryPage(),
      );
    },
    StatisticsRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i51.StatisticsPage(),
      );
    },
    StatusRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i52.StatusPage(),
      );
    },
    TestBeveragesRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i53.TestBeveragesPage(),
      );
    },
    TestUsersManagementRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i54.TestUsersManagementPage(),
      );
    },
    UserManagementRoute.name: (routeData) {
      return _i56.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i55.UserManagementPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.AddDishPage]
class AddDishRoute extends _i56.PageRouteInfo<void> {
  const AddDishRoute({List<_i56.PageRouteInfo>? children})
      : super(
          AddDishRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddDishRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i2.AddParcelPage]
class AddParcelRoute extends _i56.PageRouteInfo<void> {
  const AddParcelRoute({List<_i56.PageRouteInfo>? children})
      : super(
          AddParcelRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddParcelRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i3.AdminDashboardPage]
class AdminDashboardRoute extends _i56.PageRouteInfo<void> {
  const AdminDashboardRoute({List<_i56.PageRouteInfo>? children})
      : super(
          AdminDashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'AdminDashboardRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i4.AllDishesPage]
class AllDishesRoute extends _i56.PageRouteInfo<void> {
  const AllDishesRoute({List<_i56.PageRouteInfo>? children})
      : super(
          AllDishesRoute.name,
          initialChildren: children,
        );

  static const String name = 'AllDishesRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i5.AllRestaurantsPage]
class AllRestaurantsRoute extends _i56.PageRouteInfo<void> {
  const AllRestaurantsRoute({List<_i56.PageRouteInfo>? children})
      : super(
          AllRestaurantsRoute.name,
          initialChildren: children,
        );

  static const String name = 'AllRestaurantsRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i6.AssignmentManagementPage]
class AssignmentManagementRoute extends _i56.PageRouteInfo<void> {
  const AssignmentManagementRoute({List<_i56.PageRouteInfo>? children})
      : super(
          AssignmentManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'AssignmentManagementRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i7.AuthPage]
class AuthRoute extends _i56.PageRouteInfo<void> {
  const AuthRoute({List<_i56.PageRouteInfo>? children})
      : super(
          AuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i8.CartPage]
class CartRoute extends _i56.PageRouteInfo<void> {
  const CartRoute({List<_i56.PageRouteInfo>? children})
      : super(
          CartRoute.name,
          initialChildren: children,
        );

  static const String name = 'CartRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i9.CategoryManagementPage]
class CategoryManagementRoute extends _i56.PageRouteInfo<void> {
  const CategoryManagementRoute({List<_i56.PageRouteInfo>? children})
      : super(
          CategoryManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'CategoryManagementRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i10.CheckoutPage]
class CheckoutRoute extends _i56.PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    _i57.Key? key,
    required String restaurantName,
    required List<Map<String, dynamic>> cartItems,
    List<_i56.PageRouteInfo>? children,
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

  static const _i56.PageInfo<CheckoutRouteArgs> page =
      _i56.PageInfo<CheckoutRouteArgs>(name);
}

class CheckoutRouteArgs {
  const CheckoutRouteArgs({
    this.key,
    required this.restaurantName,
    required this.cartItems,
  });

  final _i57.Key? key;

  final String restaurantName;

  final List<Map<String, dynamic>> cartItems;

  @override
  String toString() {
    return 'CheckoutRouteArgs{key: $key, restaurantName: $restaurantName, cartItems: $cartItems}';
  }
}

/// generated route for
/// [_i11.DeliveryAdminDashboardPage]
class DeliveryAdminDashboardRoute extends _i56.PageRouteInfo<void> {
  const DeliveryAdminDashboardRoute({List<_i56.PageRouteInfo>? children})
      : super(
          DeliveryAdminDashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryAdminDashboardRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i12.DeliveryAssignmentPage]
class DeliveryAssignmentRoute extends _i56.PageRouteInfo<void> {
  const DeliveryAssignmentRoute({List<_i56.PageRouteInfo>? children})
      : super(
          DeliveryAssignmentRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryAssignmentRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i13.DeliveryDashboardPage]
class DeliveryDashboardRoute extends _i56.PageRouteInfo<void> {
  const DeliveryDashboardRoute({List<_i56.PageRouteInfo>? children})
      : super(
          DeliveryDashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryDashboardRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i14.DeliveryDetailPage]
class DeliveryDetailRoute extends _i56.PageRouteInfo<DeliveryDetailRouteArgs> {
  DeliveryDetailRoute({
    _i57.Key? key,
    required _i58.DeliveryOrder order,
    List<_i56.PageRouteInfo>? children,
  }) : super(
          DeliveryDetailRoute.name,
          args: DeliveryDetailRouteArgs(
            key: key,
            order: order,
          ),
          initialChildren: children,
        );

  static const String name = 'DeliveryDetailRoute';

  static const _i56.PageInfo<DeliveryDetailRouteArgs> page =
      _i56.PageInfo<DeliveryDetailRouteArgs>(name);
}

class DeliveryDetailRouteArgs {
  const DeliveryDetailRouteArgs({
    this.key,
    required this.order,
  });

  final _i57.Key? key;

  final _i58.DeliveryOrder order;

  @override
  String toString() {
    return 'DeliveryDetailRouteArgs{key: $key, order: $order}';
  }
}

/// generated route for
/// [_i15.DeliveryListPage]
class DeliveryListRoute extends _i56.PageRouteInfo<void> {
  const DeliveryListRoute({List<_i56.PageRouteInfo>? children})
      : super(
          DeliveryListRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryListRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i16.DeliveryOrdersPage]
class DeliveryOrdersRoute extends _i56.PageRouteInfo<void> {
  const DeliveryOrdersRoute({List<_i56.PageRouteInfo>? children})
      : super(
          DeliveryOrdersRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryOrdersRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i17.DeliveryProfilePage]
class DeliveryProfileRoute extends _i56.PageRouteInfo<void> {
  const DeliveryProfileRoute({List<_i56.PageRouteInfo>? children})
      : super(
          DeliveryProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryProfileRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i18.DeliveryUserManagementPage]
class DeliveryUserManagementRoute extends _i56.PageRouteInfo<void> {
  const DeliveryUserManagementRoute({List<_i56.PageRouteInfo>? children})
      : super(
          DeliveryUserManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryUserManagementRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i19.DishDetailPage]
class DishDetailRoute extends _i56.PageRouteInfo<DishDetailRouteArgs> {
  DishDetailRoute({
    _i57.Key? key,
    required String id,
    required String restaurantId,
    required String name,
    required String price,
    required String imageUrl,
    required String rating,
    required String description,
    List<_i56.PageRouteInfo>? children,
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

  static const _i56.PageInfo<DishDetailRouteArgs> page =
      _i56.PageInfo<DishDetailRouteArgs>(name);
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

  final _i57.Key? key;

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
/// [_i20.DishImageEditorPage]
class DishImageEditorRoute
    extends _i56.PageRouteInfo<DishImageEditorRouteArgs> {
  DishImageEditorRoute({
    _i57.Key? key,
    required _i59.DishModel dish,
    List<_i56.PageRouteInfo>? children,
  }) : super(
          DishImageEditorRoute.name,
          args: DishImageEditorRouteArgs(
            key: key,
            dish: dish,
          ),
          initialChildren: children,
        );

  static const String name = 'DishImageEditorRoute';

  static const _i56.PageInfo<DishImageEditorRouteArgs> page =
      _i56.PageInfo<DishImageEditorRouteArgs>(name);
}

class DishImageEditorRouteArgs {
  const DishImageEditorRouteArgs({
    this.key,
    required this.dish,
  });

  final _i57.Key? key;

  final _i59.DishModel dish;

  @override
  String toString() {
    return 'DishImageEditorRouteArgs{key: $key, dish: $dish}';
  }
}

/// generated route for
/// [_i21.DishListPage]
class DishListRoute extends _i56.PageRouteInfo<DishListRouteArgs> {
  DishListRoute({
    _i57.Key? key,
    required String restaurantId,
    List<_i56.PageRouteInfo>? children,
  }) : super(
          DishListRoute.name,
          args: DishListRouteArgs(
            key: key,
            restaurantId: restaurantId,
          ),
          initialChildren: children,
        );

  static const String name = 'DishListRoute';

  static const _i56.PageInfo<DishListRouteArgs> page =
      _i56.PageInfo<DishListRouteArgs>(name);
}

class DishListRouteArgs {
  const DishListRouteArgs({
    this.key,
    required this.restaurantId,
  });

  final _i57.Key? key;

  final String restaurantId;

  @override
  String toString() {
    return 'DishListRouteArgs{key: $key, restaurantId: $restaurantId}';
  }
}

/// generated route for
/// [_i22.DishManagementPage]
class DishManagementRoute extends _i56.PageRouteInfo<void> {
  const DishManagementRoute({List<_i56.PageRouteInfo>? children})
      : super(
          DishManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'DishManagementRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i23.EarningsPage]
class EarningsRoute extends _i56.PageRouteInfo<void> {
  const EarningsRoute({List<_i56.PageRouteInfo>? children})
      : super(
          EarningsRoute.name,
          initialChildren: children,
        );

  static const String name = 'EarningsRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i24.HomeDeliveryPage]
class HomeDeliveryRoute extends _i56.PageRouteInfo<void> {
  const HomeDeliveryRoute({List<_i56.PageRouteInfo>? children})
      : super(
          HomeDeliveryRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeDeliveryRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i25.HomePage]
class HomeRoute extends _i56.PageRouteInfo<void> {
  const HomeRoute({List<_i56.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i26.HomeRestaurantPage]
class HomeRestaurantRoute extends _i56.PageRouteInfo<HomeRestaurantRouteArgs> {
  HomeRestaurantRoute({
    _i57.Key? key,
    required _i60.HomeOption option,
    List<_i56.PageRouteInfo>? children,
  }) : super(
          HomeRestaurantRoute.name,
          args: HomeRestaurantRouteArgs(
            key: key,
            option: option,
          ),
          initialChildren: children,
        );

  static const String name = 'HomeRestaurantRoute';

  static const _i56.PageInfo<HomeRestaurantRouteArgs> page =
      _i56.PageInfo<HomeRestaurantRouteArgs>(name);
}

class HomeRestaurantRouteArgs {
  const HomeRestaurantRouteArgs({
    this.key,
    required this.option,
  });

  final _i57.Key? key;

  final _i60.HomeOption option;

  @override
  String toString() {
    return 'HomeRestaurantRouteArgs{key: $key, option: $option}';
  }
}

/// generated route for
/// [_i27.ImageManagementPage]
class ImageManagementRoute extends _i56.PageRouteInfo<void> {
  const ImageManagementRoute({List<_i56.PageRouteInfo>? children})
      : super(
          ImageManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'ImageManagementRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i28.InfoUserPage]
class InfoUserRoute extends _i56.PageRouteInfo<void> {
  const InfoUserRoute({List<_i56.PageRouteInfo>? children})
      : super(
          InfoUserRoute.name,
          initialChildren: children,
        );

  static const String name = 'InfoUserRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i29.LieuPage]
class LieuRoute extends _i56.PageRouteInfo<LieuRouteArgs> {
  LieuRoute({
    _i57.Key? key,
    required String phoneNumber,
    required String typeProduit,
    bool isReception = false,
    required String ville,
    String? colisDescription,
    List<dynamic>? colisList,
    List<_i56.PageRouteInfo>? children,
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

  static const _i56.PageInfo<LieuRouteArgs> page =
      _i56.PageInfo<LieuRouteArgs>(name);
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

  final _i57.Key? key;

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
/// [_i30.LikedDishesPage]
class LikedDishesRoute extends _i56.PageRouteInfo<void> {
  const LikedDishesRoute({List<_i56.PageRouteInfo>? children})
      : super(
          LikedDishesRoute.name,
          initialChildren: children,
        );

  static const String name = 'LikedDishesRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i31.ModernDishDetailPage]
class ModernDishDetailRoute
    extends _i56.PageRouteInfo<ModernDishDetailRouteArgs> {
  ModernDishDetailRoute({
    required String id,
    required String restaurantId,
    required String name,
    required String price,
    required String imageUrl,
    required String rating,
    required String description,
    List<_i56.PageRouteInfo>? children,
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

  static const _i56.PageInfo<ModernDishDetailRouteArgs> page =
      _i56.PageInfo<ModernDishDetailRouteArgs>(name);
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
/// [_i32.ModernHomeRestaurantPage]
class ModernHomeRestaurantRoute
    extends _i56.PageRouteInfo<ModernHomeRestaurantRouteArgs> {
  ModernHomeRestaurantRoute({
    _i57.Key? key,
    required _i60.HomeOption option,
    List<_i56.PageRouteInfo>? children,
  }) : super(
          ModernHomeRestaurantRoute.name,
          args: ModernHomeRestaurantRouteArgs(
            key: key,
            option: option,
          ),
          initialChildren: children,
        );

  static const String name = 'ModernHomeRestaurantRoute';

  static const _i56.PageInfo<ModernHomeRestaurantRouteArgs> page =
      _i56.PageInfo<ModernHomeRestaurantRouteArgs>(name);
}

class ModernHomeRestaurantRouteArgs {
  const ModernHomeRestaurantRouteArgs({
    this.key,
    required this.option,
  });

  final _i57.Key? key;

  final _i60.HomeOption option;

  @override
  String toString() {
    return 'ModernHomeRestaurantRouteArgs{key: $key, option: $option}';
  }
}

/// generated route for
/// [_i33.ModernRestaurantDetailPage]
class ModernRestaurantDetailRoute
    extends _i56.PageRouteInfo<ModernRestaurantDetailRouteArgs> {
  ModernRestaurantDetailRoute({
    _i57.Key? key,
    required String id,
    required String name,
    required String description,
    required String coverImage,
    List<_i56.PageRouteInfo>? children,
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

  static const _i56.PageInfo<ModernRestaurantDetailRouteArgs> page =
      _i56.PageInfo<ModernRestaurantDetailRouteArgs>(name);
}

class ModernRestaurantDetailRouteArgs {
  const ModernRestaurantDetailRouteArgs({
    this.key,
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
  });

  final _i57.Key? key;

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
/// [_i34.NotificationsPage]
class NotificationsRoute extends _i56.PageRouteInfo<void> {
  const NotificationsRoute({List<_i56.PageRouteInfo>? children})
      : super(
          NotificationsRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationsRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i35.OrderDetailPage]
class OrderDetailRoute extends _i56.PageRouteInfo<OrderDetailRouteArgs> {
  OrderDetailRoute({
    _i57.Key? key,
    required _i61.Order order,
    List<_i56.PageRouteInfo>? children,
  }) : super(
          OrderDetailRoute.name,
          args: OrderDetailRouteArgs(
            key: key,
            order: order,
          ),
          initialChildren: children,
        );

  static const String name = 'OrderDetailRoute';

  static const _i56.PageInfo<OrderDetailRouteArgs> page =
      _i56.PageInfo<OrderDetailRouteArgs>(name);
}

class OrderDetailRouteArgs {
  const OrderDetailRouteArgs({
    this.key,
    required this.order,
  });

  final _i57.Key? key;

  final _i61.Order order;

  @override
  String toString() {
    return 'OrderDetailRouteArgs{key: $key, order: $order}';
  }
}

/// generated route for
/// [_i36.OrderListPage]
class OrderListRoute extends _i56.PageRouteInfo<OrderListRouteArgs> {
  OrderListRoute({
    _i57.Key? key,
    required String phoneNumber,
    List<_i56.PageRouteInfo>? children,
  }) : super(
          OrderListRoute.name,
          args: OrderListRouteArgs(
            key: key,
            phoneNumber: phoneNumber,
          ),
          initialChildren: children,
        );

  static const String name = 'OrderListRoute';

  static const _i56.PageInfo<OrderListRouteArgs> page =
      _i56.PageInfo<OrderListRouteArgs>(name);
}

class OrderListRouteArgs {
  const OrderListRouteArgs({
    this.key,
    required this.phoneNumber,
  });

  final _i57.Key? key;

  final String phoneNumber;

  @override
  String toString() {
    return 'OrderListRouteArgs{key: $key, phoneNumber: $phoneNumber}';
  }
}

/// generated route for
/// [_i37.OrderManagementPage]
class OrderManagementRoute extends _i56.PageRouteInfo<void> {
  const OrderManagementRoute({List<_i56.PageRouteInfo>? children})
      : super(
          OrderManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'OrderManagementRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i38.OtpPage]
class OtpRoute extends _i56.PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    required String verificationId,
    _i57.Key? key,
    List<_i56.PageRouteInfo>? children,
  }) : super(
          OtpRoute.name,
          args: OtpRouteArgs(
            verificationId: verificationId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'OtpRoute';

  static const _i56.PageInfo<OtpRouteArgs> page =
      _i56.PageInfo<OtpRouteArgs>(name);
}

class OtpRouteArgs {
  const OtpRouteArgs({
    required this.verificationId,
    this.key,
  });

  final String verificationId;

  final _i57.Key? key;

  @override
  String toString() {
    return 'OtpRouteArgs{verificationId: $verificationId, key: $key}';
  }
}

/// generated route for
/// [_i39.ParcelDetailPage]
class ParcelDetailRoute extends _i56.PageRouteInfo<ParcelDetailRouteArgs> {
  ParcelDetailRoute({
    _i57.Key? key,
    required _i62.Parcel parcel,
    List<_i56.PageRouteInfo>? children,
  }) : super(
          ParcelDetailRoute.name,
          args: ParcelDetailRouteArgs(
            key: key,
            parcel: parcel,
          ),
          initialChildren: children,
        );

  static const String name = 'ParcelDetailRoute';

  static const _i56.PageInfo<ParcelDetailRouteArgs> page =
      _i56.PageInfo<ParcelDetailRouteArgs>(name);
}

class ParcelDetailRouteArgs {
  const ParcelDetailRouteArgs({
    this.key,
    required this.parcel,
  });

  final _i57.Key? key;

  final _i62.Parcel parcel;

  @override
  String toString() {
    return 'ParcelDetailRouteArgs{key: $key, parcel: $parcel}';
  }
}

/// generated route for
/// [_i40.ParcelHomePage]
class ParcelHomeRoute extends _i56.PageRouteInfo<void> {
  const ParcelHomeRoute({List<_i56.PageRouteInfo>? children})
      : super(
          ParcelHomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'ParcelHomeRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i41.ParcelListPage]
class ParcelListRoute extends _i56.PageRouteInfo<void> {
  const ParcelListRoute({List<_i56.PageRouteInfo>? children})
      : super(
          ParcelListRoute.name,
          initialChildren: children,
        );

  static const String name = 'ParcelListRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i42.ProfilePage]
class ProfileRoute extends _i56.PageRouteInfo<void> {
  const ProfileRoute({List<_i56.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i43.RestaurantDetailPage]
class RestaurantDetailRoute
    extends _i56.PageRouteInfo<RestaurantDetailRouteArgs> {
  RestaurantDetailRoute({
    _i57.Key? key,
    required String id,
    required String name,
    required String description,
    required String coverImage,
    List<_i56.PageRouteInfo>? children,
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

  static const _i56.PageInfo<RestaurantDetailRouteArgs> page =
      _i56.PageInfo<RestaurantDetailRouteArgs>(name);
}

class RestaurantDetailRouteArgs {
  const RestaurantDetailRouteArgs({
    this.key,
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
  });

  final _i57.Key? key;

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
/// [_i44.RestaurantEditPage]
class RestaurantEditRoute extends _i56.PageRouteInfo<RestaurantEditRouteArgs> {
  RestaurantEditRoute({
    _i57.Key? key,
    String? restaurantId,
    List<_i56.PageRouteInfo>? children,
  }) : super(
          RestaurantEditRoute.name,
          args: RestaurantEditRouteArgs(
            key: key,
            restaurantId: restaurantId,
          ),
          initialChildren: children,
        );

  static const String name = 'RestaurantEditRoute';

  static const _i56.PageInfo<RestaurantEditRouteArgs> page =
      _i56.PageInfo<RestaurantEditRouteArgs>(name);
}

class RestaurantEditRouteArgs {
  const RestaurantEditRouteArgs({
    this.key,
    this.restaurantId,
  });

  final _i57.Key? key;

  final String? restaurantId;

  @override
  String toString() {
    return 'RestaurantEditRouteArgs{key: $key, restaurantId: $restaurantId}';
  }
}

/// generated route for
/// [_i45.RestaurantManagementPage]
class RestaurantManagementRoute extends _i56.PageRouteInfo<void> {
  const RestaurantManagementRoute({List<_i56.PageRouteInfo>? children})
      : super(
          RestaurantManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'RestaurantManagementRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i46.RestaurantSelectPage]
class RestaurantSelectRoute extends _i56.PageRouteInfo<void> {
  const RestaurantSelectRoute({List<_i56.PageRouteInfo>? children})
      : super(
          RestaurantSelectRoute.name,
          initialChildren: children,
        );

  static const String name = 'RestaurantSelectRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i47.RolePermissionManagementPage]
class RolePermissionManagementRoute extends _i56.PageRouteInfo<void> {
  const RolePermissionManagementRoute({List<_i56.PageRouteInfo>? children})
      : super(
          RolePermissionManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'RolePermissionManagementRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i48.SearchPage]
class SearchRoute extends _i56.PageRouteInfo<void> {
  const SearchRoute({List<_i56.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i49.ShareLocationPage]
class ShareLocationRoute extends _i56.PageRouteInfo<void> {
  const ShareLocationRoute({List<_i56.PageRouteInfo>? children})
      : super(
          ShareLocationRoute.name,
          initialChildren: children,
        );

  static const String name = 'ShareLocationRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i50.SplashDeliveryPage]
class SplashDeliveryRoute extends _i56.PageRouteInfo<void> {
  const SplashDeliveryRoute({List<_i56.PageRouteInfo>? children})
      : super(
          SplashDeliveryRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashDeliveryRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i51.StatisticsPage]
class StatisticsRoute extends _i56.PageRouteInfo<void> {
  const StatisticsRoute({List<_i56.PageRouteInfo>? children})
      : super(
          StatisticsRoute.name,
          initialChildren: children,
        );

  static const String name = 'StatisticsRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i52.StatusPage]
class StatusRoute extends _i56.PageRouteInfo<void> {
  const StatusRoute({List<_i56.PageRouteInfo>? children})
      : super(
          StatusRoute.name,
          initialChildren: children,
        );

  static const String name = 'StatusRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i53.TestBeveragesPage]
class TestBeveragesRoute extends _i56.PageRouteInfo<void> {
  const TestBeveragesRoute({List<_i56.PageRouteInfo>? children})
      : super(
          TestBeveragesRoute.name,
          initialChildren: children,
        );

  static const String name = 'TestBeveragesRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i54.TestUsersManagementPage]
class TestUsersManagementRoute extends _i56.PageRouteInfo<void> {
  const TestUsersManagementRoute({List<_i56.PageRouteInfo>? children})
      : super(
          TestUsersManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'TestUsersManagementRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}

/// generated route for
/// [_i55.UserManagementPage]
class UserManagementRoute extends _i56.PageRouteInfo<void> {
  const UserManagementRoute({List<_i56.PageRouteInfo>? children})
      : super(
          UserManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'UserManagementRoute';

  static const _i56.PageInfo<void> page = _i56.PageInfo<void>(name);
}
