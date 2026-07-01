import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:for_u/presentation/res/router/app_router.dart';
import 'package:for_u/presentation/views/captain/order_details/view/screens/captain_order_details_view.dart';
import 'package:for_u/presentation/views/cashier/order_details/view/screens/cashier_order_details_view.dart';
import 'package:for_u/presentation/views/user/order_details/view/screens/order_details_view.dart';
import 'package:for_u/presentation/views/user/support/view/screens/ticket_detail_view.dart';

/// Turns a tapped push notification into in-app navigation.
///
/// The backend stamps every push with its notification `type` (e.g.
/// `order.delivered`) alongside the target id (`order_id` / `ticket_id`). We
/// route on the type because the type already implies the audience — a captain
/// device only ever receives `delivery.*`, a branch device the `*_for_branch`
/// events, and a customer device the rest — so the screen follows from the type
/// without a separate role lookup.
class NotificationDeepLink {
  NotificationDeepLink._();

  /// A tap that arrived while the app was alive (foreground or background). The
  /// user is already on their home, so we can navigate straight away.
  static void handleTap(RemoteMessage message) {
    final target = _resolve(message.data);
    if (target == null) return;
    appRouter.pushNamed(target.routeName, extra: target.extra);
  }

  static void open({
    required String type,
    required Map<String, dynamic> payload,
  }) {
    final target = _resolve({'type': type, ...payload});
    if (target == null) return;
    appRouter.pushNamed(target.routeName, extra: target.extra);
  }

  /// A tap that cold-started the app. The notification is stashed and replayed
  /// by the splash once the session resolves and the user lands on their home;
  /// navigating any earlier would be wiped out by the splash's own redirect.
  static RemoteMessage? _pendingColdStart;

  static void stashColdStart(RemoteMessage message) =>
      _pendingColdStart = message;

  static void consumeColdStart() {
    final message = _pendingColdStart;
    if (message == null) return;
    _pendingColdStart = null;
    handleTap(message);
  }

  static _DeepLinkTarget? _resolve(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString();
    if (type.isEmpty) return null;

    final orderId = int.tryParse((data['order_id'] ?? '').toString());
    final ticketId = int.tryParse((data['ticket_id'] ?? '').toString());

    // Captain — new assignment / hand-off to another captain.
    if (type.startsWith('delivery.')) {
      if (orderId == null) return null;
      return _DeepLinkTarget(
        Routes.captainOrderDetails.name,
        CaptainOrderDetailsArgs(orderId: orderId),
      );
    }

    // Cashier — branch-facing order events.
    if (type == 'order.new_for_branch' || type == 'order.failed_for_branch') {
      if (orderId == null) return null;
      return _DeepLinkTarget(
        Routes.cashierOrderDetails.name,
        CashierOrderDetailsArgs(orderId: orderId),
      );
    }

    // Customer — every other order event opens the order details screen;
    // `order.delivered` additionally pops the rating sheet so the prompt to
    // "tap to rate" lands the customer straight on the rating.
    if (type.startsWith('order.')) {
      if (orderId == null) return null;
      return _DeepLinkTarget(
        Routes.orderDetails.name,
        OrderDetailsArgs(
          orderId: orderId,
          openRating: type == 'order.delivered',
        ),
      );
    }

    // Customer — support ticket updates.
    if (type.startsWith('support.')) {
      if (ticketId == null) return null;
      return _DeepLinkTarget(
        Routes.ticketDetail.name,
        TicketDetailArgs(id: ticketId),
      );
    }

    // billing.* / catalog.* / inventory.* / cashhandover.* / account.* have no
    // dedicated mobile screen — tapping simply brings the app to the front.
    return null;
  }
}

class _DeepLinkTarget {
  final String routeName;
  final Object extra;

  const _DeepLinkTarget(this.routeName, this.extra);
}
