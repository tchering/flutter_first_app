import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';

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
    _fetchTaskDetails();
    if (!widget.isContractor) {
      _fetchTaskApplication();
    }
  }

  Future<void> _fetchTaskDetails() async {
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
          SnackBar(content: Text('application_sent'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_applying'.tr())),
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
      await ApiService.deleteTaskApplication(widget.taskId);
      setState(() {
        _application = {};
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('application_withdrawn'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_withdrawing'.tr())),
        );
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
              icon: const Icon(Icons.description),
              label: Text('generate_contract'.tr()),
              onPressed: () {
                // Navigate to contract generation
              },
            ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: Text('edit'.tr()),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: Text('delete'.tr()),
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
              icon: const Icon(Icons.description),
              label: Text('view_contract'.tr()),
              onPressed: () {
                // Navigate to contract view
              },
            );
          }
          return const SizedBox.shrink();
        }
        return ElevatedButton.icon(
          icon: const Icon(Icons.cancel),
          label: Text('withdraw_application'.tr()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: _withdrawApplication,
        );
      }
      
      return ElevatedButton.icon(
        icon: const Icon(Icons.send),
        label: Text('apply_for_task'.tr()),
        onPressed: _isApplying ? null : _applyForTask,
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Task Details', 
          style: TextStyle(
            color: Colors.blueGrey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: _buildAppBarActions(),
        iconTheme: IconThemeData(color: Colors.blueGrey[800]),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTaskDetailBody(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
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
        icon: Icon(Icons.edit, color: Colors.blueGrey[700]),
        onPressed: () {
          // TODO: Implement edit task navigation
        },
      ),
      IconButton(
        icon: Icon(Icons.delete, color: Colors.red[700]),
        onPressed: _showDeleteConfirmationDialog,
      ),
    ];
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
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
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        : const AssetImage('assets/images/default_logo1.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 16),
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
              const SizedBox(height: 24),

              // Location
              _buildInfoRow(
                Icons.location_on,
                '${_taskDetails['street']}, ${_taskDetails['city']}',
              ),
              const SizedBox(height: 16),

              // Dates
              _buildInfoRow(
                Icons.calendar_today,
                'Start: ${DateFormat('MMM d, yyyy').format(DateTime.parse(_taskDetails['start_date']))}',
              ),
              if (_taskDetails['end_date'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.event,
                  'End: ${DateFormat('MMM d, yyyy').format(DateTime.parse(_taskDetails['end_date']))}',
                ),
              ],
              const SizedBox(height: 16),

              // Price
              if (_taskDetails['proposed_price'] != null)
                _buildInfoRow(
                  Icons.attach_money,
                  'Proposed Price: ${_formatPrice(_taskDetails['proposed_price'])}',
                ),

              const SizedBox(height: 24),

              // Task Details Section
              Text(
                'Task Details',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

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
                      const SizedBox(height: 4),
                      Text(
                        entry.value.toString(),
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
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
                const SizedBox(height: 8),
                ..._taskDetails['measurements'].entries.map((entry) {
                  final label = entry.key.toString().replaceAll('_', ' ').split(' ')
                    .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
                    .join(' ');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 8),
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
        const SizedBox(width: 8),
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