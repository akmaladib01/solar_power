import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(
    home: AnalyticPage(),
  ));
}

class AnalyticPage extends StatefulWidget {
  @override
  _AnalyticPageState createState() => _AnalyticPageState();
}

class _AnalyticPageState extends State<AnalyticPage> {
  String voltage = 'Loading...';
  String current = 'Loading...';
  String power = 'Loading...';

  Timer? _timer;
  String? _highlighted;
  List<_ChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.133/solarpower/gettingdata.php'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          voltage = '${data['voltage']} V';
          current = '${data['current']} A';
          power = '${data['power']} W';

          // Update chart data
          chartData.add(_ChartData(
            DateTime.now(),
            double.tryParse(data['voltage']) ?? 0,
            double.tryParse(data['current']) ?? 0,
            double.tryParse(data['power']) ?? 0,
          ));
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _highlight(String type) {
    setState(() {
      _highlighted = _highlighted == type ? null : type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Readings Display'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ReadingCard(
              title: 'Voltage',
              value: voltage,
              color: Colors.blue,
              onTap: () => _highlight('Voltage'),
            ),
            SizedBox(height: 16),
            ReadingCard(
              title: 'Current',
              value: current,
              color: Colors.green,
              onTap: () => _highlight('Current'),
            ),
            SizedBox(height: 16),
            ReadingCard(
              title: 'Power',
              value: power,
              color: Colors.red,
              onTap: () => _highlight('Power'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.Hm(),
                ),
                series: <CartesianSeries>[
                  LineSeries<_ChartData, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.time,
                    yValueMapper: (_ChartData data, _) => data.voltage,
                    color: _highlighted == 'Voltage' ? Colors.blue : Colors.blue.withOpacity(0.2),
                    name: 'Voltage',
                  ),
                  LineSeries<_ChartData, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.time,
                    yValueMapper: (_ChartData data, _) => data.current,
                    color: _highlighted == 'Current' ? Colors.green : Colors.green.withOpacity(0.2),
                    name: 'Current',
                  ),
                  LineSeries<_ChartData, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.time,
                    yValueMapper: (_ChartData data, _) => data.power,
                    color: _highlighted == 'Power' ? Colors.red : Colors.red.withOpacity(0.2),
                    name: 'Power',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  ReadingCard({
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.electrical_services,
                size: 40,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.time, this.voltage, this.current, this.power);

  final DateTime time;
  final double voltage;
  final double current;
  final double power;
}
