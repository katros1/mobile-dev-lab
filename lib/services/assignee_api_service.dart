import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/assignee.dart';

class AssigneeApiService {
  
  static const String baseUrl = 'http://10.0.2.2:8082/api/assignees';

  static Future<List<Assignee>> fetchAssignees() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Assignee.fromMap(e)).toList();
      } else {
        throw Exception('Failed to load assignees: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching assignees: $e');
      return [];
    }
  }

  static Future<Assignee?> createAssignee(Assignee assignee) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(assignee.toMap()),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Assignee.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to create assignee: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating assignee: $e');
      return null;
    }
  }

  static Future<Assignee?> updateAssignee(Assignee assignee) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${assignee.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(assignee.toMap()),
      );
      
      if (response.statusCode == 200) {
        return Assignee.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to update assignee: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating assignee: $e');
      return null;
    }
  }

  static Future<bool> deleteAssignee(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting assignee: $e');
      return false;
    }
  }
}
