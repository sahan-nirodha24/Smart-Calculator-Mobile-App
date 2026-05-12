import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  String fromCurrency = "USD";
  String toCurrency = "LKR";
  String inputString = "1";
  Map<String, dynamic> rates = {
    "USD": 1.0,
    "LKR": 300.0,
    "EUR": 0.92,
    "GBP": 0.79,
    "JPY": 150.0,
    "AUD": 1.52,
    "CAD": 1.35,
    "INR": 83.0,
    "CNY": 7.2,
    "AED": 3.67
  };
  bool isLoading = false;
  DateTime? lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadCachedRates();
    _fetchRates();
  }

  Future<void> _loadCachedRates() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('currency_rates');
    final cachedTime = prefs.getInt('rates_timestamp');
    
    if (cachedData != null && cachedTime != null) {
      setState(() {
        rates = json.decode(cachedData);
        lastUpdated = DateTime.fromMillisecondsSinceEpoch(cachedTime);
      });
    }
  }

  Future<void> _fetchRates() async {
    setState(() => isLoading = true);
    try {
      // Using a free open API (no key required for basic rates)
      final response = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newRates = data['rates'] as Map<String, dynamic>;
        
        setState(() {
          rates = newRates;
          lastUpdated = DateTime.now();
          isLoading = false;
        });

        // Cache the results
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_rates', json.encode(newRates));
        await prefs.setInt('rates_timestamp', DateTime.now().millisecondsSinceEpoch);
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update rates. Using cached data.")),
        );
      }
    }
  }

  double get amount => double.tryParse(inputString) ?? 0;

  double get convertedAmount {
    if (!rates.containsKey(fromCurrency) || !rates.containsKey(toCurrency)) return 0;
    double usdAmount = amount / rates[fromCurrency]!;
    return usdAmount * rates[toCurrency]!;
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
          _buildHeader(),
          const SizedBox(height: 24),
          _buildCurrencySection(fromCurrency, inputString, true),
          const SizedBox(height: 16),
          _buildCurrencySection(toCurrency, convertedAmount.toStringAsFixed(2), false),
          const Spacer(),
          _buildKeypad(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lastUpdated != null)
              Text(
                "Last updated: ${lastUpdated!.toString().split('.')[0]}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            if (isLoading)
              const SizedBox(
                width: 100,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          onPressed: _fetchRates,
          tooltip: "Update rates",
        ),
      ],
    );
  }

  Widget _buildCurrencySection(String currency, String value, bool isInput) {
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
        InkWell(
          onTap: () => _showCurrencyPicker(isInput),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currency,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCurrencyPicker(bool isFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          final sortedCurrencies = rates.keys.toList()..sort();
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Select Currency", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: sortedCurrencies.length,
                  itemBuilder: (context, index) {
                    final code = sortedCurrencies[index];
                    return ListTile(
                      title: Text(code),
                      onTap: () {
                        setState(() {
                          if (isFrom) fromCurrency = code; else toCurrency = code;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
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
                  String temp = fromCurrency;
                  fromCurrency = toCurrency;
                  toCurrency = temp;
                });
              },
              child: const Row(
                children: [
                  Icon(Icons.swap_vert, size: 16),
                  SizedBox(width: 4),
                  Text("Swap Currencies"),
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
