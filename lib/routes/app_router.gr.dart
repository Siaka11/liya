// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;
import 'package:liya/modules/auth/auth_page.dart' as _i1;
import 'package:liya/modules/auth/info_user_page.dart' as _i3;
import 'package:liya/modules/auth/otp_page.dart' as _i4;
import 'package:liya/modules/home/HomePage.dart' as _i2;

abstract class $AppRouter extends _i5.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i5.PageFactory> pagesMap = {
    AuthRoute.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AuthPage(),
      );
    },
    HomeRoute.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.HomePage(),
      );
    },
    InfoUserRoute.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.InfoUserPage(),
      );
    },
    OtpRoute.name: (routeData) {
      final args = routeData.argsAs<OtpRouteArgs>();
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.OtpPage(
          args.verificationId,
          key: args.key,
        ),
      );
    },
  };
}

/// generated route for
/// [_i1.AuthPage]
class AuthRoute extends _i5.PageRouteInfo<void> {
  const AuthRoute({List<_i5.PageRouteInfo>? children})
      : super(
          AuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthRoute';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}

/// generated route for
/// [_i3.InfoUserPage]
class InfoUserRoute extends _i5.PageRouteInfo<void> {
  const InfoUserRoute({List<_i5.PageRouteInfo>? children})
      : super(
          InfoUserRoute.name,
          initialChildren: children,
        );

  static const String name = 'InfoUserRoute';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}

/// generated route for
/// [_i4.OtpPage]
class OtpRoute extends _i5.PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    required String verificationId,
    _i6.Key? key,
    List<_i5.PageRouteInfo>? children,
  }) : super(
          OtpRoute.name,
          args: OtpRouteArgs(
            verificationId: verificationId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'OtpRoute';

  static const _i5.PageInfo<OtpRouteArgs> page =
      _i5.PageInfo<OtpRouteArgs>(name);
}

class OtpRouteArgs {
  const OtpRouteArgs({
    required this.verificationId,
    this.key,
  });

  final String verificationId;

  final _i6.Key? key;

  @override
  String toString() {
    return 'OtpRouteArgs{verificationId: $verificationId, key: $key}';
  }
}
