import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/api_service.dart';

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
  final _employeeNumberController = TextEditingController();

  String? selectedMainSector;
  String? selectedSubSector;
  List<String> subSectors = [];
  String? selectedPosition;
  String? selectedEstablishmentYear;

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
    _employeeNumberController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _moveToNextStep() {
    if (_formKey.currentState!.validate() && 
        selectedMainSector != null && 
        selectedSubSector != null && 
        selectedPosition != null && 
        selectedEstablishmentYear != null) {
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userData = {
          'email': _emailController.text,
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'company_name': _companyNameController.text,
          'legal_status': _legalStatusController.text,
          'position': selectedPosition,
          'main_sector': selectedMainSector,
          'sub_sector': selectedSubSector,
          'siret_number': _siretNumberController.text,
          'street': _streetController.text,
          'area_code': _areaCodeController.text,
          'city': _cityController.text,
          'establishment_date': selectedEstablishmentYear,
          'employees_number': int.parse(_employeeNumberController.text),
        };

        final response = await ApiService.signup(userData);
        // Handle successful signup
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr('signup.success'))),
          );
          Navigator.of(context).pop(); // Return to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
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
                                    ? tr('signup.step1')
                                    : tr('signup.step2'),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isCompanyInfoStep
                                    ? tr('signup.step1of2')
                                    : tr('signup.step2of2'),
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
                                    isCompanyInfoStep ? tr('signup.buttons.next') : tr('signup.buttons.submit'),
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
                                    tr('signup.buttons.back'),
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
        _buildTextField(
          'signup.form.companyName'.tr(),
          controller: _companyNameController,
          icon: FontAwesomeIcons.building,
          theme: theme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return tr('signup.validation.required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Legal Status Dropdown
        _buildDropdownField(
          'signup.form.legalStatus'.tr(),
          ['SARL', 'EURL', 'SA', 'SAS', 'Auto-entrepreneur'],
          controller: _legalStatusController,
          icon: FontAwesomeIcons.scaleBalanced,
          theme: theme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return tr('signup.validation.required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Position Dropdown
        _buildDropdownField(
          'signup.form.position'.tr(),
          ['Contractor', 'Sub-contractor'],
          onChanged: (value) {
            setState(() {
              selectedPosition = value;
            });
          },
          icon: FontAwesomeIcons.userTie,
          theme: theme,
          validator: (value) {
            if (selectedPosition == null) {
              return tr('signup.validation.required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Establishment Year Dropdown
        _buildDropdownField(
          'signup.form.establishmentYear'.tr(),
          ApiService.getEstablishmentYears(),
          onChanged: (value) {
            setState(() {
              selectedEstablishmentYear = value;
            });
          },
          icon: FontAwesomeIcons.calendar,
          theme: theme,
          validator: (value) {
            if (selectedEstablishmentYear == null) {
              return tr('signup.validation.establishmentDateRequired');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Employee Number Input
        _buildTextField(
          'signup.form.employeeNumber'.tr(),
          controller: _employeeNumberController,
          icon: FontAwesomeIcons.users,
          theme: theme,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return tr('signup.validation.employeesNumberRequired');
            }
            // Validate that it's a number
            if (int.tryParse(value) == null) {
              return tr('signup.validation.invalidNumber');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildActivitySectorDropdowns(theme),
        const SizedBox(height: 16),
        _buildTextField(
          'signup.form.siretNumber'.tr(),
          controller: _siretNumberController,
          icon: FontAwesomeIcons.idCard,
          theme: theme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return tr('signup.validation.required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'signup.form.street'.tr(),
          controller: _streetController,
          icon: FontAwesomeIcons.road,
          theme: theme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return tr('signup.validation.required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'signup.form.areaCode'.tr(),
                controller: _areaCodeController,
                icon: FontAwesomeIcons.locationDot,
                theme: theme,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('signup.validation.required');
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'signup.form.city'.tr(),
                controller: _cityController,
                icon: FontAwesomeIcons.city,
                theme: theme,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('signup.validation.required');
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
                'signup.form.firstName'.tr(),
                controller: _firstNameController,
                icon: FontAwesomeIcons.user,
                theme: theme,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('signup.validation.required');
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'signup.form.lastName'.tr(),
                controller: _lastNameController,
                icon: FontAwesomeIcons.user,
                theme: theme,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('signup.validation.required');
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'signup.form.email'.tr(),
          controller: _emailController,
          icon: FontAwesomeIcons.envelope,
          theme: theme,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return tr('signup.validation.required');
            }
            if (!value.contains('@')) {
              return tr('signup.validation.email');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'signup.form.phone'.tr(),
          controller: _phoneController,
          icon: FontAwesomeIcons.phone,
          theme: theme,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return tr('signup.validation.required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'signup.form.password'.tr(),
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
              return tr('signup.validation.required');
            }
            if (value.length < 6) {
              return tr('signup.validation.password');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'signup.form.confirmPassword'.tr(),
          controller: _confirmPasswordController,
          icon: FontAwesomeIcons.lock,
          theme: theme,
          obscureText: !_isPasswordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return tr('signup.validation.required');
            }
            if (value != _passwordController.text) {
              return tr('signup.validation.passwordMatch');
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
            labelText: 'signup.form.mainSector'.tr(),
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
          items: [
            tr('sectors.interiorDesign.name'),
            tr('sectors.technicalEquipment.name'),
            tr('sectors.buildingEnvelope.name'),
            tr('sectors.structureConstruction.name'),
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedMainSector = newValue;
              selectedSubSector = null;
              if (newValue == tr('sectors.interiorDesign.name')) {
                subSectors = [
                  tr('sectors.interiorDesign.subsectors.buildingCleaning'),
                  tr('sectors.interiorDesign.subsectors.interiorDesigner'),
                  tr('sectors.interiorDesign.subsectors.painter'),
                  tr('sectors.interiorDesign.subsectors.plasterer'),
                  tr('sectors.interiorDesign.subsectors.carpetLayer'),
                  tr('sectors.interiorDesign.subsectors.tileSetter'),
                ];
              } else if (newValue == tr('sectors.technicalEquipment.name')) {
                subSectors = [
                  tr('sectors.technicalEquipment.subsectors.electrician'),
                  tr('sectors.technicalEquipment.subsectors.plumber'),
                  tr('sectors.technicalEquipment.subsectors.hvacInstaller'),
                ];
              } else if (newValue == tr('sectors.buildingEnvelope.name')) {
                subSectors = [
                  tr('sectors.buildingEnvelope.subsectors.ropeAccess'),
                  tr('sectors.buildingEnvelope.subsectors.roofer'),
                  tr('sectors.buildingEnvelope.subsectors.waterproofer'),
                  tr('sectors.buildingEnvelope.subsectors.metalJoinery'),
                  tr('sectors.buildingEnvelope.subsectors.glazier'),
                  tr('sectors.buildingEnvelope.subsectors.blindInstaller'),
                ];
              } else if (newValue == tr('sectors.structureConstruction.name')) {
                subSectors = [
                  tr('sectors.structureConstruction.subsectors.woodCarpenter'),
                  tr('sectors.structureConstruction.subsectors.machineOperator'),
                  tr('sectors.structureConstruction.subsectors.woodConstructor'),
                  tr('sectors.structureConstruction.subsectors.concreteConstructor'),
                  tr('sectors.structureConstruction.subsectors.industrialFloorConstructor'),
                  tr('sectors.structureConstruction.subsectors.metalConstructor'),
                  tr('sectors.structureConstruction.subsectors.demolisher'),
                  tr('sectors.structureConstruction.subsectors.craneOperator'),
                  tr('sectors.structureConstruction.subsectors.mason'),
                  tr('sectors.structureConstruction.subsectors.scaffoldErector'),
                  tr('sectors.structureConstruction.subsectors.liftingAssembler'),
                  tr('sectors.structureConstruction.subsectors.stoneCutter'),
                ];
              }
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return tr('signup.validation.required');
            }
            return null;
          },
        ),
        if (selectedMainSector != null) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'signup.form.subSector'.tr(),
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
            items: subSectors.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedSubSector = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr('signup.validation.required');
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}
