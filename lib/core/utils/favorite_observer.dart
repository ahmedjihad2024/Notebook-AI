// 1. Observer Interface
abstract class FavoritesObserver {
  void onFavoritesChanged(
    Map<int, bool> favoriteProviders,
    Map<int, bool> favoriteProducts,
  );
}

// 2. Observable - FavoritesManager (Singleton)
class FavoritesManager {
  static final FavoritesManager instance = FavoritesManager._internal();
  FavoritesManager._internal();

  // Separate maps for providers (salons, clinics, etc.) and products
  final Map<int, bool> _favoriteProviders = {};
  final Map<int, bool> _favoriteProducts = {};
  final List<FavoritesObserver> _observers = [];

  // Get current favorites
  Map<int, bool> get favoriteProviders => Map.unmodifiable(_favoriteProviders);
  Map<int, bool> get favoriteProducts => Map.unmodifiable(_favoriteProducts);

  // Register observer
  void addObserver(FavoritesObserver observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  // Unregister observer
  void removeObserver(FavoritesObserver observer) {
    _observers.remove(observer);
  }

  // ========== Provider (Salons, Clinics, etc.) Methods ==========

  // Toggle provider favorite
  void toggleProviderFavorite(int providerId) {
    if (_favoriteProviders.containsKey(providerId)) {
      _favoriteProviders[providerId] = !_favoriteProviders[providerId]!;
    } else {
      _favoriteProviders[providerId] = true;
    }
    _notifyObservers();
  }

  // Add provider to favorites
  void addProviderToFavorites(int providerId) {
    _favoriteProviders[providerId] = true;
    _notifyObservers();
  }

  // Remove provider from favorites
  void removeProviderFromFavorites(int providerId) {
    _favoriteProviders[providerId] = false;
    _notifyObservers();
  }

  // Check if provider is favorite
  bool isProviderFavorite(int providerId) {
    return _favoriteProviders[providerId] ?? false;
  }

  // Clear all provider favorites
  void clearProviderFavorites() {
    _favoriteProviders.clear();
    _notifyObservers();
  }

  // ========== Product Methods ==========

  // Toggle product favorite
  void toggleProductFavorite(int productId) {
    if (_favoriteProducts.containsKey(productId)) {
      _favoriteProducts[productId] = !_favoriteProducts[productId]!;
    } else {
      _favoriteProducts[productId] = true;
    }
    _notifyObservers();
  }

  // Add product to favorites
  void addProductToFavorites(int productId) {
    _favoriteProducts[productId] = true;
    _notifyObservers();
  }

  // Remove product from favorites
  void removeProductFromFavorites(int productId) {
    _favoriteProducts[productId] = false;
    _notifyObservers();
  }

  // Check if product is favorite
  bool isProductFavorite(int productId) {
    return _favoriteProducts[productId] ?? false;
  }

  // Clear all product favorites
  void clearProductFavorites() {
    _favoriteProducts.clear();
    _notifyObservers();
  }

  // ========== General Methods ==========

  // Clear all favorites (both providers and products)
  void clearAllFavorites() {
    _favoriteProviders.clear();
    _favoriteProducts.clear();
    _notifyObservers();
  }

  // Notify all observers
  void _notifyObservers() {
    for (var observer in _observers) {
      observer.onFavoritesChanged(_favoriteProviders, _favoriteProducts);
    }
  }

  // Get all favorite provider IDs (only true values)
  List<int> getFavoriteProviderIds() {
    return _favoriteProviders.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }

  // Get all favorite product IDs (only true values)
  List<int> getFavoriteProductIds() {
    return _favoriteProducts.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }
}

//
// // 3. Example Home BLoC Implementation
// class HomeBloc extends Bloc<HomeEvent, HomeState> implements FavoritesObserver {
//   final FavoritesManager _favoritesManager = FavoritesManager();
//
//   HomeBloc() : super(HomeInitial()) {
//     // Register as observer
//     _favoritesManager.addObserver(this);
//
//     on<LoadHomeEvent>(_onLoadHome);
//     on<UpdateFavoritesStatusEvent>(_onUpdateFavoritesStatus);
//   }
//
//   @override
//   void onFavoritesChanged(Set<String> favoriteIds) {
//     // This will be called automatically when favorites change
//     add(UpdateFavoritesStatusEvent(favoriteIds));
//   }
//
//   void _onLoadHome(LoadHomeEvent event, Emitter<HomeState> emit) async {
//     emit(HomeLoading());
//
//     // Load your products
//     final products = await fetchProducts();
//
//     emit(HomeLoaded(
//       products: products,
//       favoriteIds: _favoritesManager.favoriteIds,
//     ));
//   }
//
//   void _onUpdateFavoritesStatus(
//       UpdateFavoritesStatusEvent event,
//       Emitter<HomeState> emit,
//       ) {
//     if (state is HomeLoaded) {
//       final currentState = state as HomeLoaded;
//       emit(currentState.copyWith(favoriteIds: event.favoriteIds));
//     }
//   }
//
//   @override
//   Future<void> close() {
//     // Unregister observer when bloc is disposed
//     _favoritesManager.removeObserver(this);
//     return super.close();
//   }
// }
//
// // Home Events
// abstract class HomeEvent {}
//
// class LoadHomeEvent extends HomeEvent {}
//
// class UpdateFavoritesStatusEvent extends HomeEvent {
//   final Set<String> favoriteIds;
//   UpdateFavoritesStatusEvent(this.favoriteIds);
// }
//
// // Home State
// abstract class HomeState {}
//
// class HomeInitial extends HomeState {}
//
// class HomeLoading extends HomeState {}
//
// class HomeLoaded extends HomeState {
//   final List<Product> products;
//   final Set<String> favoriteIds;
//
//   HomeLoaded({
//     required this.products,
//     required this.favoriteIds,
//   });
//
//   HomeLoaded copyWith({
//     List<Product>? products,
//     Set<String>? favoriteIds,
//   }) {
//     return HomeLoaded(
//       products: products ?? this.products,
//       favoriteIds: favoriteIds ?? this.favoriteIds,
//     );
//   }
// }
//
// // 4. Example Search BLoC Implementation
// class SearchBloc extends Bloc<SearchEvent, SearchState> implements FavoritesObserver {
//   final FavoritesManager _favoritesManager = FavoritesManager();
//
//   SearchBloc() : super(SearchInitial()) {
//     _favoritesManager.addObserver(this);
//
//     on<SearchProductsEvent>(_onSearchProducts);
//     on<UpdateSearchFavoritesStatusEvent>(_onUpdateFavoritesStatus);
//   }
//
//   @override
//   void onFavoritesChanged(Set<String> favoriteIds) {
//     add(UpdateSearchFavoritesStatusEvent(favoriteIds));
//   }
//
//   void _onSearchProducts(SearchProductsEvent event, Emitter<SearchState> emit) async {
//     emit(SearchLoading());
//
//     final products = await searchProducts(event.query);
//
//     emit(SearchLoaded(
//       products: products,
//       favoriteIds: _favoritesManager.favoriteIds,
//     ));
//   }
//
//   void _onUpdateFavoritesStatus(
//       UpdateSearchFavoritesStatusEvent event,
//       Emitter<SearchState> emit,
//       ) {
//     if (state is SearchLoaded) {
//       final currentState = state as SearchLoaded;
//       emit(currentState.copyWith(favoriteIds: event.favoriteIds));
//     }
//   }
//
//   @override
//   Future<void> close() {
//     _favoritesManager.removeObserver(this);
//     return super.close();
//   }
// }
//
// // Search Events
// abstract class SearchEvent {}
//
// class SearchProductsEvent extends SearchEvent {
//   final String query;
//   SearchProductsEvent(this.query);
// }
//
// class UpdateSearchFavoritesStatusEvent extends SearchEvent {
//   final Set<String> favoriteIds;
//   UpdateSearchFavoritesStatusEvent(this.favoriteIds);
// }
//
// // Search State
// abstract class SearchState {}
//
// class SearchInitial extends SearchState {}
//
// class SearchLoading extends SearchState {}
//
// class SearchLoaded extends SearchState {
//   final List<Product> products;
//   final Set<String> favoriteIds;
//
//   SearchLoaded({
//     required this.products,
//     required this.favoriteIds,
//   });
//
//   SearchLoaded copyWith({
//     List<Product>? products,
//     Set<String>? favoriteIds,
//   }) {
//     return SearchLoaded(
//       products: products ?? this.products,
//       favoriteIds: favoriteIds ?? this.favoriteIds,
//     );
//   }
// }
//
// // 5. UI Usage Example
// class ProductCard extends StatelessWidget {
//   final Product product;
//
//   const ProductCard({Key? key, required this.product}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final favoritesManager = FavoritesManager();
//
//     return BlocBuilder<HomeBloc, HomeState>(
//       builder: (context, state) {
//         if (state is HomeLoaded) {
//           final isFavorite = state.favoriteIds.contains(product.id);
//
//           return Card(
//             child: Column(
//               children: [
//                 Text(product.name),
//                 IconButton(
//                   icon: Icon(
//                     isFavorite ? Icons.favorite : Icons.favorite_border,
//                     color: isFavorite ? Colors.red : Colors.grey,
//                   ),
//                   onPressed: () {
//                     favoritesManager.toggleFavorite(product.id);
//                   },
//                 ),
//               ],
//             ),
//           );
//         }
//         return const SizedBox();
//       },
//     );
//   }
// }
//
// // Product Model (placeholder)
// class Product {
//   final String id;
//   final String name;
//
//   Product({required this.id, required this.name});
// }
//
// // Placeholder functions
// Future<List<Product>> fetchProducts() async {
//   // Your implementation
//   return [];
// }
//
// Future<List<Product>> searchProducts(String query) async {
//   // Your implementation
//   return [];
// }
