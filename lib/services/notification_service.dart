import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android Settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Notification-e tap korle response.payload paben
      },
    );

    // Permission request
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Token print for testing
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showLocalNotification(
          title: notification.title ?? 'New Notification',
          body: notification.body ?? '',
          payload: message.data['taskId'],
        );
      }
    });
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'task_channel_id',
      'Task Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
}