import 'dart:convert';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
    'prepify_household_channel',
    'Prepify household updates',
    description: 'Household grocery and member activity notifications',
    importance: Importance.high,
  );

  // Returns true if the current platform supports Firebase Messaging.
  static bool get _isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<void> initialize() async {
    // FCM is not supported on Windows / macOS / Linux desktop.
    if (!_isSupportedPlatform) return;

    try {
      await _initializeLocalNotifications();
    } catch (_) {}

    try {
      await _requestPermissions();
    } catch (_) {}

    try {
      await _saveCurrentToken();
    } catch (_) {}

    try {
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await _updateTokenInFirestore(newToken);
      });

      FirebaseMessaging.onMessage.listen((message) async {
        await _showLocalNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        // Hook for future deep links.
      });

      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        // App was opened from terminated state via notification tap.
      }
    } catch (_) {}
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_defaultChannel);
  }

  static Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  static Future<void> _saveCurrentToken() async {
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;
    await _updateTokenInFirestore(token);
  }

  static Future<void> _updateTokenInFirestore(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'userId': uid,
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Prepify';
    final body = message.notification?.body ?? 'You have a new update.';
    final payload = jsonEncode(message.data);

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prepify_household_channel',
          'Prepify household updates',
          channelDescription: 'Household grocery and member activity notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }
}
