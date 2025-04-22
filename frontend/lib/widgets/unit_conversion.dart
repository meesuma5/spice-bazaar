import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/widgets/custom_button.dart';

class UnitConverterDrawer extends StatefulWidget {
  const UnitConverterDrawer({super.key});

  @override
  State<UnitConverterDrawer> createState() => _UnitConverterDrawerState();
}

class _UnitConverterDrawerState extends State<UnitConverterDrawer> {
  // Categories of conversion
  final List<String> _categories = ['Volume', 'Weight', 'Temperature'];
  String _selectedCategory = 'Weight';

  // For storing the conversion factors loaded from JSON
  Map<String, dynamic> _conversionFactors = {};

  // Selected units and input value
  String? _fromUnit;
  String? _toUnit;
  final TextEditingController _inputController = TextEditingController();
  String _result = '';

  // Available units for current category
  List<String> _availableUnits = [];

  @override
  void initState() {
    super.initState();
    _loadConversionFactors();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // Load conversion factors from the JSON file
  Future<void> _loadConversionFactors() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/conversion_factors.json');
      setState(() {
        _conversionFactors = jsonDecode(jsonString);
        _updateUnitsForCategory();
      });
    } catch (e) {
      print('Error loading conversion factors: $e');
    }
  }

  void _updateUnitsForCategory() {
    if (_conversionFactors.isEmpty) return;

    final String categoryKey = _selectedCategory.toLowerCase();
    if (_conversionFactors.containsKey(categoryKey)) {
      final Map<String, dynamic> categoryFactors =
          _conversionFactors[categoryKey];
      _availableUnits = categoryFactors.keys.toList().cast<String>();

      // Set default units
      _fromUnit = _availableUnits.isNotEmpty ? _availableUnits[0] : null;
      _toUnit = _availableUnits.length > 1
          ? _availableUnits[1]
          : _availableUnits.isNotEmpty
              ? _availableUnits[0]
              : null;

      // Reset input and result
      _inputController.clear();
      _result = '';
    }
  }

  void _performConversion() {
    if (_fromUnit == null || _toUnit == null || _inputController.text.isEmpty) {
      setState(() {
        _result = '';
      });
      return;
    }

    try {
      final double inputValue = double.parse(_inputController.text);
      final String categoryKey = _selectedCategory.toLowerCase();
      final conversionFactor =
          _conversionFactors[categoryKey][_fromUnit][_toUnit];

      if (conversionFactor != null) {
        final double resultValue = inputValue * conversionFactor;
        setState(() {
          // Format to 2 decimal places if needed
          _result = resultValue % 1 == 0
              ? resultValue.toInt().toString()
              : resultValue.toStringAsFixed(2);
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  void _swapUnits() {
    setState(() {
      final String? temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;

      if (_inputController.text.isNotEmpty) {
        _performConversion();
      }
    });
  }

  String _formatUnitName(String unit) {
    // Format unit names for display (e.g., fluid_ounce -> Fluid Ounce)
    return unit
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unit Converter',
                    style: poppins(
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Convert between different units of measurement for your recipes.',
                style: poppins(
                    style: const TextStyle(color: Colors.black, fontSize: 14)),
              ),
              const SizedBox(height: 16),

              // Category Selector
              Text(
                'Category',
                style: poppins(
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: lighterPurple),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category,
                            style: poppins(
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12))),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != _selectedCategory) {
                        setState(() {
                          _selectedCategory = newValue;
                          _updateUnitsForCategory();
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // From Section
              Text(
                'From',
                style: poppins(
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: poppins(
                    style: const TextStyle(color: Colors.black, fontSize: 12)),
                decoration: InputDecoration(
                  hintText: 'Enter value',
                  hintStyle: poppins(
                      style:
                          const TextStyle(color: Colors.black, fontSize: 12)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (_) => _performConversion(),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderGray),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _fromUnit,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _availableUnits.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(_formatUnitName(unit),
                            style: poppins(
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12))),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _fromUnit = newValue;
                          _performConversion();
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Swap Button
              Center(
                child: IconButton(
                  icon: const Icon(Icons.swap_vert),
                  onPressed: _swapUnits,
                  style: IconButton.styleFrom(
                    backgroundColor: borderGray,
                    shape: const CircleBorder(),
                  ),
                ),
              ),

              // To Section
              Text(
                'To',
                style: poppins(
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderGray),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _toUnit,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _availableUnits.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(_formatUnitName(unit),
                            style: poppins(
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12))),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _toUnit = newValue;
                          _performConversion();
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),
              TextField(
                style: poppins(
                    style: const TextStyle(color: Colors.black, fontSize: 14)),
                readOnly: true,
                controller: TextEditingController(text: _result),
                decoration: InputDecoration(
                  hintText: 'Result',
                  filled: true,
                  fillColor: Colors.purple.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: mainPurple, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: mainPurple, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: mainPurple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Convert Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _performConversion,
                  text: 'Convert',
                  textStyle: poppins(
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  color: mainPurple,
                  isOutlined: false,
                  icon: const Icon(Icons.swap_horiz, color: Colors.white),
                  vPad: 16,
                ),
                // ElevatedButton(
                //   onPressed: _performConversion,
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.purple.shade300,
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(vertical: 16),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //   ),
                //   child: const Text('Convert'),
                // ),
              ),
              const SizedBox(height: 24),

              // Common Equivalents
              Text(
                'Common equivalents',
                style: poppins(
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              ..._buildCommonEquivalents(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCommonEquivalents() {
    // Static common equivalents as shown in the design
    if (_selectedCategory == 'Weight') {
      return [
        _buildEquivalentItem('1 kg = 1000 g'),
        _buildEquivalentItem('1 lb = 16 oz'),
        _buildEquivalentItem('1 lb = 453.6 g'),
      ];
    } else if (_selectedCategory == 'Volume') {
      return [
        _buildEquivalentItem('1 cup = 16 tbsp'),
        _buildEquivalentItem('1 tbsp = 3 tsp'),
        _buildEquivalentItem('1 cup = 240 ml'),
      ];
    }
    return [];
  }

  Widget _buildEquivalentItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: mainPurple),
          const SizedBox(width: 8),
          Text(
            text,
            style: poppins(
                style: const TextStyle(color: Colors.black87, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// To use this drawer in your app:
void showUnitConverterDrawer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return const UnitConverterDrawer();
    },
  );
}

// Add this to your pubspec.yaml:
// assets:
//   - assets/conversion_factors.json