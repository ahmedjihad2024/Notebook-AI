import 'package:dartz/dartz.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// State-management–agnostic pagination helper.
///
/// Mix it into anything that holds a state value and can publish a new one —
/// a Riverpod `Notifier`, a `Bloc`/`Cubit`, a `ChangeNotifier`, or a plain
/// class. It tracks the current page per list (so one object can paginate
/// several lists via [key]) and wires up `pull_to_refresh` if you use it.
///
/// You stay in control of *state*: instead of emitting directly, you pass
/// builder callbacks ([loadingState], [errorState], [emptyState],
/// [successState]) and an [emit] sink that applies the new state.
///
/// ### Riverpod
/// ```dart
/// class ProductsNotifier extends Notifier<ProductsState>
///     with PaginationMixin {
///   void load({bool refresh = false}) => handlePagination<Product, ProductsState, Failure>(
///         key: 'products',
///         controller: refreshController,        // optional
///         isRefresh: refresh,
///         emit: (s) => state = s,               // <- Riverpod
///         currentItems: state.items,
///         fetchData: (page) => _repo.products(page),
///         loadingState: () => state.copyWith(reqState: ReqState.loading),
///         errorState: (f) => state.copyWith(reqState: ReqState.error, failure: f),
///         emptyState: () => state.copyWith(reqState: ReqState.empty, items: []),
///         successState: (items, isRefresh) =>
///             state.copyWith(reqState: ReqState.data, items: items),
///       );
/// }
/// ```
///
/// ### Bloc / Cubit
/// Identical, except `emit: (s) => emit(s)`.
mixin PaginationMixin {
  /// Current page per list key.
  final Map<String, int> _pages = {};

  /// Current page for [key] (starts at 1).
  int getPage(String key) => _pages[key] ?? 1;

  /// Overwrite the page for [key].
  void setPage(String key, int page) => _pages[key] = page;

  /// Advance [key] to the next page.
  void incrementPage(String key) => _pages[key] = getPage(key) + 1;

  /// Reset [key] back to the first page.
  void resetPage(String key) => _pages[key] = 1;

  /// Drives one fetch of a paginated list.
  ///
  /// - [T] is the item type, [S] your state type, [F] your failure type.
  /// - On [isRefresh] it resets to page 1, emits [loadingState] and completes
  ///   the refresh indicator; otherwise it appends the next page to
  ///   [currentItems].
  /// - [controller] is optional: pass your `pull_to_refresh` controller to get
  ///   footer states (load complete / no-data / failed) handled for you, or
  ///   omit it entirely.
  Future<void> handlePagination<T, S, F>({
    required String key,
    required bool isRefresh,
    required void Function(S state) emit,
    required List<T> currentItems,
    required Future<Either<F, PaginatedResponse<T>>> Function(int page)
    fetchData,
    required S Function() loadingState,
    required S Function(F failure) errorState,
    required S Function() emptyState,
    required S Function(List<T> items, bool isRefresh) successState,
    RefreshController? controller,
  }) async {
    var currentPage = getPage(key);

    if (isRefresh) {
      resetPage(key);
      currentPage = 1;
      emit(loadingState());
      controller?.refreshCompleted(resetFooterState: true);
    }

    final response = await fetchData(currentPage);

    response.fold(
      (failure) {
        // On load-more let the footer show the failure; on refresh surface it
        // through state.
        if (isRefresh) {
          emit(errorState(failure));
        } else {
          controller?.loadFailed();
        }
      },
      (data) {
        if (data.items.isEmpty) {
          if (isRefresh) {
            emit(emptyState());
          } else {
            controller?.loadNoData();
          }
          return;
        }

        if (!data.meta.hasMore) {
          controller?.loadNoData();
        } else if (!isRefresh) {
          controller?.loadComplete();
        }

        incrementPage(key);

        emit(
          successState(
            isRefresh ? data.items : [...currentItems, ...data.items],
            isRefresh,
          ),
        );
      },
    );
  }

  /// Clear all tracked pages. Call from your dispose/close.
  /// (Refresh controllers are owned by you.)
  void disposePagination() => _pages.clear();
}

/// Generic paginated response — your data layer maps an API response into this.
class PaginatedResponse<T> {
  final List<T> items;
  final PaginationMeta meta;

  const PaginatedResponse({required this.items, required this.meta});
}

/// Pagination metadata describing the current position in the list.
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  /// Whether another page can be loaded after [currentPage].
  bool get hasMore => currentPage < lastPage;
}
