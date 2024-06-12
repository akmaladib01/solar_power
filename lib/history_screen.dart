import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:syncfusion_flutter_charts/charts.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Map<String, dynamic>> data = [];
  Timer? _timer;
  String selectedFilter = 'day';

  @override
  void initState() {
    super.initState();
    fetchData(selectedFilter);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchData(selectedFilter);
    });
  }

  Future<void> fetchData(String filter) async {
    try {
      final response = await http.get(Uri.parse('http://10.131.73.249/solarpower/history.php?filter=$filter'));

      if (response.statusCode == 200) {
        setState(() {
          data = List<Map<String, dynamic>>.from(
            jsonDecode(response.body).map((item) {
              return {
                'voltage': double.parse(item['voltage']),
                'current': double.parse(item['current']),
                'power': double.parse(item['power']),
                'datetime': item['datetime']
              };
            }),
          );
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Data'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedFilter,
              items: [
                DropdownMenuItem(value: 'day', child: Text('Day')),
                DropdownMenuItem(value: 'week', child: Text('Week')),
                DropdownMenuItem(value: 'month', child: Text('Month')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
                fetchData(selectedFilter);
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Consumption Patterns',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: selectedFilter == 'day'
                        ? SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelIntersectAction: AxisLabelIntersectAction.rotate45,
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Power (W)'),
                      ),
                      series: <CartesianSeries>[
                        LineSeries<Map<String, dynamic>, String>(
                          dataSource: data,
                          xValueMapper: (datum, _) => datum['datetime'],
                          yValueMapper: (datum, _) => datum['power'],
                        ),
                      ],
                    )
                        : SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelIntersectAction: AxisLabelIntersectAction.rotate45,
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Power (W)'),
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<Map<String, dynamic>, String>(
                          dataSource: data,
                          xValueMapper: (datum, _) => datum['datetime'],
                          yValueMapper: (datum, _) => datum['power'],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ReadingCard(
                    title: 'Reading ${index + 1}',
                    voltage: '${data[index]['voltage']} V',
                    current: '${data[index]['current']} A',
                    power: '${data[index]['power']} W',
                    datetime: '${data[index]['datetime']}',
                  );
                },
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
  final String voltage;
  final String current;
  final String power;
  final String datetime;

  ReadingCard({
    required this.title,
    required this.voltage,
    required this.current,
    required this.power,
    required this.datetime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Voltage: $voltage',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Current: $current',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Power: $power',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Date: $datetime',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}