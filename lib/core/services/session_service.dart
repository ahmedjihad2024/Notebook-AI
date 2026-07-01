import 'dart:async';
import 'dart:io' show Platform;

import 'package:for_u/app/services/storage_services/storage_service.dart';
import 'package:notebook_ai/core/request/auth/auth_request.dart';
import 'package:notebook_ai/core/response/auth/auth_response.dart';
import 'package:notebook_ai/core/network/error_handler/failure.dart';
import 'package:for_u/domain/usecase/get_me_usecase.dart';
import 'package:for_u/domain/usecase/logout_usecase.dart';
import 'package:for_u/domain/usecase/register_device_usecase.dart';
import 'package:for_u/domain/usecase/unregister_device_usecase.dart';

/// Where a cold start should land.
sealed class SessionStart {
  const SessionStart();
}

final class StartAuth extends SessionStart {
  const StartAuth();
}

final class StartHome extends SessionStart {
  final MobileRole role;
  const StartHome(this.role);
}

/// Owns the authenticated session: persisting it after verify-otp, restoring
/// it on cold start, and tearing it down on logout / forced sign-out.
///
/// The FCM token provider is injected so tests never touch Firebase and a
/// simulator without push support can still log in.
class SessionService {
  final StorageService _storage;
  final RegisterDeviceUseCase _registerDeviceUseCase;
  final GetMeUseCase _getMeUseCase;
  final UnregisterDeviceUseCase _unregisterDeviceUseCase;
  final LogoutUseCase _logoutUseCase;
  final Future<String?> Function() _fcmToken;

  /// Session-scoped state to wipe on teardown (the cart, injected by DI so
  /// this service never reaches into the widget layer).
  final void Function()? _onSessionCleared;

  SessionService(
    this._storage,
    this._fcmToken, {
    required RegisterDeviceUseCase registerDeviceUseCase,
    required GetMeUseCase getMeUseCase,
    required UnregisterDeviceUseCase unregisterDeviceUseCase,
    required LogoutUseCase logoutUseCase,
    void Function()? onSessionCleared,
  }) : _registerDeviceUseCase = registerDeviceUseCase,
       _getMeUseCase = getMeUseCase,
       _unregisterDeviceUseCase = unregisterDeviceUseCase,
       _logoutUseCase = logoutUseCase,
       _onSessionCleared = onSessionCleared;

  /// Persists a verified session and registers the device for push.
  /// Returns false (and stores nothing) when the backend refused a token
  /// (blocked account) or sent a role this app version doesn't know.
  Future<bool> establish(AuthSession session) async {
    final token = session.accessToken;
    final role = session.role;
    if (session.blocked || token == null || role == null) return false;

    await _storage.setToken(token);
    await _storage.setRole(role.value);
    unawaited(registerDeviceBestEffort());
    return true;
  }

  /// Push registration must never block or fail login — a simulator has no
  /// FCM token and the backend may be unreachable; the next login retries.
  Future<void> registerDeviceBestEffort() async {
    try {
      final fcm = await _fcmToken();
      if (fcm == null) return;
      await _registerDeviceUseCase.execute(
        RegisterDeviceBody(
          token: fcm,
          platform: Platform.isIOS ? 'ios' : 'android',
          locale: _storage.language?.languageCode ?? 'ar',
        ),
      );
    } catch (_) {
      // Best-effort by contract.
    }
  }

  Future<MobileRole?> storedRole() async =>
      MobileRole.tryFrom(await _storage.getRole());

  /// Resolves the cold-start destination. The stored session is validated
  /// against the backend when reachable; a dead session (expired token,
  /// suspended/deleted account) is cleared. When the backend is unreachable
  /// the stored role wins — being offline must not lock the user out.
  Future<SessionStart> resolveStart() async {
    final token = await _storage.getToken();
    if (token == null) return const StartAuth();

    final stored = await storedRole();
    if (stored == null) {
      // A token without a role predates role persistence; re-authenticate.
      await clearLocal();
      return const StartAuth();
    }

    final result = await _getMeUseCase.execute(null);
    return result.fold(
      (failure) async {
        if (_isSessionDead(failure)) {
          await clearLocal();
          return const StartAuth();
        }
        return StartHome(stored);
      },
      (me) async {
        final current = me.role;
        if (current == null) {
          await clearLocal();
          return const StartAuth();
        }
        // The backend is authoritative — refresh in case the role changed.
        await _storage.setRole(current.value);
        return StartHome(current);
      },
    );
  }

  /// Revokes the session server-side first (the requests need the token),
  /// then clears local state regardless of how the network calls went.
  Future<void> logout() async {
    try {
      final fcm = await _fcmToken();
      if (fcm != null) {
        await _unregisterDeviceUseCase.execute(fcm);
      }
    } catch (_) {
      // The backend prunes dead tokens on failed pushes.
    }
    await _logoutUseCase.execute(null);
    await clearLocal();
  }

  Future<void> clearLocal() async {
    await _storage.deleteToken();
    await _storage.deleteRole();
    // The cart belongs to the session — never carry it to the next account.
    _onSessionCleared?.call();
  }

  /// Only an invalid token or a deactivated account ends the session —
  /// other failures (timeouts, 5xx, no internet) are transient.
  bool _isSessionDead(Failure failure) =>
      failure is ServerError &&
      (failure.statusCode == 401 || failure.code == 'account_suspended');
}
