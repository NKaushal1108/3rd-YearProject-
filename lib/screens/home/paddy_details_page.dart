import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/paddy_field.dart';
import '../../models/harvest_data.dart';
import '../../utils/district_paddy_varieties.dart';

class PaddyDetailsPage extends StatefulWidget {
  final PaddyField paddyField;

  const PaddyDetailsPage({super.key, required this.paddyField});

  @override
  State<PaddyDetailsPage> createState() => _PaddyDetailsPageState();
}

class _PaddyDetailsPageState extends State<PaddyDetailsPage> {
  String? _selectedPaddyType;
  final TextEditingController _quantityController = TextEditingController();
  double? _predictedYield;

  // Dummy harvest data - replace with real data from backend later
  final List<HarvestDataPoint> _harvestData = [
    HarvestDataPoint(year: 2021, quantity: 950),
    HarvestDataPoint(year: 2022, quantity: 650),
    HarvestDataPoint(year: 2023, quantity: 600),
    HarvestDataPoint(year: 2024, quantity: 700),
  ];

  final Color primary = const Color(0xFF36883B);

  @override
  void initState() {
    super.initState();
    // Set default paddy type from district varieties
    final varieties = DistrictPaddyVarieties.getVarietiesFor(
      widget.paddyField.location,
    );
    if (varieties.isNotEmpty) {
      _selectedPaddyType = varieties[0];
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
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

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Paddy Field Name
                  Text(
                    widget.paddyField.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 1: Recommended Paddy Types
                  _buildSectionTitle('Recommended Paddy Types'),
                  const SizedBox(height: 12),
                  _buildRecommendedPaddyTypes(),

                  const SizedBox(height: 24),

                  // Section 2: Past Harvest Analysis
                  _buildSectionTitle('Past Harvest Analysis'),
                  const SizedBox(height: 12),
                  _buildPastHarvestChart(),

                  const SizedBox(height: 24),

                  // Section 3: Yield Prediction
                  _buildSectionTitle('Yield Prediction'),
                  const SizedBox(height: 12),
                  _buildYieldPredictionForm(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
    );
  }

  Widget _buildRecommendedPaddyTypes() {
    final List<String> varieties = DistrictPaddyVarieties.getVarietiesFor(
      widget.paddyField.location,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (varieties.isEmpty)
            const Text(
              'No recommendations available for this district.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            )
          else
            ...varieties.take(3).map((name) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPastHarvestChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 250,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade400, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'YEAR',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final year = value.toInt();
                  if (_harvestData.any((d) => d.year == year)) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        year.toString(),
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  'Quantity (Kg)',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(color: Colors.black87, fontSize: 12),
                  );
                },
                reservedSize: 50,
                interval: 250,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade400),
              left: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          minX: 2020.5,
          maxX: 2024.5,
          minY: 0,
          maxY: 1000,
          lineBarsData: [
            LineChartBarData(
              spots: _harvestData.map((point) {
                return FlSpot(point.year.toDouble(), point.quantity);
              }).toList(),
              isCurved: false,
              color: primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: primary.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYieldPredictionForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paddy Type Dropdown
          _buildFormLabel('Type of rice sown :'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Builder(
              builder: (context) {
                final varieties = _getDistrictVarieties();
                // Ensure selected value exists in the list, otherwise use first item or null
                String? validValue;
                if (varieties.isNotEmpty) {
                  if (varieties.contains(_selectedPaddyType)) {
                    validValue = _selectedPaddyType;
                  } else {
                    validValue = varieties[0];
                    // Update state to match valid value
                    Future.microtask(() {
                      if (mounted && _selectedPaddyType != validValue) {
                        setState(() {
                          _selectedPaddyType = validValue;
                        });
                      }
                    });
                  }
                }

                return DropdownButtonFormField<String>(
                  value: validValue,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: varieties.map((variety) {
                    return DropdownMenuItem(
                      value: variety,
                      child: Text(variety),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaddyType = value;
                      _predictedYield =
                          null; // Reset prediction when type changes
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Quantity Input
          _buildFormLabel('Amount of rice sown :'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: '1000',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Kg',
                style: TextStyle(
                  color: primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Yield Prediction Output
          _buildFormLabel('Yield Prediction :'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1E6D0), // Light green
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _predictedYield != null
                        ? _predictedYield!.toStringAsFixed(0)
                        : '--',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Kg',
                style: TextStyle(
                  color: primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Calculate Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _calculateYield,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Calculate',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  List<String> _getDistrictVarieties() {
    return DistrictPaddyVarieties.getVarietiesFor(widget.paddyField.location);
  }

  /// Get yield multiplier based on paddy variety (Sri Lanka standards)
  /// These multipliers ensure yield is always greater than amount sown
  double _getYieldMultiplier(String? variety) {
    if (variety == null) return 18.0; // Default multiplier

    // Yield multipliers based on Sri Lanka paddy yield standards
    // These represent typical yield ratios (kg yield per kg seed sown)
    // All multipliers ensure yield > amount sown
    final Map<String, double> multipliers = {
      'At 362': 20.0,
      'Bg 250': 22.0,
      'Bg 300': 21.0,
      'Bg 352': 19.0,
      'Bg 357': 18.5,
      'Bg 358': 20.5,
      'Bg 360': 21.5,
      'Bg 379-2': 19.5,
      'Bg 380': 20.0,
      'Bg 407': 18.0,
      'Bg 450': 22.5,
      'Bg 94-1': 21.0,
      'Hondarawalu': 17.5,
      'Kalu Heenati': 16.5,
      'Kuruwee': 18.0,
      'Ld 365': 20.0,
      'Maa-Wee': 17.0,
      'Madathawalu': 16.0,
      'Pachchaperumal': 19.0,
      'Ponni': 21.5,
      'Ptb 21': 20.5,
      'Rathel': 18.5,
      'Suwandhal': 19.5,
      'Suwandal': 19.5,
    };

    return multipliers[variety] ?? 18.0; // Default if variety not found
  }

  void _calculateYield() {
    if (_selectedPaddyType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a paddy variety'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculate yield based on Sri Lanka paddy yield standards
    // Formula: Yield = Amount sown × Multiplier
    // Multipliers are based on typical Sri Lanka paddy yield ratios
    final multiplier = _getYieldMultiplier(_selectedPaddyType);
    final calculatedYield = quantity * multiplier;

    // Ensure yield is always greater than amount sown
    final finalYield = calculatedYield > quantity
        ? calculatedYield
        : quantity * 1.5;

    setState(() {
      _predictedYield = finalYield;
    });
  }
}
