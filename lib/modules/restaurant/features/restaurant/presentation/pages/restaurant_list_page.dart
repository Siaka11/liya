import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';

class RestaurantListPage extends ConsumerStatefulWidget {
  const RestaurantListPage({super.key});

  @override
  ConsumerState<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends ConsumerState<RestaurantListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
        () => ref.read(restaurantProvider.notifier).loadInitialRestaurants());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(restaurantProvider.notifier).loadMoreRestaurants();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(restaurantProvider.notifier).loadInitialRestaurants();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (state.error != null)
              SliverToBoxAdapter(
                child: ErrorMessageWidget(
                  message: state.error!,
                  onRetry: () {
                    ref
                        .read(restaurantProvider.notifier)
                        .loadInitialRestaurants();
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= state.restaurants.length) {
                        return null;
                      }
                      return RestaurantCard(
                        restaurant: state.restaurants[index],
                      );
                    },
                    childCount: state.restaurants.length,
                  ),
                ),
              ),
            if (state.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: LoadingIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
