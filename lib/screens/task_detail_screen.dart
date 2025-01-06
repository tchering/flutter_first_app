import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      print('Task Data: $taskData'); // Debug print
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _taskDetails == null
                  ? const Center(child: Text('Task not found'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await _loadTask();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTaskDetails(),
                            const SizedBox(height: 24),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contractor Information Section
            _buildSectionHeader('Contractor Information', Icons.business),
            const Divider(height: 24),
            _buildInfoRow(
              'Contractor',
              _taskDetails?['contractor_name'] ?? 'N/A',
            ),
            _buildInfoRow(
              'Sub Contractor',
              _taskDetails?['sub_contractor_name'] ?? 'N/A',
            ),
            
            const SizedBox(height: 24),
            // Site Information Section
            _buildSectionHeader('Site Information', Icons.location_on),
            const Divider(height: 24),
            _buildInfoRow('Site Name', _taskDetails?['site_name'] ?? 'N/A'),
            _buildInfoRow(
              'Address',
              '${_taskDetails?['street'] ?? ''}, ${_taskDetails?['city'] ?? ''}, ${_taskDetails?['area_code'] ?? ''}',
            ),
            _buildInfoRow('Postal Code', _taskDetails?['postal_code']?.toString() ?? 'N/A'),
            _buildInfoRow('Country', _taskDetails?['country'] ?? 'N/A'),
            
            const SizedBox(height: 24),
            // Price Details Section
            _buildSectionHeader('Price Details', Icons.euro),
            const Divider(height: 24),
            _buildInfoRow(
              'Proposed Price',
              _taskDetails?['proposed_price'] != null
                  ? NumberFormat.currency(locale: 'fr_FR', symbol: '€')
                      .format(double.parse(_taskDetails!['proposed_price'].toString()))
                  : 'N/A',
            ),
            if (_taskDetails?['accepted_price'] != null)
              _buildInfoRow(
                'Accepted Price',
                NumberFormat.currency(locale: 'fr_FR', symbol: '€')
                    .format(double.parse(_taskDetails!['accepted_price'].toString())),
              ),
            
            const SizedBox(height: 24),
            // Schedule Section
            _buildSectionHeader('Schedule', Icons.calendar_today),
            const Divider(height: 24),
            if (_taskDetails?['start_date'] != null)
              _buildInfoRow(
                'Start Date',
                DateFormat('MMMM d, yyyy').format(DateTime.parse(_taskDetails?['start_date'])),
              ),
            if (_taskDetails?['end_date'] != null)
              _buildInfoRow(
                'End Date',
                DateFormat('MMMM d, yyyy').format(DateTime.parse(_taskDetails?['end_date'])),
              ),
            
            const SizedBox(height: 24),
            // Task Status
            _buildSectionHeader('Status', Icons.info_outline),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_taskDetails?['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _taskDetails?['status']?.toString().toTitleCase() ?? 'PENDING',
                style: TextStyle(
                  color: _getStatusColor(_taskDetails?['status']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Taskable Attributes Section
            if (_taskDetails?['text_attributes'] != null ||
                _taskDetails?['measurements'] != null ||
                _taskDetails?['boolean_services'] != null) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('Additional Details', Icons.assignment),
              const Divider(height: 24),
              
              // Text Attributes
              if (_taskDetails?['text_attributes'] != null) ...[
                ..._buildTextAttributes(_taskDetails!['text_attributes']),
                const SizedBox(height: 16),
              ],
              
              // Measurements
              if (_taskDetails?['measurements'] != null) ...[
                const Text(
                  'Measurements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    for (var entry in (_taskDetails!['measurements'] as Map<String, dynamic>).entries)
                      _buildMeasurementChip(
                        entry.key.toString().replaceAll('surface_', '').toTitleCase(),
                        entry.value,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Boolean Services
              if (_taskDetails?['boolean_services'] != null) ...[
                const Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    for (var entry in (_taskDetails!['boolean_services'] as Map<String, dynamic>).entries)
                      if (entry.value == true)
                        Chip(
                          label: Text(entry.key.toString().toTitleCase()),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          labelStyle: const TextStyle(color: Colors.blue),
                        ),
                  ],
                ),
              ],
            ],
            
            // Description
            if (_taskDetails?['description'] != null) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('Description', Icons.description),
              const Divider(height: 24),
              Text(
                _taskDetails?['description'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
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
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTextAttributes(Map<String, dynamic> attributes) {
    return attributes.entries.map((entry) {
      return _buildInfoRow(
        entry.key.toString().toTitleCase(),
        entry.value?.toString() ?? 'N/A',
      );
    }).toList();
  }

  Widget _buildMeasurementChip(String name, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${name.toTitleCase()}: ${value.toString()} m²',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
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
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        child: const Text('Apply for this task'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Application',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.euro, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Proposed: ${NumberFormat.currency(
                    locale: 'fr_FR',
                    symbol: '€',
                  ).format(double.parse(_application?['proposed_price'].toString() ?? '0'))}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add withdraw application functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Withdraw Application'),
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