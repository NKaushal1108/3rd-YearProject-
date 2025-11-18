import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/paddy_field.dart';
import '../../utils/sri_lankan_districts.dart';
import '../../utils/district_paddy_varieties.dart';

class AddPaddyFieldPage extends StatefulWidget {
  const AddPaddyFieldPage({super.key});

  @override
  State<AddPaddyFieldPage> createState() => _AddPaddyFieldPageState();
}

class _AddPaddyFieldPageState extends State<AddPaddyFieldPage> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _areaSizeController = TextEditingController();
  final _nameController = TextEditingController();

  String? _selectedDistrict;
  final Color primary = const Color(0xFF36883B);
  List<String> _recommendedVarieties = const [];

  @override
  void dispose() {
    _locationController.dispose();
    _areaSizeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Paddy Fields',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Location'),
                    const SizedBox(height: 8),
                    _buildLocationDropdown(),

                    const SizedBox(height: 24),
                    _buildLabel('Area Size (අක්කර)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _areaSizeController,
                      hintText: 'Enter area size',
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),
                    _buildLabel('Paddy Field Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Enter paddy field name',
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ADD',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Row(
      children: [
        Text(
          '$text :',
          style: TextStyle(
            color: primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedDistrict,
            decoration: InputDecoration(
              hintText: 'Choose your district',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            items: SriLankanDistricts.districts.map((district) {
              return DropdownMenuItem(value: district, child: Text(district));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDistrict = value;
                _recommendedVarieties =
                    DistrictPaddyVarieties.getVarietiesFor(value);
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a district';
              }
              return null;
            },
          ),
          if (_recommendedVarieties.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recommended paddy varieties',
                style: TextStyle(
                  color: primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recommendedVarieties
                    .map(
                      (v) => Chip(
                        label: Text(v),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.visiblePassword,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
            : null,
        enableSuggestions: false,
        autocorrect: false,
        smartDashesType: SmartDashesType.disabled,
        smartQuotesType: SmartQuotesType.disabled,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final areaSize = double.tryParse(_areaSizeController.text);
      if (areaSize == null || areaSize <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid area size'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final newField = PaddyField(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        location: _selectedDistrict!,
        areaSize: areaSize,
        createdAt: DateTime.now(),
      );

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Success!', style: TextStyle(color: Colors.green)),
          content: const Text('Paddy field added successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(
                  context,
                  newField,
                ); // Return to home with new field
              },
              child: Text('OK', style: TextStyle(color: primary)),
            ),
          ],
        ),
      );
    }
  }
}
