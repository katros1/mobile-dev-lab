class Assignee {
  final int? id;
  String name;
  String phone;
  String email;
  String taskAssigned;
  DateTime dateAssigned;

  Assignee({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.taskAssigned,
    required this.dateAssigned,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'taskAssigned': taskAssigned,
    'dateAssigned': dateAssigned.toIso8601String(),
  };

  static Assignee fromMap(Map<String, dynamic> map) => Assignee(
    id: map['id'],
    name: map['name'],
    phone: map['phone'],
    email: map['email'],
    taskAssigned: map['taskAssigned'],
    dateAssigned: DateTime.parse(map['dateAssigned']),
  );
}