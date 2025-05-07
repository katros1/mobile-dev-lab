import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/assignee.dart';
import '../models/task.dart';
import '../providers/assignee_provider.dart';
import '../providers/task_provider.dart';
import 'assignee_detail_screen.dart';

class AssigneesScreen extends StatelessWidget {
  const AssigneesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assigneeProvider = Provider.of<AssigneeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => assigneeProvider.loadAssignees(),
          ),
        ],
      ),
      body: assigneeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : assigneeProvider.error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(assigneeProvider.error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => assigneeProvider.loadAssignees(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : assigneeProvider.assignees.isEmpty
                  ? const Center(child: Text('No assignees yet'))
                  : ListView.builder(
                      itemCount: assigneeProvider.assignees.length,
                      itemBuilder: (context, index) {
                        final assignee = assigneeProvider.assignees[index];
                        return Dismissible(
                          key: Key(assignee.id.toString()),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm"),
                                  content: const Text("Are you sure you want to delete this assignee?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text("CANCEL"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text("DELETE"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (_) {
                            if (assignee.id != null) {
                              assigneeProvider.deleteAssignee(assignee.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Assignee "${assignee.name}" deleted'),
                                ),
                              );
                            }
                          },
                          child: ListTile(
                            title: Text(assignee.name),
                            subtitle: Text('Task: ${assignee.taskAssigned}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAssigneeDialog(context, assignee),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AssigneeDetailScreen(assignee: assignee),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAssigneeDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            context.go('/');
          } else if (index == 2) {
            context.go('/notifications');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Assignees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }

  void _showAssigneeDialog(BuildContext context, [Assignee? assignee]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: assignee?.name ?? '');
    final phoneController = TextEditingController(text: assignee?.phone ?? '');
    final emailController = TextEditingController(text: assignee?.email ?? '');
    String selectedTask = assignee?.taskAssigned ?? '';

    showDialog(
      context: context,
      builder: (context) {
        final taskProvider = Provider.of<TaskProvider>(context);
        final assigneeProvider = Provider.of<AssigneeProvider>(context, listen: false);
        
        // Filter tasks to only include incomplete tasks
        final availableTasks = taskProvider.tasks.where((task) => !task.isCompleted).toList();
        
        // If the currently assigned task is completed but we're editing an existing assignee,
        // we should still include it in the dropdown
        if (assignee != null && selectedTask.isNotEmpty) {
          final currentTaskIsAvailable = availableTasks.any((task) => task.title == selectedTask);
          if (!currentTaskIsAvailable) {
            // Find the completed task in the full task list
            final completedTask = taskProvider.tasks.firstWhere(
              (task) => task.title == selectedTask,
              orElse: () => Task(title: '', description: '', dueDate: DateTime.now()),
            );
            
            // If we found it, add it to available tasks for this specific edit
            if (completedTask != null) {
              availableTasks.add(completedTask);
            }
          }
        }
     
        final String? initialValue = selectedTask.isNotEmpty && 
                                    availableTasks.any((t) => t.title == selectedTask)
            ? selectedTask
            : (availableTasks.isNotEmpty ? availableTasks.first.title : null);
        
        return AlertDialog(
          title: Text(assignee == null ? 'Add Assignee' : 'Edit Assignee'),
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
                  final newAssignee = Assignee(
                    id: assignee?.id,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    taskAssigned: selectedTask,
                    dateAssigned: assignee?.dateAssigned ?? DateTime.now(),
                  );
                  
                  bool success;
                  if (assignee == null) {
                    success = await assigneeProvider.addAssignee(newAssignee);
                  } else {
                    success = await assigneeProvider.updateAssignee(newAssignee);
                  }
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success 
                              ? 'Assignee ${assignee == null ? 'added' : 'updated'} successfully' 
                              : 'Failed to ${assignee == null ? 'add' : 'update'} assignee'
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
