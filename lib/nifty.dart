import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NiftyChart extends StatefulWidget {
  const NiftyChart({super.key});

  @override
  State<NiftyChart> createState() => _NiftyChartState();
}

class _NiftyChartState extends State<NiftyChart> {
  List<FlSpot> chartData = [];
  bool isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    fetchNiftyData();
  }

  Future<void> fetchNiftyData() async {
    // The ticker for Nifty 50 on Yahoo Finance is ^NSEI.
    // %5E is the URL-encoded version of '^'.
    const symbol = '%5ENSEI';
    final url = Uri.parse(
      'https://query2.finance.yahoo.com/v8/finance/chart/$symbol?interval=5m',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load data. Status Code: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      final chartData = data['chart'];
      if (chartData == null || chartData['error'] != null) {
        throw Exception(
          chartData?['error']?['description'] ?? 'Unknown API error',
        );
      }

      final result = chartData['result'];
      if (result == null || result.isEmpty) {
        throw Exception('No data returned for symbol');
      }

      final indicators = result[0]['indicators']['quote'][0];
      final List<dynamic>? prices = indicators['close'];

      if (prices == null) {
        throw Exception('Price data is missing in the API response.');
      }

      final List<FlSpot> points = prices
          .where((price) => price != null)
          .toList()
          .asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
          .toList();

      setState(() {
        this.chartData = points;
        isLoading = false;
        _error = '';
      });
    } catch (e) {
      setState(() {
        _error =
            "Failed to get data: ${e.toString().replaceFirst("Exception: ", "")}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nifty 50 Tracker')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Text(_error, style: const TextStyle(color: Colors.red)),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      color: Colors.blue,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
