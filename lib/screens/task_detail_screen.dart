import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';

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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        elevation: 0,
        actions: _buildAppBarActions(),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _buildTaskDetailBody(),
    );
  }

  List<Widget>? _buildAppBarActions() {
    // Only show actions for contractors
    if (!widget.isContractor) return null;

    return [
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          // TODO: Implement edit task navigation
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (context) => EditTaskScreen(taskId: widget.taskId)
          // ));
        },
      ),
      IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          _showDeleteConfirmationDialog();
        },
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTaskHeaderCard(),
            const SizedBox(height: 16),
            _buildSiteInformationCard(),
            const SizedBox(height: 16),
            _buildPriceDetailsCard(),
            const SizedBox(height: 16),
            _buildScheduleCard(),
            const SizedBox(height: 16),
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildTaskSpecificDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _taskDetails['site_name'] ?? 'Unnamed Task',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      _taskDetails['status'] ?? 'Unknown', 
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getStatusColor(_taskDetails['status']),
                  ),
                ],
              ),
            ),
            if (_taskDetails['applications_count'] != null)
              Chip(
                label: Text('${_taskDetails['applications_count']} Applications'),
                backgroundColor: Colors.blue.shade50,
                labelStyle: TextStyle(color: Colors.blue.shade700),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteInformationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Site Information', Icons.location_on),
            const SizedBox(height: 16),
            _buildDetailRow('Site Name', _taskDetails['site_name'] ?? 'N/A'),
            _buildDetailRow('Address', 
              '${_taskDetails['street'] ?? 'N/A'}, '
              '${_taskDetails['city'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Price Details', Icons.euro),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Proposed Price', 
              '€${_taskDetails['proposed_price']?.toStringAsFixed(2) ?? 'N/A'}'
            ),
            _buildDetailRow(
              'Accepted Price', 
              '€${_taskDetails['accepted_price']?.toStringAsFixed(2) ?? 'N/A'}'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Schedule', Icons.calendar_today),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Start Date', 
              _formatDate(_taskDetails['start_date'])
            ),
            _buildDetailRow(
              'End Date', 
              _formatDate(_taskDetails['end_date'])
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Status', Icons.info_outline),
            const SizedBox(height: 16),
            _buildDetailRow('Current Status', _taskDetails['status'] ?? 'N/A'),
            _buildDetailRow('Work Progress', _taskDetails['work_progress'] ?? 'N/A'),
            _buildDetailRow('Billing Process', _taskDetails['billing_process'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSpecificDetailsCard() {
    // TODO: Implement dynamic task-specific details based on task type
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Task Details', Icons.construction),
            const SizedBox(height: 16),
            Text(
              'Detailed task-specific information will be added in future updates.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('MMMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return 'N/A';
    }
  }

  Color _getStatusColor(String? status) {
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