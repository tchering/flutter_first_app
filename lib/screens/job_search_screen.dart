import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'task_detail_screen.dart'; // Import TaskDetailScreen

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks([String? query]) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tasks = await ApiService.fetchAvailableTasks(query: query);
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _fetchTasks(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('available_jobs'.tr()),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'search_jobs_hint'.tr(),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildTasksList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_tasks.isEmpty) {
      return Center(
        child: Text('no_jobs_found'.tr()),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(
                    taskId: task.id,
                    isContractor: false,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: task.contractorLogo != null
                            ? NetworkImage(task.contractorLogo!)
                            : const AssetImage('assets/images/logo_dost.png')
                                as ImageProvider,
                        radius: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.siteName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              task.contractorName,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${task.street}, ${task.city}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d, yyyy').format(task.startDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (task.proposedPrice != null) ...[
                        const Spacer(),
                        const Icon(Icons.attach_money, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          task.proposedPrice!.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
