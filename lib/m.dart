import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(StockTrackerApp());
}

class StockTrackerApp extends StatelessWidget {
  const StockTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StockHomePage(),
    );
  }
}

class StockHomePage extends StatefulWidget {
  const StockHomePage({super.key});
  @override
  StockHomePageState createState() => StockHomePageState();
}

class StockHomePageState extends State<StockHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<FlSpot> _graphPoints = [];
  bool _isLoading = false;
  String _error = '';
  String _symbol = '';

  Future<void> fetchStockData(String symbol) async {
    setState(() {
      _isLoading = true;
      _error = '';
      _graphPoints = [];
    });

    final apiKey = 'YOUR_API_KEY'; // Replace with your Alpha Vantage API key
    final url = Uri.parse(
      'https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=$symbol&interval=5min&apikey=$apiKey',
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data.containsKey('Note') || data.containsKey('Error Message')) {
        setState(() {
          _error = 'Error: ${data['Note'] ?? data['Error Message']}';
          _isLoading = false;
        });
        return;
      }

      final timeSeries = data['Time Series (5min)'] as Map<String, dynamic>;
      final entries = timeSeries.entries.toList().take(30).toList().reversed;

      List<FlSpot> points = [];
      int index = 0;

      for (var entry in entries) {
        final close = double.tryParse(entry.value['4. close']) ?? 0;
        points.add(FlSpot(index.toDouble(), close));
        index++;
      }

      setState(() {
        _symbol = symbol;
        _graphPoints = points;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch data.';
        _isLoading = false;
      });
    }
  }

  Widget buildChart() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _graphPoints,
            isCurved: true,
            color: Colors.blue, // ✅ correct
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Tracker'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Drawer Header',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account'),
              onTap: () {
                Navigator.pop(context);
                // Add navigation to account settings or profile page
              },
            ),
            // Add other sections as needed, e.g., settings, help, etc.
            // ListTile(leading: Icon(Icons.settings), title: Text('Settings'), onTap: () { ... }),
            // ListTile(leading: Icon(Icons.help), title: Text('Help'), onTap: () { ... }),
            // ...
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Stock Symbol (e.g. AAPL)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () =>
                  fetchStockData(_controller.text.trim().toUpperCase()),
              child: Text('Get Data'),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red))
            else if (_graphPoints.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    Text('$_symbol - Recent Prices'),
                    SizedBox(height: 300, child: buildChart()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
