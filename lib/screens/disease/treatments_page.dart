import 'package:flutter/material.dart';

class TreatmentsPage extends StatelessWidget {
  final String diseaseName;
  const TreatmentsPage({super.key, required this.diseaseName});

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF36883B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with back
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Treatments',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildContent(primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color primary) {
    // Get treatment data based on disease name
    final treatmentData = _getTreatmentData(diseaseName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Disease Name
        Text(
          diseaseName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Disease Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/welcome_paddy_img.png',
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),

        // Prevention Heading
        Center(
          child: Text(
            'How can be prevent?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: primary,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Description paragraph
        if (treatmentData['description'] != null)
          Text(
            treatmentData['description'] as String,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        if (treatmentData['description'] != null) const SizedBox(height: 12),

        // Prevention strategies (bullet points)
        ...treatmentData['preventions']!.map(
          (prevention) => _bullet(prevention),
        ),

        const SizedBox(height: 24),

        // See more button
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'See more',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getTreatmentData(String diseaseName) {
    final normalizedName = diseaseName.toLowerCase();

    if (normalizedName.contains('bacterial leaf blight')) {
      return {
        'description':
            'Preventing bacterial leaf blight is always more cost-effective than treatment. '
            'This disease can cause significant yield losses if not managed properly. '
            'However, the following strategies can be useful as preventative measures:',
        'preventions': [
          'Use disease-free or resistant varieties.',
          'Avoid excess nitrogen fertilizer.',
          'Remove infected plants and improve drainage.',
          'Treat seeds before planting.',
          'Apply bactericide if severe.',
        ],
      };
    } else if (normalizedName.contains('brown spot')) {
      return {
        'description':
            'Preventing brown spot disease is always more cost-effective than treatment. '
            'This fungal disease can spread quickly under favorable conditions. '
            'However, the following strategies can be useful as preventative measures:',
        'preventions': [
          'Use clean, treated seeds.',
          'Maintain balanced soil nutrients (especially K and Si).',
          'Avoid dense planting and excess nitrogen.',
          'Remove infected residues.',
          'Apply fungicide if infection spreads.',
        ],
      };
    } else if (normalizedName.contains('healthy')) {
      return {
        'description':
            'Your paddy crop appears to be healthy! Continue maintaining good agricultural practices '
            'to prevent diseases and ensure optimal growth.',
        'preventions': [
          'Continue using certified seeds.',
          'Maintain balanced fertilizer application.',
          'Practice proper water control.',
          'Regular monitoring and field inspection.',
        ],
      };
    } else if (normalizedName.contains('leaf blast')) {
      return {
        'description':
            'Preventing leaf blast is always more cost-effective than treatment. '
            'This fungal disease can cause severe damage to rice crops. '
            'However, the following strategies can be useful as preventative measures:',
        'preventions': [
          'Plant resistant varieties and avoid late planting.',
          'Split nitrogen applications to prevent excess.',
          'Remove infected stubble.',
          'Spray fungicide at early stages if disease appears.',
        ],
      };
    } else if (normalizedName.contains('leaf scald')) {
      return {
        'description':
            'Preventing leaf scald is always more cost-effective than treatment. '
            'This bacterial disease can reduce grain quality and yield. '
            'However, the following strategies can be useful as preventative measures:',
        'preventions': [
          'Use treated seeds.',
          'Avoid high nitrogen use.',
          'Remove infected debris.',
          'Apply fungicide when symptoms appear.',
          'Use resistant varieties if available.',
        ],
      };
    } else if (normalizedName.contains('narrow brown spot')) {
      return {
        'description':
            'Preventing narrow brown spot is always more cost-effective than treatment. '
            'This disease can affect both leaves and grains. '
            'However, the following strategies can be useful as preventative measures:',
        'preventions': [
          'Keep fields clean and remove weeds.',
          'Use resistant varieties.',
          'Maintain balanced nutrients.',
          'Apply fungicide during boot to heading stages if needed.',
        ],
      };
    }

    // Default fallback
    return {
      'description':
          'Treatment recommendations will be available soon for this disease.',
      'preventions': [
        'Please consult with agricultural experts for specific treatment options.',
      ],
    };
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
