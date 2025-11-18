import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class MLService {
  static const String _modelPath = 'assets/models/rice_disease_model.tflite';
  static const String _labelsPath = 'assets/models/labels.txt';
  
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  /// Initialize the ML model
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load model
      final modelData = await rootBundle.load(_modelPath);
      final modelBytes = modelData.buffer.asUint8List();
      _interpreter = Interpreter.fromBuffer(modelBytes);

      // Load labels
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels = labelsData.split('\n').where((label) => label.trim().isNotEmpty).toList();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize ML model: $e');
    }
  }

  /// Predict disease from image file
  Future<Map<String, dynamic>> predictDisease(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_interpreter == null) {
      throw Exception('Model not initialized');
    }

    try {
      // Preprocess image
      final inputImage = await _preprocessImage(imagePath);
      
      // Get model input/output shapes
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      // Prepare input/output buffers with proper shape
      final outputSize = outputShape[0] * outputShape[1];
      
      // Create properly shaped input buffer: [batch, height, width, channels]
      final inputBuffer = List.generate(
        inputShape[0],
        (_) => List.generate(
          inputShape[1],
          (_) => List.generate(
            inputShape[2],
            (_) => List.generate(inputShape[3], (_) => 0.0),
          ),
        ),
      );
      
      final outputBuffer = List.generate(
        outputSize,
        (index) => 0.0,
      );

      // Normalize image to input buffer
      for (int i = 0; i < inputShape[1]; i++) {
        for (int j = 0; j < inputShape[2]; j++) {
          final pixel = inputImage.getPixel(j, i);
          inputBuffer[0][i][j][0] = pixel.r.toDouble() / 255.0;
          inputBuffer[0][i][j][1] = pixel.g.toDouble() / 255.0;
          inputBuffer[0][i][j][2] = pixel.b.toDouble() / 255.0;
        }
      }

      // Run inference
      _interpreter!.run(inputBuffer, outputBuffer);

      // Get prediction results
      double maxValue = outputBuffer[0];
      int maxIndex = 0;
      for (int i = 1; i < outputBuffer.length; i++) {
        if (outputBuffer[i] > maxValue) {
          maxValue = outputBuffer[i];
          maxIndex = i;
        }
      }
      final confidence = maxValue;

      // Map label index to disease name
      final diseaseName = _mapLabelToDiseaseName(_labels[maxIndex]);

      return {
        'disease': diseaseName,
        'confidence': confidence,
        'rawLabel': _labels[maxIndex],
      };
    } catch (e) {
      throw Exception('Prediction failed: $e');
    }
  }

  /// Preprocess image for model input
  Future<img.Image> _preprocessImage(String imagePath) async {
    final imageBytes = await File(imagePath).readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Get model input size (typically 224x224 or 256x256)
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final targetWidth = inputShape[2];
    final targetHeight = inputShape[1];

    // Resize image to model input size
    image = img.copyResize(
      image,
      width: targetWidth,
      height: targetHeight,
    );

    return image;
  }

  /// Map label to human-readable disease name
  String _mapLabelToDiseaseName(String label) {
    final labelMap = {
      'bacterial_leaf_blight': 'Bacterial Leaf Blight',
      'brown_spot': 'Brown Spot',
      'healthy': 'Healthy',
      'leaf_blast': 'Leaf Blast',
      'leaf_scald': 'Leaf Scald',
      'narrow_brown_spot': 'Narrow Brown Spot',
    };

    return labelMap[label] ?? label;
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

