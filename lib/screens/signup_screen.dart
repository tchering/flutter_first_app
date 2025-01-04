import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: size.width > 400 ? 400 : size.width,
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  FontAwesomeIcons.userPlus,
                                  size: 32,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              Text(
                                'Create Business Account',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign up to get started',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 32),

                              _buildSectionCard(
                                'Company Information',
                                Column(
                                  children: [
                                    _buildDropdownField('Legal Status', ['SARL', 'SA', 'Other']),
                                    _buildTextField('Company Name'),
                                    _buildDropdownField('Position', ['Contractor', 'Sub-contractor']),
                                    _buildDropdownField('Establishment Date', 
                                        List.generate(100, (i) => (DateTime.now().year - i).toString())),
                                    _buildTextField('Activity Sector'),
                                    _buildTextField('Street'),
                                    _buildTextField('Area Code'),
                                    _buildTextField('City'),
                                    _buildTextField('SIRET Number'),
                                    _buildTextField('Number of Employees'),
                                    _buildTextField('Turnover'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildSectionCard(
                                'Personal Information',
                                Column(
                                  children: [
                                    _buildTextField('First Name'),
                                    _buildTextField('Last Name'),
                                    _buildTextField('Email', isEmail: true),
                                    _buildTextField('Phone Number'),
                                    _buildTextField('Password', isPassword: true),
                                    _buildTextField('Confirm Password', isPassword: true),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Handle form submission
                                    }
                                  },
                                  child: const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Back button - moved to the end of Stack to be on top
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildTextField(String label, {bool isPassword = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            _getIconForField(label),
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (isEmail && !value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            _getIconForField(label),
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (_) {},
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  IconData _getIconForField(String label) {
    switch (label.toLowerCase()) {
      case 'legal status':
        return FontAwesomeIcons.buildingColumns;
      case 'company name':
        return FontAwesomeIcons.building;
      case 'position':
        return FontAwesomeIcons.briefcase;
      case 'establishment date':
        return FontAwesomeIcons.calendar;
      case 'activity sector':
        return FontAwesomeIcons.industry;
      case 'street':
        return FontAwesomeIcons.road;
      case 'area code':
        return FontAwesomeIcons.locationDot;
      case 'city':
        return FontAwesomeIcons.city;
      case 'siret number':
        return FontAwesomeIcons.idCard;
      case 'number of employees':
        return FontAwesomeIcons.users;
      case 'turnover':
        return FontAwesomeIcons.chartLine;
      case 'first name':
        return FontAwesomeIcons.user;
      case 'last name':
        return FontAwesomeIcons.user;
      case 'email':
        return FontAwesomeIcons.envelope;
      case 'phone number':
        return FontAwesomeIcons.phone;
      case 'password':
      case 'confirm password':
        return FontAwesomeIcons.lock;
      default:
        return FontAwesomeIcons.circleInfo;
    }
  }
}
