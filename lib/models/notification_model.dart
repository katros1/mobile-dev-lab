class NotificationModel {
  final int? id;
  final String title;
  final String body;
  final String payload;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.payload,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead ? 1 : 0,
  };

  static NotificationModel fromMap(Map<String, dynamic> map) => NotificationModel(
    id: map['id'],
    title: map['title'],
    body: map['body'],
    payload: map['payload'],
    timestamp: DateTime.parse(map['timestamp']),
    isRead: map['isRead'] == 1,
  );
}