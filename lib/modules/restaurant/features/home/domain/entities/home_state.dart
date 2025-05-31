class HomeState {
  final List<dynamic>? restaurants;
  final bool isLoading;
  final String? error;

  HomeState({
    this.restaurants,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<dynamic>? restaurants,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
