import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Adds a single, reusable periodic auto-refresh to any [Notifier].
///
/// Screens that need to poll (support chat, live order status, …) wire one line
/// instead of each managing its own [Timer] lifecycle. The timer is cancelled
/// automatically when the provider is disposed, and re-arming is safe — a new
/// call replaces the previous timer.
mixin AutoRefreshMixin<T> on Notifier<T> {
  Timer? _autoRefreshTimer;

  /// Starts (or restarts) a periodic refresh that calls [onTick] every
  /// [interval]. Cancellation is registered on the provider's disposal.
  void startAutoRefresh(Duration interval, FutureOr<void> Function() onTick) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(interval, (_) => onTick());
    ref.onDispose(stopAutoRefresh);
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }
}
