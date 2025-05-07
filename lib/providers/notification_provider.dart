import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/local_db_service.dart';
import 'dart:async';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  static final StreamController<void> _notificationStreamController = 
      StreamController<void>.broadcast();

  static Stream<void> get notificationStream => _notificationStreamController.stream;

  static void notifyNewNotification() {
    _notificationStreamController.add(null);
  }

  NotificationProvider() {
    loadNotifications();
 
    notificationStream.listen((_) {
      print('Notification provider received update event');
      loadNotifications();
    });
  }

  Future<void> loadNotifications() async {
    try {
      _notifications = await LocalDbService.getNotifications();
      print('Loaded ${_notifications.length} notifications');
      notifyListeners();
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    try {
      await LocalDbService.insertNotification(notification);
      print('Added notification: ${notification.title}');
      await loadNotifications();

      notifyNewNotification();
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await LocalDbService.markNotificationAsRead(id);
      print('Marked notification $id as read');
      await loadNotifications();
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await LocalDbService.deleteNotification(id);
      print('Deleted notification $id');
      await loadNotifications();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      await LocalDbService.deleteAllNotifications();
      print('Deleted all notifications');
      await loadNotifications();
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }
  
  @override
  void dispose() {
    // close
    super.dispose();
  }
}


