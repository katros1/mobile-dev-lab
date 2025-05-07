import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/notification_model.dart';
import '../services/local_db_service.dart';
import '../providers/notification_provider.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          context.go('/notifications');
        }
      },
    );

    // Request permission for iOS
    await FirebaseMessaging.instance.requestPermission();

    // FCM token for this device
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");

    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground: ${message.notification?.title}');
      _saveAndShowNotification(message);
    });

    // Background (tapped)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 App opened from background: ${message.notification?.title}');
      _saveNotification(message);
      
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.go('/notifications');
      }
    });

    // Background
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('🧊 App launched from terminated state: ${message.notification?.title}');
        _saveNotification(message);
        
        Future.delayed(const Duration(seconds: 1), () {
          final context = navigatorKey.currentContext;
          if (context != null) {
            context.go('/notifications');
          }
        });
      }
    });
  }
  
  static Future<void> _saveAndShowNotification(RemoteMessage message) async {

    await _saveNotification(message);
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      channelDescription: 'Channel Description',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data.toString(),
    );
  }
  
  static Future<void> _saveNotification(RemoteMessage message) async {
    try {
      final notification = NotificationModel(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        payload: message.data.toString(),
        timestamp: DateTime.now(),
      );
      
      await LocalDbService.insertNotification(notification);
      print('Notification saved to database: ${notification.title}');
      
      NotificationProvider.notifyNewNotification();
    } catch (e) {
      print('Error saving notification: $e');
    }
  }
}

