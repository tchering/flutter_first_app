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

  TaskDetailScreen({
    super.key, 
    required this.taskId,
    this.isContractor = true,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Map<String, dynamic> _taskDetails = {};
  Map<String, dynamic> _application = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
    if (!widget.isContractor) {
      _fetchTaskApplication();
    }
  }

  Future<void> _loadTaskDetails() async {
    try {
      final taskDetails = await ApiService.fetchTaskDetails(
        taskId: widget.taskId
      );
      
      setState(() {
        _taskDetails = taskDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTaskApplication() async {
    try {
      final application = await ApiService.getTaskApplication(widget.taskId);
      setState(() {
        _application = application;
      });
    } catch (e) {
      // Ignore error as it might mean no application exists
    }
  }

  Future<void> _applyForTask() async {
    setState(() {
      _isApplying = true;
    });

    try {
      await ApiService.applyForTask(widget.taskId);
      await _fetchTaskApplication();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying for task: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  Future<void> _withdrawApplication() async {
    try {
      setState(() {
        _isLoading = true; // Show loading state
      });
      
      await ApiService.withdrawTaskApplication(taskId: widget.taskId);
      
      // Refresh both task details and application status
      await _loadTaskDetails();
      await _fetchTaskApplication();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application withdrawn successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error withdrawing application: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildActionButtons() {
    if (widget.isContractor) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_taskDetails['contract'] == null && _taskDetails['sub_contractor_id'] != null)
            ElevatedButton.icon(
              icon: Icon(Icons.description),
              label: Text('Generate Contract'),
              onPressed: () {
                // Navigate to contract generation
              },
            ),
          SizedBox(width: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.edit),
            label: Text('Edit'),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
          SizedBox(width: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.delete),
            label: Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // Show delete confirmation
            },
          ),
        ],
      );
    } else {
      final hasApplication = _application.isNotEmpty;
      final applicationStatus = _application['status'];
      
      if (hasApplication) {
        if (applicationStatus == 'approved') {
          if (_taskDetails['contract'] != null) {
            return ElevatedButton.icon(
              icon: Icon(Icons.description),
              label: Text('View Contract'),
              onPressed: () {
                // Navigate to contract view
              },
            );
          }
          return SizedBox.shrink();
        }
        return ElevatedButton.icon(
          icon: Icon(Icons.cancel),
          label: Text('Withdraw Application'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: _withdrawApplication,
        );
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskApplicationScreen(taskId: widget.taskId),
                ),
              );
              if (result == true) {
                // Application was submitted successfully
                setState(() {
                  _isLoading = true; // Show loading while refreshing
                });
                // Refresh both task details and application status
                await _loadTaskDetails();
                await _fetchTaskApplication();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Apply for Task',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'N/A';
    try {
      return '€${double.parse(price.toString()).toStringAsFixed(2)}';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Task Details', 
          style: TextStyle(
            color: Colors.blueGrey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: _buildAppBarActions(),
        iconTheme: IconThemeData(color: Colors.blueGrey.shade800),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTaskDetailBody(),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: _buildActionButtons(),
                      ),
                    ],
                  ),
                ),
    );
  }

  List<Widget>? _buildAppBarActions() {
    if (!widget.isContractor) return null;

    return [
      IconButton(
        icon: Icon(Icons.edit, color: Colors.blueGrey.shade700),
        onPressed: () {
          // TODO: Implement edit task navigation
        },
      ),
      IconButton(
        icon: Icon(Icons.delete, color: Colors.red.shade700),
        onPressed: _showDeleteConfirmationDialog,
      ),
    ];
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete'),
              onPressed: () {
                // TODO: Implement task deletion
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskDetailBody() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with company info
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: _taskDetails['contractor_logo'] != null
                        ? NetworkImage(_taskDetails['contractor_logo'])
                        : AssetImage('assets/images/default_logo1.png') as ImageProvider,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _taskDetails['site_name'] ?? '',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          _taskDetails['contractor_name'] ?? '',
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Location
              _buildInfoRow(
                Icons.location_on,
                '${_taskDetails['street']}, ${_taskDetails['city']}',
              ),
              SizedBox(height: 16),

              // Dates
              _buildInfoRow(
                Icons.calendar_today,
                'Start: ${DateFormat('MMM d, yyyy').format(DateTime.parse(_taskDetails['start_date']))}',
              ),
              if (_taskDetails['end_date'] != null) ...[
                SizedBox(height: 8),
                _buildInfoRow(
                  Icons.event,
                  'End: ${DateFormat('MMM d, yyyy').format(DateTime.parse(_taskDetails['end_date']))}',
                ),
              ],
              SizedBox(height: 16),

              // Price
              if (_taskDetails['proposed_price'] != null)
                _buildInfoRow(
                  Icons.attach_money,
                  'Proposed Price: ${_formatPrice(_taskDetails['proposed_price'])}',
                ),

              SizedBox(height: 24),

              // Task Details Section
              Text(
                'Task Details',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Text Attributes
              if (_taskDetails['text_attributes'] != null) ...[
                ..._taskDetails['text_attributes'].entries.map((entry) {
                  final label = entry.key.toString().replaceAll('_', ' ').split(' ')
                    .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
                    .join(' ');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        entry.value.toString(),
                        style: textTheme.bodyLarge,
                      ),
                      SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ],

              // Measurements
              if (_taskDetails['measurements'] != null &&
                  _taskDetails['measurements'].isNotEmpty) ...[
                Text(
                  'Measurements',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ..._taskDetails['measurements'].entries.map((entry) {
                  final label = entry.key.toString().replaceAll('_', ' ').split(' ')
                    .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
                    .join(' ');
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: textTheme.bodyMedium,
                        ),
                        Text(
                          '${entry.value} m²',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
              ],

              // Services
              if (_taskDetails['boolean_services'] != null &&
                  _taskDetails['boolean_services'].isNotEmpty) ...[
                Text(
                  'Services Required',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _taskDetails['boolean_services']
                      .entries
                      .where((entry) => entry.value == true)
                      .map<Widget>((entry) {
                    final label = entry.key.toString().replaceAll('_', ' ').split(' ')
                      .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
                      .join(' ');
                    return Chip(
                      label: Text(
                        label,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: colorScheme.primary,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}