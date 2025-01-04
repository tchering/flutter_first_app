import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Team'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFC3CFE2),
            ],
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Founder Profile Card
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Profile Header
                          Container(
                            height: 200,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
                              ),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                          ),
                          // Profile Image
                          Transform.translate(
                            offset: const Offset(0, -75),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const CircleAvatar(
                                radius: 75,
                                backgroundImage: NetworkImage('https://avatars.githubusercontent.com/u/your-github-username'),
                              ),
                            ),
                          ),
                          // Profile Content
                          Transform.translate(
                            offset: const Offset(0, -60),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Text(
                                    'Sonam Sherpa',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Founder & Technology Innovator',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF546E7A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'A visionary developer with a unique blend of expertise in Ruby on Rails, PHP, and construction industry insights. Graduate of CMFP with distinction, Sonam bridges the gap between technology and construction, bringing innovative solutions to age-old industry challenges.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF455A64),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Social Links
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildSocialButton(
                                        icon: FontAwesomeIcons.linkedinIn,
                                        onPressed: () {
                                          // Add LinkedIn URL
                                        },
                                      ),
                                      const SizedBox(width: 16),
                                      _buildSocialButton(
                                        icon: FontAwesomeIcons.github,
                                        onPressed: () {
                                          // Add GitHub URL
                                        },
                                      ),
                                      const SizedBox(width: 16),
                                      _buildSocialButton(
                                        icon: FontAwesomeIcons.twitter,
                                        onPressed: () {
                                          // Add Twitter URL
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Company Story Card
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Building the Future of Construction',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'MiniDost represents the convergence of technology and construction expertise, born from years of industry experience and technological innovation. Our platform bridges critical gaps in the construction sector, fostering collaboration and efficiency.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF546E7A),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Timeline
                            ..._buildTimelineItems(),
                            const SizedBox(height: 32),
                            // Values Grid
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _buildValueCard(
                                  icon: Icons.security,
                                  title: 'Trust & Quality',
                                  description: 'Building lasting relationships through verified professionals and guaranteed quality work.',
                                ),
                                _buildValueCard(
                                  icon: Icons.lightbulb,
                                  title: 'Innovation',
                                  description: 'Constantly evolving our platform with cutting-edge technology and industry best practices.',
                                ),
                                _buildValueCard(
                                  icon: Icons.people,
                                  title: 'Community',
                                  description: 'Fostering a strong network of construction professionals who support and elevate each other.',
                                ),
                                _buildValueCard(
                                  icon: Icons.trending_up,
                                  title: 'Growth',
                                  description: 'Enabling sustainable business growth through efficient project management and networking.',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      elevation: 2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF5F5F5),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1A237E),
            size: 20,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTimelineItems() {
    final items = [
      {
        'title': 'Digital Transformation',
        'content': 'Revolutionizing traditional construction management through cutting-edge digital solutions that streamline workflows and enhance collaboration.',
      },
      {
        'title': 'Industry Connection',
        'content': 'Creating a robust network of verified professionals, enabling seamless partnerships between contractors and skilled craftsmen.',
      },
      {
        'title': 'Future Vision',
        'content': 'Developing AI-powered tools for precise project estimation and intelligent matching of professionals based on expertise and project requirements.',
      },
    ];

    return items.map((item) => _buildTimelineItem(item['title']!, item['content']!)).toList();
  }

  Widget _buildTimelineItem(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.only(left: 16),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Color(0xFF1A237E),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF455A64),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 180),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xFFF8F9FA),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: const Color(0xFF1A237E),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF455A64),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
