import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/assignee.dart';
import '../providers/assignee_provider.dart';
import '../providers/task_provider.dart';

class AssigneeDetailScreen extends StatelessWidget {
  final Assignee assignee;

  const AssigneeDetailScreen({super.key, required this.assignee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(assignee.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showAssigneeDialog(context, assignee),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, assignee),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              title: 'Personal Information',
              content: [
                _buildInfoRow(Icons.person, 'Name', assignee.name),
                _buildInfoRow(Icons.email, 'Email', assignee.email),
                _buildInfoRow(Icons.phone, 'Phone', assignee.phone),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Assignment Details',
              content: [
                _buildInfoRow(Icons.task, 'Task', assignee.taskAssigned),
                _buildInfoRow(
                  Icons.calendar_today, 
                  'Date Assigned', 
                  _formatDate(assignee.dateAssigned),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Assignee assignee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignee'),
        content: Text('Are you sure you want to delete ${assignee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      final assigneeProvider = Provider.of<AssigneeProvider>(context, listen: false);
      if (assignee.id != null) {
        final success = await assigneeProvider.deleteAssignee(assignee.id!);
        
        if (context.mounted) {
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success 
                    ? 'Assignee "${assignee.name}" deleted successfully' 
                    : 'Failed to delete assignee'
              ),
            ),
          );
        }
      }
    }
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> content}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAssigneeDialog(BuildContext context, Assignee assignee) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: assignee.name);
    final phoneController = TextEditingController(text: assignee.phone);
    final emailController = TextEditingController(text: assignee.email);
    String selectedTask = assignee.taskAssigned;

    showDialog(
      context: context,
      builder: (context) {
        final taskProvider = Provider.of<TaskProvider>(context);
        final assigneeProvider = Provider.of<AssigneeProvider>(context, listen: false);
        
        // Filter tasks to only include incomplete tasks
        final availableTasks = taskProvider.tasks.where((task) => !task.isCompleted).toList();
        
        // If the currently assigned task is completed, we should still include it in the dropdown
        if (selectedTask.isNotEmpty) {
          final currentTaskIsAvailable = availableTasks.any((task) => task.title == selectedTask);
          if (!currentTaskIsAvailable) {
            // Find the completed task in the full task list
            final completedTaskList = taskProvider.tasks.where(
              (task) => task.title == selectedTask
            ).toList();
            
            // If we found it, add it to available tasks for this specific edit
            if (completedTaskList.isNotEmpty) {
              availableTasks.add(completedTaskList.first);
            }
          }
        }
        
        // Default selection logic
        final String? initialValue = selectedTask.isNotEmpty && 
                                    availableTasks.any((t) => t.title == selectedTask)
            ? selectedTask
            : (availableTasks.isNotEmpty ? availableTasks.first.title : null);
        
        return AlertDialog(
          title: const Text('Edit Assignee'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name*',
                      hintText: 'Enter full name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone*',
                      hintText: 'Enter phone number',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      if (value.trim().length < 10) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email*',
                      hintText: 'Enter email address',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  if (availableTasks.isEmpty)
                    const Text(
                      'No incomplete tasks available. Please create a task first.',
                      style: TextStyle(color: Colors.red),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: initialValue,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Task*',
                        hintText: 'Select a task',
                      ),
                      items: availableTasks.map((task) {
                        return DropdownMenuItem<String>(
                          value: task.title,
                          child: Text(
                            task.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedTask = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Task assignment is required';
                        }
                        return null;
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                if (availableTasks.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please create an incomplete task first'),
                    ),
                  );
                  Navigator.of(context).pop();
                  return;
                }
                
                if (formKey.currentState!.validate()) {
                  final updatedAssignee = Assignee(
                    id: assignee.id,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    taskAssigned: selectedTask,
                    dateAssigned: assignee.dateAssigned,
                  );
                  
                  final success = await assigneeProvider.updateAssignee(updatedAssignee);
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    
                    if (success) {
                      Navigator.of(context).pop();
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success 
                              ? 'Assignee updated successfully' 
                              : 'Failed to update assignee'
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }
}



