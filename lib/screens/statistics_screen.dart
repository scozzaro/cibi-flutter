// lib/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // Importato qui, non più nei widget separati
import '../database/database_helper.dart';
import 'dart:math' as math; // Import per la funzione math.max

class StatisticsScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const StatisticsScreen({super.key, required this.dbHelper});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, Map<String, double>> _dailyData = {};
  bool _isLoading = true;
  int _selectedDays = 7;
  final double _dailyCalorieTarget = 1900.0;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() => _isLoading = true);

    Map<String, Map<String, double>> data = {};
    DateTime now = DateTime.now();

    for (int i = _selectedDays - 1; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      String formattedDate = DateFormat('yyyy-MM-dd').format(day);
      data[formattedDate] = {'food': 0.0, 'sport': 0.0, 'glycemicIndex': 0.0};
    }

    DateTime startDate = now.subtract(Duration(days: _selectedDays - 1));
    final entries = await widget.dbHelper.getDetailedDiaryEntries(startDate: startDate, endDate: now);

    for (var entry in entries) {
      final String entryDate = entry['date'];
      if (data.containsKey(entryDate)) {
        if (entry['type'] == 'food') {
          final caloriesPerUnit = (entry['caloriesPerUnit'] as num?)?.toDouble() ?? 0.0;
          data[entryDate]!['food'] = data[entryDate]!['food']! + ((entry['quantity'] ?? 0.0) * caloriesPerUnit);

          final glycemicIndex = (entry['glycemicIndex'] as num?)?.toDouble() ?? 0.0;
          data[entryDate]!['glycemicIndex'] = data[entryDate]!['glycemicIndex']! + ((entry['quantity'] ?? 0.0) / 100) * glycemicIndex;
        } else if (entry['type'] == 'sport') {
          final caloriesBurnedPerMinute = (entry['caloriesBurnedPerMinute'] as num?)?.toDouble() ?? 0.0;
          data[entryDate]!['sport'] = data[entryDate]!['sport']! + ((entry['quantity'] ?? 0.0) * caloriesBurnedPerMinute);
        }
      }
    }

    setState(() {
      _dailyData = data;
      _isLoading = false;
    });
  }

  void _updateDays(int days) {
    setState(() {
      _selectedDays = days;
    });
    _loadChartData();
  }

  List<BarChartGroupData> _buildCaloriesChartBarGroups() {
    List<BarChartGroupData> barGroups = [];
    List<String> sortedDates = _dailyData.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length; i++) {
      String date = sortedDates[i];
      final food = _dailyData[date]?['food'] ?? 0.0;
      final sport = _dailyData[date]?['sport'] ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: food,
              color: Colors.blueAccent,
              width: 8,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
            BarChartRodData(
              toY: sport,
              color: Colors.orange,
              width: 8,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ],
          showingTooltipIndicators: [0, 1],
        ),
      );
    }
    return barGroups;
  }

  List<BarChartGroupData> _buildGlycemicIndexChartBarGroups() {
    List<BarChartGroupData> barGroups = [];
    List<String> sortedDates = _dailyData.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length; i++) {
      String date = sortedDates[i];
      final glycemicIndex = _dailyData[date]?['glycemicIndex'] ?? 0.0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: glycemicIndex,
              color: Colors.purple,
              width: 16,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    return barGroups;
  }

  FlTitlesData _getCaloriesChartTitlesData(Map<String, Map<String, double>> dailyData) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final dateKeys = dailyData.keys.toList()..sort();
            final totalDays = dateKeys.length;
            if (value.toInt() < 0 || value.toInt() >= totalDays) return const Text('');
            int step = totalDays <= 7 ? 1 : (totalDays <= 15 ? 2 : 3);
            if (value.toInt() % step != 0) return const Text('');
            final date = DateTime.parse(dateKeys[value.toInt()]);
            return Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10));
          },
        ),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlTitlesData _getGlycemicIndexChartTitlesData(Map<String, Map<String, double>> dailyData) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final dateKeys = dailyData.keys.toList()..sort();
            final totalDays = dateKeys.length;
            if (value.toInt() < 0 || value.toInt() >= totalDays) return const Text('');
            int step = totalDays <= 7 ? 1 : (totalDays <= 15 ? 2 : 3);
            if (value.toInt() % step != 0) return const Text('');
            final date = DateTime.parse(dateKeys[value.toInt()]);
            return Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10));
          },
        ),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildDayButton(int days) {
    final bool isSelected = days == _selectedDays;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        onPressed: () => _updateDays(days),
        child: Text('$days giorni'),
      ),
    );
  }

  Widget _buildCaloriesLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Calorie Consumate', style: TextStyle(color: Colors.blueAccent)),
        const SizedBox(width: 20),
        Text('Calorie Bruciate', style: TextStyle(color: Colors.orange)),
      ],
    );
  }

  Widget _buildGlycemicIndexLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Indice Glicemico', style: TextStyle(color: Colors.purple)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final barGroups = _buildCaloriesChartBarGroups();
    final glycemicGroups = _buildGlycemicIndexChartBarGroups();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [7, 14, 30].map(_buildDayButton).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Calorie Consumate vs Bruciate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: _getCaloriesChartTitlesData(_dailyData),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      //tooltipBgColor: Colors.transparent, // Sfondo trasparente
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 10,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (rod.toY < 10) return null; // Nasconde il tooltip se il valore è sotto 10
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(1)} cal',
                          TextStyle(
                            color: rod.color,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildCaloriesLegend(),
            const SizedBox(height: 32),
            const Text('Indice Glicemico Totale', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  barGroups: glycemicGroups,
                  titlesData: _getGlycemicIndexChartTitlesData(_dailyData),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      //tooltipBgColor: Colors.transparent, // Sfondo trasparente
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 10,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (rod.toY < 10) return null; // Nasconde il tooltip se il valore è sotto 10
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(1)} IG',
                          const TextStyle(
                            color: Colors.lightGreenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildGlycemicIndexLegend(),
          ],
        ),
      ),
    );
  }
}
