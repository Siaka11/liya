import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/restaurant_remote_data_source.dart';
import '../../data/models/restaurant_model.dart';

final restaurantDataSourceProvider =
    Provider<RestaurantRemoteDataSource>((ref) {
  return RestaurantRemoteDataSourceImpl();
});

class RestaurantState {
  final List<RestaurantModel> restaurants;
  final bool isLoading;
  final String? error;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  RestaurantState({
    required this.restaurants,
    required this.isLoading,
    this.error,
    this.lastDocument,
    required this.hasMore,
  });

  RestaurantState copyWith({
    List<RestaurantModel>? restaurants,
    bool? isLoading,
    String? error,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
  }) {
    return RestaurantState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class RestaurantNotifier extends StateNotifier<RestaurantState> {
  final RestaurantRemoteDataSource _dataSource;
  static const int _pageSize = 10;

  RestaurantNotifier(this._dataSource)
      : super(RestaurantState(
          restaurants: [],
          isLoading: false,
          hasMore: true,
        ));

  Future<void> loadInitialRestaurants() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final restaurants = await _dataSource.getRestaurants(limit: _pageSize);
      state = state.copyWith(
        restaurants: restaurants,
        isLoading: false,
        lastDocument: restaurants.isNotEmpty
            ? await _getLastDocument(restaurants.last.id)
            : null,
        hasMore: restaurants.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreRestaurants() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final restaurants = await _dataSource.getRestaurants(
        limit: _pageSize,
        lastDocument: state.lastDocument,
      );

      state = state.copyWith(
        restaurants: [...state.restaurants, ...restaurants],
        isLoading: false,
        lastDocument: restaurants.isNotEmpty
            ? await _getLastDocument(restaurants.last.id)
            : state.lastDocument,
        hasMore: restaurants.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<DocumentSnapshot?> _getLastDocument(String restaurantId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .get();
    } catch (e) {
      return null;
    }
  }

  Future<void> searchRestaurants(String query) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final restaurants = await _dataSource.searchRestaurants(query);
      state = state.copyWith(
        restaurants: restaurants,
        isLoading: false,
        lastDocument: null,
        hasMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final restaurantProvider =
    StateNotifierProvider<RestaurantNotifier, RestaurantState>((ref) {
  final dataSource = ref.watch(restaurantDataSourceProvider);
  return RestaurantNotifier(dataSource);
});
