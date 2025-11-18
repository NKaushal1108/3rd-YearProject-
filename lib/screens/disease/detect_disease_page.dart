import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/ml_service.dart';

import 'treatments_page.dart';

class DetectDiseasePage extends StatefulWidget {
  const DetectDiseasePage({super.key});

  @override
  State<DetectDiseasePage> createState() => _DetectDiseasePageState();
}

class _DetectDiseasePageState extends State<DetectDiseasePage> {
  final Color primary = const Color(0xFF36883B);
  final ImagePicker _picker = ImagePicker();
  final MLService _mlService = MLService();

  XFile? _selectedImage;
  bool _isDetecting = false;
  String? _predictedDisease;
  double? _confidence;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeML();
  }

  Future<void> _initializeML() async {
    try {
      await _mlService.initialize();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load ML model. Please restart the app.';
        });
      }
    }
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _predictedDisease = null;
        _confidence = null;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _predictedDisease = null;
        _confidence = null;
      });
    }
  }

  Future<void> _detectDisease() async {
    if (_selectedImage == null) return;

    setState(() {
      _isDetecting = true;
      _predictedDisease = null;
      _confidence = null;
      _errorMessage = null;
    });

    try {
      // Run ML model prediction
      final result = await _mlService.predictDisease(_selectedImage!.path);

      if (!mounted) return;

      setState(() {
        _predictedDisease = result['disease'] as String;
        _confidence = result['confidence'] as double;
        _isDetecting = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to detect disease: ${e.toString()}';
        _isDetecting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'An error occurred'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildPickers(),
                  const SizedBox(height: 24),
                  if (_selectedImage != null) _buildPreview(),
                  const SizedBox(height: 16),
                  _buildDetectButton(),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) _buildErrorMessage(),
                  if (_predictedDisease != null) _buildResultCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: const Text(
        'Detect Disease',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPickers() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _pickFromCamera,
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
            label: const Text(
              'Open Camera',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDAA520),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('or', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Upload a picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _pickFromGallery,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedImage == null ? 'Click Here' : _selectedImage!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.image_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_selectedImage!.path),
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedImage!.name,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDetectButton() {
    final bool enabled = _selectedImage != null && !_isDetecting;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? _detectDisease : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: _isDetecting
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : const Text(
                'DETECT',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1.2),
              ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Result',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF36883B)),
          ),
          const SizedBox(height: 12),
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImage!.path),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            _predictedDisease ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (_confidence != null) ...[
            const SizedBox(height: 6),
            Text('Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: 180,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (_predictedDisease == null) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TreatmentsPage(diseaseName: _predictedDisease!),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2FB44B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: const Text('Treatments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? 'An error occurred',
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}