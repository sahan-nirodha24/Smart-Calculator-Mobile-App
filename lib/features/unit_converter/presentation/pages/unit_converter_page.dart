import 'package:flutter/material.dart';

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  String selectedCategory = "Length";
  String inputString = "1";
  String fromUnit = "Meters";
  String toUnit = "Feet";

  final Map<String, Map<String, double>> conversionFactors = {
    "Length": {
      "Nanometers": 1e-9,
      "Micrometers": 1e-6,
      "Millimeters": 0.001,
      "Centimeters": 0.01,
      "Decimeters": 0.1,
      "Meters": 1.0,
      "Kilometers": 1000.0,
      "Inches": 0.0254,
      "Feet": 0.3048,
      "Yards": 0.9144,
      "Miles": 1609.344,
      "Nautical Miles": 1852.0,
    },
    "Weight/Mass": {
      "Micrograms": 1e-9,
      "Milligrams": 1e-6,
      "Grams": 0.001,
      "Kilograms": 1.0,
      "Metric Tons": 1000.0,
      "Ounces": 0.0283495,
      "Pounds": 0.453592,
      "Stones": 6.35029,
      "US Tons": 907.185,
      "Imperial Tons": 1016.05,
    },
    "Temperature": {
      "Celsius": 1.0,
      "Fahrenheit": 1.0, 
      "Kelvin": 1.0,
    },
    "Volume": {
      "Milliliters": 0.001,
      "Liters": 1.0,
      "Cubic Centimeters": 0.001,
      "Cubic Meters": 1000.0,
      "US Teaspoons": 0.00492892,
      "US Tablespoons": 0.0147868,
      "US Fluid Ounces": 0.0295735,
      "US Cups": 0.236588,
      "US Pints": 0.473176,
      "US Quarts": 0.946353,
      "US Gallons": 3.78541,
      "Imperial Teaspoons": 0.00591939,
      "Imperial Tablespoons": 0.0177582,
      "Imperial Fluid Ounces": 0.0284131,
      "Imperial Pints": 0.568261,
      "Imperial Gallons": 4.54609,
    },
    "Area": {
      "Square Millimeters": 1e-6,
      "Square Centimeters": 0.0001,
      "Square Meters": 1.0,
      "Hectares": 10000.0,
      "Square Kilometers": 1000000.0,
      "Square Inches": 0.00064516,
      "Square Feet": 0.092903,
      "Square Yards": 0.836127,
      "Acres": 4046.856,
      "Square Miles": 2589988.11,
    },
    "Speed": {
      "Meters/sec": 1.0,
      "Kilometers/hour": 0.277778,
      "Miles/hour": 0.44704,
      "Knots": 0.514444,
      "Mach": 340.3,
    },
    "Time": {
      "Milliseconds": 0.001,
      "Seconds": 1.0,
      "Minutes": 60.0,
      "Hours": 3600.0,
      "Days": 86400.0,
      "Weeks": 604800.0,
      "Months (Avg)": 2629800.0,
      "Years": 31557600.0,
    },
    "Energy": {
      "Joules": 1.0,
      "Kilojoules": 1000.0,
      "Calories": 4.184,
      "Kilocalories": 4184.0,
      "Watt-hours": 3600.0,
      "Kilowatt-hours": 3600000.0,
      "Electronvolts": 1.60218e-19,
      "BTUs": 1055.06,
      "Foot-pounds": 1.35582,
    },
    "Pressure": {
      "Pascals": 1.0,
      "Kilopascals": 1000.0,
      "Bars": 100000.0,
      "PSI": 6894.76,
      "Atmospheres": 101325.0,
      "Torr": 133.322,
    },
    "Data Storage": {
      "Bits": 0.125,
      "Bytes": 1.0,
      "Kilobytes": 1024.0,
      "Megabytes": 1048576.0,
      "Gigabytes": 1073741824.0,
      "Terabytes": 1099511627776.0,
      "Petabytes": 1125899906842624.0,
    }
  };

  double get inputValue => double.tryParse(inputString) ?? 0;

  double get result {
    if (selectedCategory == "Temperature") {
      return _convertTemperature(inputValue, fromUnit, toUnit);
    }
    // Convert from 'fromUnit' to base (value in map is ratio to base)
    double valueInBase = inputValue * conversionFactors[selectedCategory]![fromUnit]!;
    // Convert from base to 'toUnit'
    return valueInBase / conversionFactors[selectedCategory]![toUnit]!;
  }

  double _convertTemperature(double val, String from, String to) {
    double celsius;
    if (from == "Celsius") celsius = val;
    else if (from == "Fahrenheit") celsius = (val - 32) * 5 / 9;
    else celsius = val - 273.15;

    if (to == "Celsius") return celsius;
    else if (to == "Fahrenheit") return (celsius * 9 / 5) + 32;
    else return celsius + 273.15;
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == "⌫") {
        if (inputString.length > 1) {
          inputString = inputString.substring(0, inputString.length - 1);
        } else {
          inputString = "0";
        }
      } else if (key == "C") {
        inputString = "0";
      } else if (key == ".") {
        if (!inputString.contains(".")) inputString += ".";
      } else {
        if (inputString == "0") inputString = key;
        else inputString += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySelector(),
          const SizedBox(height: 32),
          _buildUnitSection(fromUnit, inputString, true),
          const SizedBox(height: 24),
          _buildUnitSection(toUnit, _formatResult(result), false),
          const Spacer(),
          _buildKeypad(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatResult(double val) {
    if (val == 0) return "0";
    if (val.abs() < 0.000001 || val.abs() > 1000000000) {
      return val.toStringAsExponential(4);
    }
    String s = val.toStringAsFixed(8);
    while (s.contains('.') && (s.endsWith('0') || s.endsWith('.'))) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          items: conversionFactors.keys.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
          onChanged: (val) => setState(() {
            selectedCategory = val!;
            fromUnit = conversionFactors[selectedCategory]!.keys.first;
            toUnit = conversionFactors[selectedCategory]!.keys.elementAt(1);
          }),
        ),
      ),
    );
  }

  Widget _buildUnitSection(String unit, String value, bool isInput) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isInput ? null : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: unit,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            items: conversionFactors[selectedCategory]!
                .keys
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (val) {
              setState(() {
                if (isInput) fromUnit = val!; else toUnit = val!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['.', '0', '⌫'],
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  String temp = fromUnit;
                  fromUnit = toUnit;
                  toUnit = temp;
                });
              },
              child: const Row(
                children: [
                  Icon(Icons.swap_vert, size: 16),
                  SizedBox(width: 4),
                  Text("Swap Units"),
                ],
              ),
            ),
            const Spacer(),
            TextButton(onPressed: () => _onKeyPress("C"), child: const Text("Clear")),
          ],
        ),
        ...keys.map((row) => Row(
          children: row.map((key) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: AspectRatio(
                aspectRatio: 2.5,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    onTap: () => _onKeyPress(key),
                    borderRadius: BorderRadius.circular(4),
                    child: Center(
                      child: Text(key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ),
            ),
          )).toList(),
        )).toList(),
      ],
    );
  }
}
