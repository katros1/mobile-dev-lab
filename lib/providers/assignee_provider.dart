import 'package:flutter/foundation.dart';
import '../models/assignee.dart';
import '../services/assignee_api_service.dart';

class AssigneeProvider extends ChangeNotifier {
  List<Assignee> _assignees = [];
  bool _isLoading = false;
  String _error = '';

  List<Assignee> get assignees => _assignees;
  bool get isLoading => _isLoading;
  String get error => _error;

  AssigneeProvider() {
    loadAssignees();
  }

  Future<void> loadAssignees() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _assignees = await AssigneeApiService.fetchAssignees();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load assignees: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAssignee(Assignee assignee) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newAssignee = await AssigneeApiService.createAssignee(assignee);
      if (newAssignee != null) {
        await loadAssignees();
        return true;
      }
      _isLoading = false;
      _error = 'Failed to add assignee';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add assignee: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAssignee(Assignee assignee) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedAssignee = await AssigneeApiService.updateAssignee(assignee);
      if (updatedAssignee != null) {
        await loadAssignees();
        return true;
      }
      _isLoading = false;
      _error = 'Failed to update assignee';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update assignee: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAssignee(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await AssigneeApiService.deleteAssignee(id);
      if (success) {
        await loadAssignees();
        return true;
      }
      _isLoading = false;
      _error = 'Failed to delete assignee';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete assignee: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}