import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/widget/dish_card.dart';
import '../../../home/presentation/widget/navigation_footer.dart';
import '../providers/search_provider.dart';
import 'package:liya/routes/app_router.gr.dart';
// TODO: adapte le chemin selon ton projet

@RoutePage(name: 'SearchRoute')
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _searchHistory = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    await ref.read(searchProvider.notifier).search(query);
    // Ajoute à l'historique si non déjà présent
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      });
    }
  }

  void _onHistoryTap(String query) {
    _controller.text = query;
    _onSearch();
  }

  void _removeHistoryItem(String query) {
    setState(() {
      _searchHistory.remove(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    print('Nombre de résultats : ${searchState.results.length}');

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Recherche', style: TextStyle(color: Colors.deepOrange)),
        leading: BackButton(
          color: Colors.deepOrange,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.deepOrange),
            onPressed: () {
              _controller.clear();
              ref.read(searchProvider.notifier).search('');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText: 'Recherche un plat...',
                prefixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.deepOrange),
                  onPressed: _onSearch,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.deepOrange),
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchProvider.notifier).search('');
                        },
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // Bord arrondi
                  borderSide:
                      BorderSide(color: Colors.deepOrange), // Couleur bord
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                      color: Colors.deepOrange,
                      width: 2), // Accentuation si focus
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepOrange),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
          ),
          if (_searchHistory.isNotEmpty)
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: _searchHistory
                    .map((query) => Chip(
                          label: GestureDetector(
                            onTap: () => _onHistoryTap(query),
                            child: Text(query),
                          ),
                          deleteIcon:
                              Icon(Icons.close, size: 18, color: Colors.grey),
                          onDeleted: () => _removeHistoryItem(query),
                        ))
                    .toList(),
              ),
            ),
          if (searchState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (searchState.error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Text(searchState.error!, style: TextStyle(color: Colors.red)),
            ),
          if (!searchState.isLoading && searchState.error == null)
            Expanded(
              child: searchState.results.isEmpty
                  ? Center(child: Text('Aucun résultat'))
                  : ListView.separated(
                      itemCount: searchState.results.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey[300]),
                      itemBuilder: (context, index) {
                        final dish = searchState.results[index];
                        return DishCard(
                          name: dish.name,
                          price: dish.price.toString(),
                          imageUrl: dish.imageUrl,
                          description: dish.description,
                          quantity: 0,
                          onTap: () {
                            // Navigation vers la page de détail du plat
                            context.router.push(
                              DishDetailRoute(
                                id: dish.id.toString(),
                                restaurantId: dish.restaurantId,
                                name: dish.name,
                                price: dish.price.toString(),
                                imageUrl: dish.imageUrl,
                                rating: '0', // Valeur par défaut
                                description: dish.description,
                              ),
                            );
                          },
                          onDelete: null,
                        );
                      },
                    ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationFooter(),
    );
  }
}
