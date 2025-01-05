import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F51B5)),
            ),
          )
        : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!, 
                style: TextStyle(color: Colors.red[700]),
              ),
            )
          : _buildTaskDetailBody(),
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey[50]!,
              Colors.blueGrey[100]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Contractors', Icons.business),
                      const SizedBox(height: 16),
                      _buildContractorInfo(
                        'Contractor',
                        _taskDetails['contractor_name']?.toString() ?? 'N/A',
                        _taskDetails['contractor_logo'],
                      ),
                      const SizedBox(height: 12),
                      _buildContractorInfo(
                        'Sub Contractor',
                        _taskDetails['sub_contractor_name']?.toString() ?? 'N/A',
                        _taskDetails['sub_contractor_logo'],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_taskDetails['status']?.toString()),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(_taskDetails['status']?.toString()).withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _taskDetails['status']?.toString().toUpperCase() ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildContractorInfo(String label, String name, String? logoUrl) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!),
            image: logoUrl != null
                ? DecorationImage(
                    image: NetworkImage(logoUrl),
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    image: AssetImage('assets/images/default_logo1.png'),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSiteInformationCard() {
    return _buildDetailCard(
      title: 'Site Information',
      icon: Icons.location_on,
      children: [
        _buildDetailRow('Site Name', _taskDetails['site_name'] ?? 'N/A'),
        _buildDetailRow('Address', 
          '${_taskDetails['street'] ?? 'N/A'}, '
          '${_taskDetails['city'] ?? 'N/A'}'),
      ],
    );
  }

  Widget _buildPriceDetailsCard() {
    return _buildDetailCard(
      title: 'Price Details',
      icon: Icons.euro,
      children: [
        _buildDetailRow(
          'Proposed Price', 
          '€${(double.tryParse(_taskDetails['proposed_price']?.toString() ?? '') ?? 0).toStringAsFixed(2)}'
        ),
        _buildDetailRow(
          'Accepted Price', 
          '€${(double.tryParse(_taskDetails['accepted_price']?.toString() ?? '') ?? 0).toStringAsFixed(2)}'
        ),
      ],
    );
  }

  Widget _buildScheduleCard() {
    return _buildDetailCard(
      title: 'Schedule',
      icon: Icons.calendar_today,
      children: [
        _buildDetailRow(
          'Start Date', 
          _formatDate(_taskDetails['start_date'])
        ),
        _buildDetailRow(
          'End Date', 
          _formatDate(_taskDetails['end_date'])
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return _buildDetailCard(
      title: 'Status',
      icon: Icons.info_outline,
      children: [
        _buildDetailRow('Current Status', _taskDetails['status'] ?? 'N/A'),
        _buildDetailRow('Work Progress', _taskDetails['work_progress'] ?? 'N/A'),
        _buildDetailRow('Billing Process', _taskDetails['billing_process'] ?? 'N/A'),
      ],
    );
  }

  Widget _buildTaskSpecificDetailsCard() {
    final textAttributes = _taskDetails['text_attributes'] as Map<String, dynamic>?;
    final measurements = _taskDetails['measurements'] as Map<String, dynamic>?;
    final booleanServices = _taskDetails['boolean_services'] as Map<String, dynamic>?;

    return _buildDetailCard(
      title: 'Task Specific Details',
      icon: Icons.assignment,
      children: [
        // Text Attributes
        if (textAttributes != null && textAttributes.isNotEmpty) ...[
          for (var entry in textAttributes.entries)
            _buildDetailRow(
              entry.key.toString().replaceAll('_', ' ').toTitleCase(),
              entry.value?.toString() ?? 'N/A',
            ),
          const Divider(height: 24),
        ],

        // Measurements
        if (measurements != null && measurements.isNotEmpty) ...[
          Text(
            'Measurements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: measurements.entries.map((entry) {
              return SizedBox(
                width: 150,
                child: _buildDetailRow(
                  entry.key.toString().replaceAll('_', ' ').toTitleCase(),
                  '${entry.value} m²',
                ),
              );
            }).toList(),
          ),
          const Divider(height: 24),
        ],

        // Boolean Services
        if (booleanServices != null && booleanServices.isNotEmpty) ...[
          Text(
            'Services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: booleanServices.entries.map((entry) {
              return SizedBox(
                width: 200,
                child: Row(
                  children: [
                    Switch(
                      value: entry.value as bool? ?? false,
                      onChanged: null,
                      activeColor: const Color(0xFF3F51B5),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key.toString().replaceAll('_', ' ').toTitleCase(),
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
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

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.blueGrey[50]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(title, icon),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}