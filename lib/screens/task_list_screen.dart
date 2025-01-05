import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import '../screens/task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String status;
  final bool isContractor;

  const TaskListScreen({
    super.key, 
    required this.status, 
    this.isContractor = true,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks = await ApiService.fetchTasksByStatus(
        status: widget.status, 
        isContractor: widget.isContractor
      );
      
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_getStatusTitle(widget.status)} Tasks'),
        elevation: 0,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _buildTaskList(),
    );
  }

  Widget _buildTaskList() {
    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.folderOpen, 
              size: 80, 
              color: Colors.grey[300]
            ),
            const SizedBox(height: 16),
            Text(
              'No ${widget.status} tasks found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _tasks.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to task detail screen
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                taskId: task['id'], 
                isContractor: widget.isContractor
              )
            )
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task['site_name'] ?? 'Unnamed Task',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      task['status'] ?? widget.status, 
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getStatusColor(task['status'] ?? widget.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task['street'] ?? 'No address',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.calendar, 
                        size: 16, 
                        color: Colors.grey[600]
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(task['created_at']),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (task['applications_count'] != null)
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.paperclip, 
                          size: 16, 
                          color: Colors.grey[600]
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${task['applications_count']} Applications',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return 'N/A';
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'active':
        return 'Active';
      case 'in progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'approved':
        return 'Approved';
      case 'all':
        return 'All';
      default:
        return status.capitalize();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'in progress':
        return Colors.teal;
      case 'completed':
        return Colors.purple;
      case 'approved':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 