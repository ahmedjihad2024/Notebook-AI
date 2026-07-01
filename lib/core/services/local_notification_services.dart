// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'firebase_messeging_services.dart';

/// Top-level background handler for notification actions
/// (required by flutter_local_notifications for background tap)
@pragma('vm:entry-point')
void onLocalNotificationTapBackground(NotificationResponse response) async {
  debugPrint("💬 Message tapped from local notifications: ${response.payload}");

  // if (response.actionId == 'HIDE_KEY_ACTION') {
  //   print("HIDE_KEY_ACTION");
  //   MyBackgroundService.instance.stop();
  //   // refresh showing notification icon
  //   HomeView.homeBloc?.add(ShowHideNotificationEvent(isShow: false));
  //   return;
  // }

  if (response.payload == null || response.payload!.isEmpty) return;

  try {
    final Map<String, dynamic> data = jsonDecode(response.payload!);

    // Keep the same payload format you used with Awesome:
    // { "remote_message": "{...RemoteMessage map...}" }
    final remoteString = data['remote_message'] as String?;
    if (remoteString != null && remoteString.isNotEmpty) {
      final Map<String, dynamic> remote = jsonDecode(remoteString);
      FirebaseMessegingServices.instance.handleNotificationTap(
        RemoteMessage.fromMap(remote),
      );
    }
  } catch (e) {
    debugPrint('❌ Error parsing notification payload: $e');
  }
}

class MyLocalNotifications {
  static final MyLocalNotifications _instance = MyLocalNotifications._();
  static MyLocalNotifications get instance => _instance;
  MyLocalNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  FlutterLocalNotificationsPlugin get plugin => _plugin;

  String _channelId = 'basic_channel';
  String get channelId => _channelId;

  String _channelName = 'Basic notifications';
  String get channelName => _channelName;

  String _channelDescription = 'Notification channel for basic notifications';
  String get channelDescription => _channelDescription;

  int _notificationId = 1;
  int get notificationId => _notificationId;

  // Background/progress channel
  String _backgroundChannelId = 'background_channel';
  String get backgroundChannelId => _backgroundChannelId;

  bool? _isInitialized = false;
  bool get isInitialized => _isInitialized ?? false;

  bool _isPermissionGranted = false;
  bool get isPermissionGranted => _isPermissionGranted;

  /// Initialize local notifications
  Future<bool> initialize({
    AndroidNotificationChannel? basicChannel,
    bool isBackground = false,
  }) async {
    if (isInitialized) return true;

    // If caller passes a custom channel, use its info
    if (basicChannel != null) {
      _channelId = basicChannel.id;
      _channelName = basicChannel.name;
      _channelDescription = basicChannel.description ?? _channelDescription;
    }

    const AndroidInitializationSettings initAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: initAndroid,
      iOS: initDarwin,
      macOS: initDarwin,
    );

    _isInitialized = await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onLocalNotificationTapBackground,
    );

    if (isInitialized) {
      // Create the main channel
      await _createMainChannel(basicChannel: basicChannel);
      // Create background/progress channel
      await _createBackgroundChannel();

      if (!isBackground) {
        _isPermissionGranted = await _requestPermissionIfNeeded();
      }
    }

    return isInitialized;
  }

  /// Internal: create basic (main) channel
  Future<void> _createMainChannel({
    AndroidNotificationChannel? basicChannel,
  }) async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl == null) return;

    final AndroidNotificationChannel channel =
        basicChannel ??
        AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

    await androidImpl.createNotificationChannel(channel);
  }

  /// Internal: create background/progress channel
  Future<void> _createBackgroundChannel() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl == null) return;

    final AndroidNotificationChannel bgChannel = AndroidNotificationChannel(
      _backgroundChannelId,
      'Background Service',
      description: 'For background tasks',
      importance: Importance.defaultImportance,
      playSound: false,
      enableVibration: false,
    );

    await androidImpl.createNotificationChannel(bgChannel);
  }

  /// Handle taps when app is in foreground/background
  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) async {
    debugPrint("🔔 onDidReceiveNotificationResponse: ${response.payload}");
    onLocalNotificationTapBackground(response);
  }

  /// Separate method similar to your permission_handler logic
  Future<bool> _requestPermissionIfNeeded() async {
    // Android 13+ permission
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS / macOS
    final darwinImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (darwinImpl != null) {
      final bool? result = await darwinImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    return true;
  }

  /// Custom permission API like your Awesome version
  Future<bool> requestPermissionToSendNotifications() async {
    _isPermissionGranted = await _requestPermissionIfNeeded();
    return _isPermissionGranted;
  }

  /// Update or create channel (Android only)
  Future<void> setChannel(
    AndroidNotificationChannel notificationChannel, {
    bool forceUpdate = false,
  }) async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl == null) return;

    if (forceUpdate) {
      // There is no direct "forceUpdate", but you can delete & re-create
      await androidImpl.deleteNotificationChannel(
        channelId: notificationChannel.id,
      );
    }
    await androidImpl.createNotificationChannel(notificationChannel);

    // Update internal fields if this is the main channel
    _channelId = notificationChannel.id;
    _channelName = notificationChannel.name;
    _channelDescription =
        notificationChannel.description ?? _channelDescription;
  }

  /// Show basic notification (optionally with big picture or HTML on Android)
  Future<bool> showBasicNotification({
    int? id,
    required String title,
    required String body,
    String? bigPicture,
    String? groupKey,
    bool isHtml = false,
    Map<String, String?>? payload,
  }) async {
    final notificationId =
        id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

    String? localBigPicture;
    if (bigPicture != null && bigPicture.startsWith('http')) {
      localBigPicture = await _downloadAndSaveFile(
        bigPicture,
        'notification_img_$notificationId.jpg',
      );
    } else {
      localBigPicture = bigPicture;
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      groupKey: groupKey,
      styleInformation: localBigPicture != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(localBigPicture),
              contentTitle: isHtml ? title : null,
              summaryText: isHtml ? body : null,
              htmlFormatContentTitle: isHtml,
              htmlFormatSummaryText: isHtml,
              htmlFormatTitle: isHtml,
              htmlFormatContent: isHtml,
            )
          : DefaultStyleInformation(isHtml, isHtml),
    );

    const darwinDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    return await _plugin
        .show(
          id: notificationId,
          title: title,
          body: body,
          notificationDetails: details,
          payload: payload == null ? null : jsonEncode(payload),
        )
        .then((_) => true)
        .catchError((_) => false);
  }

  /// Advanced notification: Allows passing every detail for full customization
  Future<bool> showAdvancedNotification({
    required int id,
    String? title,
    String? body,
    AndroidNotificationDetails? androidDetails,
    DarwinNotificationDetails? darwinDetails,
    Map<String, dynamic>? payload,
  }) async {
    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    return await _plugin
        .show(
          id: id,
          title: title,
          body: body,
          notificationDetails: details,
          payload: payload == null ? null : jsonEncode(payload),
        )
        .then((_) => true)
        .catchError((_) => false);
  }

  /// Helper: Download network image to local disk
  Future<String?> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final Directory directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/$fileName';
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final File file = File(filePath);
      await file.writeAsBytes(response.data);
      return filePath;
    } catch (e) {
      debugPrint("❌ Error downloading notification image: $e");
      return null;
    }
  }

  Future<void> cancelNotification({required int id, String? tag}) async {
    await _plugin.cancel(id: id, tag: tag);
  }
}
