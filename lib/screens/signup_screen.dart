import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActivitySector {
  static const Map<String, List<String>> sectors = {
    "Interior Design & Finishing": [
      "Building Cleaning Pro.",
      "Interior Designer",
      "Painter",
      "Plasterer",
      "Carpet Layer",
      "Tile Setter",
    ],
    "Technical Equipment": [
      "Electrician",
      "Plumber",
      "HVAC Installer",
    ],
    "Building Envelope": [
      "Rope Access Technician",
      "Roofer",
      "Waterproofer",
      "Metal Joinery",
    ],
    "Structure & Construction": [
      "Wood Carpenter",
      "Equipment Operator",
      "Wood Constructor",
      "Reinforced Concrete Constructor",
      "Industrial Flooring Constructor",
      "Metal Constructor",
      "Demolition Expert",
      "Crane Operator",
      "Mason",
      "Scaffolding Assembler",
      "Lifting Equipment Assembler",
      "Stone Cutter",
    ],
  };
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool isCompanyInfoStep = true;
  bool _isPasswordVisible = false;
  
  // Animation controllers
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  
  // Company Information Controllers
  final _legalStatusController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _establishmentDateController = TextEditingController();
  final _siretNumberController = TextEditingController();
  final _streetController = TextEditingController();
  final _areaCodeController = TextEditingController();
  final _cityController = TextEditingController();
  
  // Personal Information Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? selectedMainSector;
  String? selectedSubSector;
  List<String> subSectors = [];
  String? selectedPosition;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _legalStatusController.dispose();
    _companyNameController.dispose();
    _establishmentDateController.dispose();
    _siretNumberController.dispose();
    _streetController.dispose();
    _areaCodeController.dispose();
    _cityController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _moveToNextStep() {
    if (_formKey.currentState!.validate() && 
        selectedMainSector != null && 
        selectedSubSector != null && 
        selectedPosition != null) {
      setState(() {
        isCompanyInfoStep = false;
      });
    }
  }

  void _moveToPreviousStep() {
    setState(() {
      isCompanyInfoStep = true;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement signup logic
      print('Form submitted');
    }
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
                                  isCompanyInfoStep
                                      ? FontAwesomeIcons.building
                                      : FontAwesomeIcons.userPlus,
                                  size: 32,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              Text(
                                isCompanyInfoStep
                                    ? 'Company Information'
                                    : 'Personal Information',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isCompanyInfoStep
                                    ? 'Step 1 of 2'
                                    : 'Step 2 of 2',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Form fields
                              if (isCompanyInfoStep)
                                _buildCompanyInfoForm(theme)
                              else
                                _buildPersonalInfoForm(theme),

                              const SizedBox(height: 24),

                              // Navigation buttons
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
                                  onPressed: isCompanyInfoStep ? _moveToNextStep : _submitForm,
                                  child: Text(
                                    isCompanyInfoStep ? 'Next' : 'Create Account',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              if (!isCompanyInfoStep) ...[
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: _moveToPreviousStep,
                                  child: Text(
                                    'Back to Company Information',
                                    style: TextStyle(color: theme.primaryColor),
                                  ),
                                ),
                              ],
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

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: IconButton(
              icon: Icon(
                isCompanyInfoStep ? Icons.close : Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: isCompanyInfoStep
                  ? () => Navigator.pop(context)
                  : _moveToPreviousStep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoForm(ThemeData theme) {
    return Column(
      children: [
        _buildDropdownField(
          'Legal Status',
          ['SARL', 'EURL', 'SA', 'SAS', 'Auto-entrepreneur'],
          controller: _legalStatusController,
          icon: FontAwesomeIcons.buildingColumns,
          theme: theme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select legal status';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Company Name',
          controller: _companyNameController,
          icon: FontAwesomeIcons.building,
          theme: theme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter company name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Position',
          ['Contractor', 'Sub-contractor'],
          icon: FontAwesomeIcons.briefcase,
          theme: theme,
          onChanged: (value) {
            setState(() {
              selectedPosition = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select position';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildActivitySectorDropdowns(theme),
        const SizedBox(height: 16),
        _buildTextField(
          'SIRET Number',
          controller: _siretNumberController,
          icon: FontAwesomeIcons.idCard,
          theme: theme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter SIRET number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Street',
          controller: _streetController,
          icon: FontAwesomeIcons.road,
          theme: theme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter street';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Area Code',
                controller: _areaCodeController,
                icon: FontAwesomeIcons.locationDot,
                theme: theme,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter area code';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'City',
                controller: _cityController,
                icon: FontAwesomeIcons.city,
                theme: theme,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonalInfoForm(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'First Name',
                controller: _firstNameController,
                icon: FontAwesomeIcons.user,
                theme: theme,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'Last Name',
                controller: _lastNameController,
                icon: FontAwesomeIcons.user,
                theme: theme,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Email',
          controller: _emailController,
          icon: FontAwesomeIcons.envelope,
          theme: theme,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Phone',
          controller: _phoneController,
          icon: FontAwesomeIcons.phone,
          theme: theme,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Password',
          controller: _passwordController,
          icon: FontAwesomeIcons.lock,
          theme: theme,
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: theme.primaryColor,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Confirm Password',
          controller: _confirmPasswordController,
          icon: FontAwesomeIcons.lock,
          theme: theme,
          obscureText: !_isPasswordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label, {
    TextEditingController? controller,
    IconData? icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    ThemeData? theme,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 20,
          color: theme?.primaryColor,
        ),
        suffixIcon: suffixIcon,
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
            color: theme?.primaryColor ?? Colors.blue,
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items, {
    TextEditingController? controller,
    void Function(String?)? onChanged,
    IconData? icon,
    ThemeData? theme,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 20,
          color: theme?.primaryColor,
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
            color: theme?.primaryColor ?? Colors.blue,
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
      onChanged: onChanged ?? (String? value) {
        if (controller != null) {
          controller.text = value ?? '';
        }
      },
      validator: validator,
    );
  }

  Widget _buildActivitySectorDropdowns(ThemeData theme) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Main Sector',
            prefixIcon: Icon(
              FontAwesomeIcons.industry,
              size: 20,
              color: theme.primaryColor,
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
                color: theme.primaryColor,
                width: 2,
              ),
            ),
          ),
          value: selectedMainSector,
          items: ActivitySector.sectors.keys.map((String sector) {
            return DropdownMenuItem<String>(
              value: sector,
              child: Text(sector),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedMainSector = newValue;
              selectedSubSector = null;
              if (newValue != null) {
                subSectors = ActivitySector.sectors[newValue] ?? [];
              } else {
                subSectors = [];
              }
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select main sector';
            }
            return null;
          },
        ),
        if (subSectors.isNotEmpty) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Sub Sector',
              prefixIcon: Icon(
                FontAwesomeIcons.toolbox,
                size: 20,
                color: theme.primaryColor,
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
                  color: theme.primaryColor,
                  width: 2,
                ),
              ),
            ),
            value: selectedSubSector,
            items: subSectors.map((String subSector) {
              return DropdownMenuItem<String>(
                value: subSector,
                child: Text(subSector),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedSubSector = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select sub sector';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}
