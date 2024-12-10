import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ActivityChartScreen extends StatefulWidget {
  @override
  _ActivityChartScreenState createState() => _ActivityChartScreenState();
}

class _ActivityChartScreenState extends State<ActivityChartScreen> {
  Map<String, int> activityData = {};
  double maxYValue = 0;

  @override
  void initState() {
    super.initState();
    _fetchActivityData();
  }

  Future<void> _fetchActivityData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('activity_logs').get();
      final Map<String, int> data = {};

      for (var doc in snapshot.docs) {
        String screenName = doc['screenName'];
        data[screenName] = (data[screenName] ?? 0) + 1;
      }

      // Calcula el valor máximo para el eje Y
      double maxVal = 0;
      data.forEach((key, value) {
        if (value > maxVal) maxVal = value.toDouble();
      });

      setState(() {
        activityData = data;
        maxYValue = maxVal + (maxVal * 0.2); // Añade un 20% para dar espacio visual arriba
      });
    } catch (e) {
      print('Error fetching activity data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundStart = Colors.lightBlue.shade100;
    Color backgroundEnd = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text('Actividad de Alumnos'),
        backgroundColor: Colors.blueAccent,
        elevation: 10,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundStart, backgroundEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: activityData.isEmpty
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Frecuencia de Visitas por Pantalla',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Este gráfico muestra cuántas veces los alumnos han ingresado a cada pantalla.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: maxYValue > 0 ? maxYValue : 10,
                    barGroups: _buildBarGroups(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final keys = activityData.keys.toList();
                            if (value.toInt() >= 0 && value.toInt() < keys.length) {
                              return Transform.translate(
                                offset: Offset(-10, 5),
                                child: Transform.rotate(
                                  angle: -0.5, // Rotar el texto (-0.5 radianes ~ -30 grados)
                                  child: Text(
                                    keys[value.toInt()],
                                    style: TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                ),
                              );
                            }
                            return Text('');
                          },
                          reservedSize: 50,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 10, color: Colors.black87),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Color(0xFF004E89)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: (maxYValue / 5).ceilToDouble(),
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipMargin: 8,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipBorder: BorderSide(color: Colors.grey),
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String screenName = activityData.keys.toList()[group.x.toInt()];
                          return BarTooltipItem(
                            '$screenName\n',
                            TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '${rod.toY.toInt()} visitas',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  swapAnimationDuration: Duration(milliseconds: 600),
                  swapAnimationCurve: Curves.easeOutCubic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final sortedEntries = activityData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Ordena por valor desc, opcional

    return sortedEntries.asMap().entries.map((entry) {
      int index = entry.key;
      String screenName = entry.value.key;
      int value = entry.value.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            width: 20,
            color: Color(0xFF00E29E),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
}
