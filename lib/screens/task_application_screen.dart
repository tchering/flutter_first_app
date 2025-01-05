import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class TaskApplicationScreen extends StatefulWidget {
  final int taskId;

  const TaskApplicationScreen({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  @override
  State<TaskApplicationScreen> createState() => _TaskApplicationScreenState();
}

class _TaskApplicationScreenState extends State<TaskApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _proposedPriceController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _completionTimeframeController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _equipmentOwnedController = TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();
  final TextEditingController _referencesController = TextEditingController();
  String _insuranceStatus = '';
  bool _isNegotiable = false;

  @override
  void dispose() {
    _proposedPriceController.dispose();
    _experienceController.dispose();
    _coverLetterController.dispose();
    _completionTimeframeController.dispose();
    _skillsController.dispose();
    _equipmentOwnedController.dispose();
    _paymentTermsController.dispose();
    _referencesController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.applyForTaskWithDetails(
        taskId: widget.taskId,
        proposedPrice: double.parse(_proposedPriceController.text),
        experience: int.parse(_experienceController.text),
        coverLetter: _coverLetterController.text,
        completionTimeframe: _completionTimeframeController.text,
        insuranceStatus: _insuranceStatus,
        skills: _skillsController.text,
        equipmentOwned: _equipmentOwnedController.text,
        paymentTerms: _paymentTermsController.text,
        references: _referencesController.text,
        isNegotiable: _isNegotiable,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate successful application
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Application'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPriceField(),
                    const SizedBox(height: 16),
                    _buildExperienceField(),
                    const SizedBox(height: 16),
                    _buildCoverLetterField(),
                    const SizedBox(height: 16),
                    _buildTimeframeField(),
                    const SizedBox(height: 16),
                    _buildInsuranceField(),
                    const SizedBox(height: 16),
                    _buildSkillsField(),
                    const SizedBox(height: 16),
                    _buildEquipmentField(),
                    const SizedBox(height: 16),
                    _buildPaymentTermsField(),
                    const SizedBox(height: 16),
                    _buildReferencesField(),
                    const SizedBox(height: 16),
                    _buildNegotiableCheckbox(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitApplication,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Submit Application'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _proposedPriceController,
      decoration: const InputDecoration(
        labelText: 'Proposed Price (€)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.euro),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a proposed price';
        }
        return null;
      },
    );
  }

  Widget _buildExperienceField() {
    return TextFormField(
      controller: _experienceController,
      decoration: const InputDecoration(
        labelText: 'Years of Experience',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.work),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildCoverLetterField() {
    return TextFormField(
      controller: _coverLetterController,
      decoration: const InputDecoration(
        labelText: 'Cover Letter',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a cover letter';
        }
        return null;
      },
    );
  }

  Widget _buildTimeframeField() {
    return TextFormField(
      controller: _completionTimeframeController,
      decoration: const InputDecoration(
        labelText: 'Completion Timeframe',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.schedule),
      ),
    );
  }

  Widget _buildInsuranceField() {
    return DropdownButtonFormField<String>(
      value: _insuranceStatus.isEmpty ? null : _insuranceStatus,
      decoration: const InputDecoration(
        labelText: 'Insurance Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.security),
      ),
      items: ['Fully Insured', 'Partially Insured', 'Not Insured']
          .map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _insuranceStatus = newValue ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select insurance status';
        }
        return null;
      },
    );
  }

  Widget _buildSkillsField() {
    return TextFormField(
      controller: _skillsController,
      decoration: const InputDecoration(
        labelText: 'Skills',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.engineering),
        hintText: 'Enter your relevant skills',
      ),
    );
  }

  Widget _buildEquipmentField() {
    return TextFormField(
      controller: _equipmentOwnedController,
      decoration: const InputDecoration(
        labelText: 'Equipment Owned',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.handyman),
      ),
      maxLines: 2,
    );
  }

  Widget _buildPaymentTermsField() {
    return TextFormField(
      controller: _paymentTermsController,
      decoration: const InputDecoration(
        labelText: 'Payment Terms',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.payment),
      ),
    );
  }

  Widget _buildReferencesField() {
    return TextFormField(
      controller: _referencesController,
      decoration: const InputDecoration(
        labelText: 'References',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget _buildNegotiableCheckbox() {
    return CheckboxListTile(
      title: const Text('Price is negotiable'),
      value: _isNegotiable,
      onChanged: (bool? value) {
        setState(() {
          _isNegotiable = value ?? false;
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}
