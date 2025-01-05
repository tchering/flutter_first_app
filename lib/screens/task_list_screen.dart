import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import '../screens/task_detail_screen.dart';
import '../screens/application_review_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String status;
  final bool isContractor;

  const TaskListScreen({
    Key? key,
    required this.status,
    required this.isContractor,
  }) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<dynamic> tasks = [];
  bool isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final response = await ApiService.getTasks(
        status: widget.status,
        isContractor: widget.isContractor,
      );
      setState(() {
        tasks = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = 'Error loading tasks: $e';
      });
    }
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

  void _showApplicationsDialog(BuildContext context, Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header with back button
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Applications for ${task['site_name']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Applications list
                  Expanded(
                    child: FutureBuilder(
                      future: ApiService.getTaskApplications(task['id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error loading applications'));
                        }
                        final applications = snapshot.data as List<dynamic>;
                        return ListView.builder(
                          controller: controller,
                          padding: EdgeInsets.all(16),
                          itemCount: applications.length,
                          itemBuilder: (context, index) {
                            final application = applications[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ApplicationReviewScreen(
                                        taskId: task['id'],
                                        applicationId: application['id'],
                                        taskDetails: task,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.grey[200],
                                            child: Icon(Icons.person),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  application['subcontractor_name'] ?? 'Unknown',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  'Submitted on ${DateFormat('MMM d, yyyy').format(DateTime.parse(application['created_at']))}',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(application['status']).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              application['status']?.toUpperCase() ?? 'PENDING',
                                              style: TextStyle(
                                                color: _getStatusColor(application['status']),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (application['proposed_price'] != null) ...[
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.euro, size: 16, color: Colors.grey[600]),
                                            SizedBox(width: 4),
                                            Text(
                                              'Proposed: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(double.parse(application['proposed_price'].toString()))}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
                          SizedBox(height: 16),
                          Text(
                            'No ${widget.status} tasks found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/task_detail',
                                arguments: task['id'],
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task['site_name'] ?? 'Unnamed Task',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '${task['street']}, ${task['city']}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (widget.isContractor && task['applications_count'] > 0)
                                        TextButton.icon(
                                          onPressed: () => _showApplicationsDialog(context, task),
                                          icon: Icon(Icons.people),
                                          label: Text('${task['applications_count']} Applications'),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.blue.shade50,
                                            foregroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.euro, size: 16, color: Colors.grey[600]),
                                      SizedBox(width: 4),
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'fr_FR',
                                          symbol: '€',
                                        ).format(double.parse(task['proposed_price'].toString())),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(task['status']).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          task['status']?.toUpperCase() ?? 'PENDING',
                                          style: TextStyle(
                                            color: _getStatusColor(task['status']),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  String _getTitle() {
    if (widget.status == 'all') return 'All Tasks';
    return '${widget.status.capitalize()} Tasks';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}