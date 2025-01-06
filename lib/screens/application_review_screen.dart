import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class ApplicationReviewScreen extends StatefulWidget {
  final int taskId;
  final int applicationId;
  final Map<String, dynamic> taskDetails;

  const ApplicationReviewScreen({
    Key? key,
    required this.taskId,
    required this.applicationId,
    required this.taskDetails,
  }) : super(key: key);

  @override
  _ApplicationReviewScreenState createState() => _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  bool isLoading = true;
  Map<String, dynamic>? application;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;
  bool _isEditing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.taskDetails['proposed_price']?.toString() ?? '',
    );
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    try {
      setState(() {
        isLoading = true;
        _error = null;
      });

      final data = await ApiService.getTaskApplication(
        widget.taskId,
        applicationId: widget.applicationId,
      );

      setState(() {
        application = data;
        isLoading = false;
        _priceController.text = widget.taskDetails['proposed_price'].toString();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _updateApplicationStatus(String status) async {
    try {
      setState(() {
        isLoading = true;
        _error = null;
      });

      await ApiService.updateTaskApplication(
        widget.taskId,
        widget.applicationId,
        status,
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _updateTaskPrice() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        isLoading = true;
        _error = null;
      });

      await ApiService.updateTask(
        widget.taskId,
        {'proposed_price': double.parse(_priceController.text)},
      );

      setState(() {
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task price updated successfully')),
        );
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Review Application'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : application == null
              ? const Center(child: Text('Application not found'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Details Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Task Details',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  'Site',
                                  widget.taskDetails['site_name'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  'Location',
                                  '${widget.taskDetails['street']}, ${widget.taskDetails['city']}',
                                ),
                                _buildInfoRow(
                                  'Start Date',
                                  widget.taskDetails['start_date'] != null
                                      ? DateFormat('MMM d, yyyy').format(
                                          DateTime.parse(
                                              widget.taskDetails['start_date']))
                                      : 'Not set',
                                ),
                                _buildInfoRow(
                                  'End Date',
                                  widget.taskDetails['end_date'] != null
                                      ? DateFormat('MMM d, yyyy').format(
                                          DateTime.parse(
                                              widget.taskDetails['end_date']))
                                      : 'Not set',
                                ),
                                const SizedBox(height: 16),
                                Form(
                                  key: _formKey,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _isEditing
                                            ? TextFormField(
                                                controller: _priceController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: const InputDecoration(
                                                  labelText: 'Task Budget (€)',
                                                  border: OutlineInputBorder(),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter a price';
                                                  }
                                                  if (double.tryParse(value) ==
                                                      null) {
                                                    return 'Please enter a valid number';
                                                  }
                                                  return null;
                                                },
                                              )
                                            : _buildInfoRow(
                                                'Task Budget',
                                                NumberFormat.currency(
                                                  locale: 'fr_FR',
                                                  symbol: '€',
                                                ).format(double.parse(
                                                    widget.taskDetails[
                                                            'proposed_price']
                                                        .toString())),
                                              ),
                                      ),
                                      if (_isEditing)
                                        IconButton(
                                          icon: const Icon(Icons.check),
                                          onPressed: _updateTaskPrice,
                                        )
                                      else
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () =>
                                              setState(() => _isEditing = true),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Subcontractor Details Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Subcontractor Details',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  'Name',
                                  application!['subcontractor_name'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  'Email',
                                  application!['subcontractor_email'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  'Phone',
                                  application!['subcontractor_phone'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  'SIRET',
                                  application!['subcontractor_siret'] ?? 'N/A',
                                ),
                                if (application!['proposed_price'] != null)
                                  _buildInfoRow(
                                    'Proposed Price',
                                    NumberFormat.currency(
                                      locale: 'fr_FR',
                                      symbol: '€',
                                    ).format(double.parse(
                                        application!['proposed_price']
                                            .toString())),
                                  ),
                                if (application!['message']?.isNotEmpty ?? false)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Message',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(application!['message']),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Action Buttons
                        if (application!['status'] == 'pending')
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _updateApplicationStatus('approved'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('APPROVE'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _updateApplicationStatus('rejected'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('REJECT'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
}
