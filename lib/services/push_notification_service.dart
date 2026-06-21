import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../firebase_options.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await PushNotificationService.ensureFirebaseInitialized();
  } catch (_) {
    // Keep background handling safe when Firebase config is incomplete.
  }
}

class PushNotificationService {
  PushNotificationService({
    required this.cloudSyncEnabled,
    required this.localNotificationService,
  });

  final bool cloudSyncEnabled;
  final NotificationService localNotificationService;
  CollectionReference<Map<String, dynamic>> _devicesCollection(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('devices');
  }

  bool _initialized = false;
  bool _firebaseReady = false;
  bool _permissionGranted = false;
  bool _deviceRegistered = false;
  String? _currentUserId;
  String? _fcmToken;
  DateTime? _lastTokenSyncAt;
  String? _lastSyncError;
  StreamSubscription<String>? _tokenRefreshSubscription;
  Future<void> Function(Map<String, dynamic> data)? _onNotificationTap;

  bool get isInitialized => _initialized;
  bool get isFirebaseReady => _firebaseReady;
  bool get permissionGranted => _permissionGranted;
  bool get deviceRegistered => _deviceRegistered;
  String? get fcmToken => _fcmToken;
  DateTime? get lastTokenSyncAt => _lastTokenSyncAt;
  String? get lastSyncError => _lastSyncError;
  bool get canSendPush => _firebaseReady && _permissionGranted;

  static Future<bool> ensureFirebaseInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      return true;
    }

    try {
      final envOptions = _PushFirebaseOptions.fromEnvironment();
      await Firebase.initializeApp(
        options: envOptions ?? DefaultFirebaseOptions.currentPlatform,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> initialize({
    String? userId,
    Future<void> Function(Map<String, dynamic> data)? onNotificationTap,
  }) async {
    _currentUserId = userId ?? _currentUserId;
    _onNotificationTap = onNotificationTap ?? _onNotificationTap;

    if (!Platform.isAndroid && !Platform.isIOS) {
      _lastSyncError =
          'Push notifications are only supported on Android and iOS.';
      _initialized = true;
      return;
    }

    _firebaseReady = await ensureFirebaseInitialized();
    if (!_firebaseReady) {
      _lastSyncError =
          'Firebase push is not configured yet. Local notifications remain available.';
      _initialized = true;
      return;
    }

    if (_tokenRefreshSubscription == null) {
      FirebaseMessaging.onMessage.listen((message) {
        _handleForegroundMessage(message);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleMessageTap(message);
      });
      _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
          .listen((token) async {
            _fcmToken = token;
            if (_currentUserId != null) {
              await syncDeviceToken(userId: _currentUserId!);
            }
          });
    }

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _handleMessageTap(initialMessage);
    }

    _permissionGranted = await requestPermissions();
    if (_currentUserId != null) {
      await syncDeviceToken(userId: _currentUserId!);
    }

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (!_firebaseReady) {
      return false;
    }

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final localPermission = await localNotificationService
          .requestPermissions();
      _permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional ||
          localPermission;
      return _permissionGranted;
    } catch (error) {
      _lastSyncError = 'Notification permission request failed: $error';
      _permissionGranted = false;
      return false;
    }
  }

  Future<void> syncDeviceToken({
    required String userId,
    bool notificationsEnabled = true,
  }) async {
    _currentUserId = userId;

    if (!_firebaseReady) {
      return;
    }

    try {
      _permissionGranted = await requestPermissions();
      if (!_permissionGranted) {
        _deviceRegistered = false;
        _lastSyncError = 'Push permission not granted.';
        return;
      }

      _fcmToken = await FirebaseMessaging.instance.getToken();
      if (_fcmToken == null || _fcmToken!.isEmpty) {
        _deviceRegistered = false;
        _lastSyncError = 'FCM token was not available.';
        return;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      await _devicesCollection(userId).doc(_deviceDocId(_fcmToken!)).set({
        'user_id': userId,
        'device_id': _deviceDocId(_fcmToken!),
        'fcm_token': _fcmToken,
        'platform': Platform.operatingSystem,
        'device_name': Platform.operatingSystemVersion,
        'app_version': '${packageInfo.version}+${packageInfo.buildNumber}',
        'notifications_enabled': notificationsEnabled,
        'updated_at': DateTime.now().toIso8601String(),
        'created_at':
            _lastTokenSyncAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      _deviceRegistered = true;
      _lastSyncError = null;
      _lastTokenSyncAt = DateTime.now();
    } catch (error) {
      _deviceRegistered = false;
      _lastSyncError = 'Device token sync failed: $error';
    }
  }

  Future<void> deleteTokenOnLogout(String userId) async {
    try {
      if (_fcmToken != null && _fcmToken!.isNotEmpty) {
        await _devicesCollection(userId).doc(_deviceDocId(_fcmToken!)).delete();
      }
      if (_firebaseReady) {
        await FirebaseMessaging.instance.deleteToken();
      }
      _fcmToken = null;
      _deviceRegistered = false;
      _currentUserId = null;
    } catch (error) {
      _lastSyncError = 'Unable to remove device token: $error';
    }
  }

  Future<bool> sendTestPushNotification({
    required String userId,
    String notificationType = 'upcoming_payment',
  }) async {
    _lastSyncError =
        'Cloud test push is not connected in this build yet. Device token sync still works.';
    return false;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await localNotificationService.showInstantNotification(
      title: notification.title ?? 'Bizoot alert',
      body: notification.body ?? 'Open Bizoot to review your subscriptions.',
      data: message.data,
    );
  }

  Future<void> _handleMessageTap(RemoteMessage message) async {
    if (_onNotificationTap == null) {
      return;
    }
    await _onNotificationTap!(message.data);
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
  }

  String _deviceDocId(String token) =>
      token.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
}

class _PushFirebaseOptions {
  static FirebaseOptions? fromEnvironment() {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const messagingSenderId = String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
    );
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
    const androidAppId = String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
    const iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
    const iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

    if (apiKey.isEmpty || messagingSenderId.isEmpty || projectId.isEmpty) {
      return null;
    }

    if (Platform.isAndroid && androidAppId.isNotEmpty) {
      return FirebaseOptions(
        apiKey: apiKey,
        appId: androidAppId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket.isEmpty ? null : storageBucket,
      );
    }

    if (Platform.isIOS && iosAppId.isNotEmpty) {
      return FirebaseOptions(
        apiKey: apiKey,
        appId: iosAppId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket.isEmpty ? null : storageBucket,
        iosBundleId: iosBundleId.isEmpty ? null : iosBundleId,
      );
    }

    return null;
  }
}
