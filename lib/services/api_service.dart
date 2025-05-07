import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Task.fromMap(e)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<void> sendTask(Task task) async {
    await http.post(Uri.parse(apiUrl), body: json.encode(task.toMap()));
  }
}