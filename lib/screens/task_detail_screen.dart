import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import './task_application_screen.dart';

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split('_')
        .map((word) => word.isEmpty 
            ? '' 
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  final bool isContractor;

  const TaskDetailScreen({
    Key? key,
    required this.taskId,
    required this.isContractor,
  }) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Map<String, dynamic>? _taskDetails;
  Map<String, dynamic>? _application;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final taskData = await ApiService.getTask(widget.taskId);
      final applicationData = widget.isContractor ? null : await ApiService.getTaskApplication(widget.taskId);

      setState(() {
        _taskDetails = taskData;
        _application = applicationData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchTaskApplication() async {
    if (widget.isContractor) return;
    
    try {
      final application = await ApiService.getTaskApplication(widget.taskId);
      setState(() {
        _application = application;
      });
    } catch (e) {
      print('Error fetching application: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_taskDetails?['site_name'] ?? 'Task Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _taskDetails == null
                  ? Center(child: Text('Task not found'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await _loadTask();
                      },
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTaskDetails(),
                            SizedBox(height: 24),
                            if (!widget.isContractor) _buildApplicationSection(),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildTaskDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _taskDetails?['site_name'] ?? 'Unnamed Task',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${_taskDetails?['street']}, ${_taskDetails?['city']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.euro, size: 20, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  NumberFormat.currency(
                    locale: 'fr_FR',
                    symbol: '€',
                  ).format(double.parse(_taskDetails?['proposed_price'].toString() ?? '0')),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_taskDetails?['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _taskDetails?['status']?.toString().toUpperCase() ?? 'PENDING',
                style: TextStyle(
                  color: _getStatusColor(_taskDetails?['status']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_taskDetails?['description'] != null) ...[
              SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _taskDetails?['description'] ?? '',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationSection() {
    if (_application == null) {
      return ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/apply_task',
            arguments: {
              'taskId': widget.taskId,
              'taskDetails': _taskDetails,
            },
          ).then((_) => _fetchTaskApplication());
        },
        child: Text('Apply for this task'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Application',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.euro, size: 20, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Proposed: ${NumberFormat.currency(
                    locale: 'fr_FR',
                    symbol: '€',
                  ).format(double.parse(_application?['proposed_price'].toString() ?? '0'))}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_application?['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _application?['status']?.toString().toUpperCase() ?? 'PENDING',
                style: TextStyle(
                  color: _getStatusColor(_application?['status']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_application?['status'] == 'pending') ...[
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add withdraw application functionality
                },
                child: Text('Withdraw Application'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'active':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}