import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import '../screens/task_list_screen.dart';
import '../screens/job_search_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool isContractor;
  
  const DashboardScreen({
    super.key,
    this.isContractor = true,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic> _userProfile = {};
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _projectStatistics = {};

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchProjectStatistics();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userProfile = await ApiService.fetchUserProfile();
      setState(() {
        _userProfile = userProfile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProjectStatistics() async {
    try {
      final projectStatistics = await ApiService.fetchProjectStatistics();
      setState(() {
        _projectStatistics = projectStatistics;
      });
    } catch (e) {
      print('Error fetching project statistics: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load project statistics: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isContractor ? tr('contractor_dashboard') : tr('subcontractor_dashboard')),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Professional',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Projects',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildUserInfoCard(),
          ),
        );
      case 1:
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildProfessionalProfileCard(),
          ),
        );
      case 2:
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                widget.isContractor 
                  ? _buildContractorStats() 
                  : _buildSubcontractorStats(),
                const SizedBox(height: 16),
                if (widget.isContractor) _buildQuickActions(),
              ],
            ),
          ),
        );
      default:
        return const Center(child: Text('Unknown section'));
    }
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _userProfile['logo_url'] != null
                ? NetworkImage(_userProfile['logo_url'])
                : const AssetImage('assets/images/default_logo.png') as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              _userProfile['company_name'] ?? 'Company Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                _userProfile['position'] ?? (widget.isContractor ? tr('contractor') : tr('subcontractor')),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildContactInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('Email'),
          subtitle: Text(_userProfile['email'] ?? 'N/A'),
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text('Phone'),
          subtitle: Text(_userProfile['phone'] ?? 'N/A'),
        ),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Location'),
          subtitle: Text(_userProfile['address'] ?? 'N/A'),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Member Since'),
          subtitle: Text(_formatMemberSince(_userProfile['created_at'])),
        ),
      ],
    );
  }

  Widget _buildProfessionalProfileCard() {
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Professional Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Professional bio and description goes here. This section can be expanded to include more details about the company or individual\'s professional background and expertise.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractorStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            'Projects Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 1.7,
          children: [
            _buildAnalyticsCard(
              icon: FontAwesomeIcons.briefcase,
              value: '${_projectStatistics['total_projects'] ?? 0}',
              label: tr('total_projects'),
              color: Colors.blue,
              hasNotification: false,
            ),
            _buildAnalyticsCard(
              icon: FontAwesomeIcons.clock,
              value: '${_projectStatistics['pending_projects'] ?? 0}',
              label: tr('pending'),
              color: Colors.orange,
              hasNotification: false,
            ),
            _buildAnalyticsCard(
              icon: FontAwesomeIcons.hammer,
              value: '${_projectStatistics['active_projects'] ?? 0}',
              label: tr('active'),
              color: Colors.green,
              hasNotification: _projectStatistics['active_tasks_applications_count'] != null && 
                               _projectStatistics['active_tasks_applications_count'] > 0,
              notificationCount: '${_projectStatistics['active_tasks_applications_count'] ?? 0}',
              notificationLabel: tr('applications'),
            ),
            _buildAnalyticsCard(
              icon: FontAwesomeIcons.spinner,
              value: '${_projectStatistics['in_progress_projects'] ?? 0}',
              label: tr('in_progress'),
              color: Colors.teal,
              hasNotification: false,
            ),
            _buildAnalyticsCard(
              icon: FontAwesomeIcons.checkDouble,
              value: '${_projectStatistics['completed_projects'] ?? 0}',
              label: tr('completed'),
              color: Colors.purple,
              hasNotification: false,
            ),
            _buildAnalyticsCard(
              icon: FontAwesomeIcons.checkCircle,
              value: '${_projectStatistics['approved_applications'] ?? 0}',
              label: tr('tasks_approved'),
              color: Colors.indigo,
              hasNotification: _projectStatistics['tasks_without_contracts'] != null && 
                               _projectStatistics['tasks_without_contracts'] > 0,
              notificationCount: '${_projectStatistics['tasks_without_contracts'] ?? 0}',
              notificationLabel: tr('generate_contract'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubcontractorStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            'Project Applications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 1.7,
          children: [
            _buildAnalyticsCard(
              icon: FontAwesomeIcons.checkCircle,
              value: '${_projectStatistics['approved_applications'] ?? 0}',
              label: tr('applications_approved'),
              color: Colors.green,
              hasNotification: false,
            ),
            _buildAnalyticsCard(
              icon: FontAwesomeIcons.clock,
              value: '${_projectStatistics['pending_applications'] ?? 0}',
              label: tr('applications_pending'),
              color: Colors.orange,
              hasNotification: false,
            ),
            _buildAnalyticsCard(
              icon: FontAwesomeIcons.times,
              value: '${_projectStatistics['rejected_applications'] ?? 0}',
              label: tr('applications_rejected'),
              color: Colors.red,
              hasNotification: false,
            ),
            _buildAnalyticsCard(
              icon: FontAwesomeIcons.hammer,
              value: '${_projectStatistics['in_progress_projects'] ?? 0}',
              label: tr('in_progress'),
              color: Colors.blue,
              hasNotification: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool hasNotification,
    String? notificationCount,
    String? notificationLabel,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Determine the status based on the label
          String status;
          switch (label) {
            case 'Total Projects':
              status = 'all';
              break;
            case 'Pending':
              status = 'pending';
              break;
            case 'Active':
              status = 'active';
              break;
            case 'In Progress':
              status = 'in progress';
              break;
            case 'Completed':
              status = 'completed';
              break;
            case 'Travaux Approved':
              status = 'approved';
              break;
            default:
              status = label.toLowerCase();
          }

          // Navigate to TaskListScreen
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => TaskListScreen(
                status: status, 
                isContractor: widget.isContractor
              )
            )
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 28,
                      ),
                      if (hasNotification)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              if (hasNotification && notificationCount != null)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$notificationCount $notificationLabel',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add,
                    label: tr('new_project'),
                    color: Colors.blue,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.search,
                    label: tr('find_jobs'),
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JobSearchScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMemberSince(String? createdAt) {
    if (createdAt == null) return 'N/A';
    try {
      final DateTime parsedDate = DateTime.parse(createdAt);
      return DateFormat('MMMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return 'N/A';
    }
  }
}
