import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ActivityPieChartScreen extends StatefulWidget {
  @override
  _ActivityPieChartScreenState createState() => _ActivityPieChartScreenState();
}

class _ActivityPieChartScreenState extends State<ActivityPieChartScreen> {
  Map<String, int> activityData = {};
  int totalActivities = 0;
  String touchedSection = '';

  @override
  void initState() {
    super.initState();
    _fetchActivityData();
  }

  Future<void> _fetchActivityData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('activity_logs')
          .where('role', isEqualTo: 'alumno') // Solo actividades de alumnos
          .get();

      final Map<String, int> data = {};
      for (var doc in snapshot.docs) {
        String userName = doc['userName'] ?? 'Usuario desconocido';
        data[userName] = (data[userName] ?? 0) + 1;
      }

      int total = data.values.fold(0, (prev, val) => prev + val);

      setState(() {
        activityData = data;
        totalActivities = total;
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
        title: Text('Actividad de Alumnos (Gráfico Circular)'),
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
                'Proporción de Actividades por Estudiante',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Este gráfico muestra cuántas actividades realizó cada estudiante.',
                style: TextStyle(fontSize: 14, color: Colors.blue.shade800),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(),
                    centerSpaceRadius: 60,
                    sectionsSpace: 4,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (response != null &&
                            response.touchedSection != null) {
                          final index =
                              response.touchedSection!.touchedSectionIndex;
                          final key =
                          activityData.keys.toList()[index];
                          setState(() {
                            touchedSection = key;
                          });
                        } else {
                          setState(() {
                            touchedSection = '';
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                touchedSection.isNotEmpty
                    ? 'Seleccionaste: $touchedSection'
                    : 'Toca una sección para más detalles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildLegend(),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.yellow.shade700,
      Colors.cyan,
      Colors.pink,
    ];

    final sortedEntries = activityData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final screenName = entry.value.key;
      final count = entry.value.value;
      final total = totalActivities == 0 ? 1 : totalActivities; // Evitar división por cero
      final percentage = (count / total) * 100;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: count.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final sortedEntries = activityData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.yellow.shade700,
      Colors.cyan,
      Colors.pink,
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: sortedEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final screenName = entry.value.key;
        final count = entry.value.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '$screenName ($count)',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        );
      }).toList(),
    );
  }
}
