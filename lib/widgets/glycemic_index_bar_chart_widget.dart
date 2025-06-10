// lib/widgets/glycemic_index_bar_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GlycemicIndexBarChartWidget extends StatelessWidget {
  final Map<String, Map<String, double>> dailyData;
  final Color barColor; // Rendi il colore configurabile

  const GlycemicIndexBarChartWidget({
    Key? key,
    required this.dailyData,
    this.barColor = Colors.purple, // Valore predefinito
  }) : super(key: key);

  static const double _barWidth = 16;
  static const double _leftTitlesReservedSize = 40;
  static const double _bottomTitlesReservedSize = 30;
  static const int _dateAxisStepSmall = 2; // Mostra 1 ogni 2 giorni se <= 15 giorni
  static const int _dateAxisStepLarge = 3; // Mostra 1 ogni 3 giorni se > 15 giorni

  List<BarChartGroupData> _buildBarGroups() {
    List<BarChartGroupData> barGroups = [];
    List<String> sortedDates = dailyData.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length; i++) {
      String date = sortedDates[i];
      final glycemicIndex = dailyData[date]?['glycemicIndex'] ?? 0.0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: glycemicIndex,
              color: barColor,
              width: _barWidth,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    return barGroups;
  }

  FlTitlesData get _titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: _bottomTitlesReservedSize,
        getTitlesWidget: (value, meta) {
          final dateKeys = dailyData.keys.toList()..sort();
          final totalDays = dateKeys.length;

          if (value.toInt() < 0 || value.toInt() >= totalDays) return const Text('');

          if (totalDays <= 7) {
            final date = DateTime.parse(dateKeys[value.toInt()]);
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 4,
              child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10)),
            );
          }

          int step = totalDays <= 15 ? _dateAxisStepSmall : _dateAxisStepLarge;
          if (value.toInt() % step != 0) return const Text('');

          final date = DateTime.parse(dateKeys[value.toInt()]);
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 4,
            child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10)),
          );
        },
      ),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: true, reservedSize: _leftTitlesReservedSize),
    ),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );

  @override
  Widget build(BuildContext context) {
    // Calcola maxY basandosi solo sull'indice glicemico
    final maxY = dailyData.values
        .map((e) => e['glycemicIndex'] ?? 0.0)
        .fold<double>(0.0, (a, b) => a > b ? a : b)
        .clamp(1.0, double.infinity) *
        1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barGroups: _buildBarGroups(),
        titlesData: _titlesData,
        borderData: FlBorderData(
          show: true,
          // Puoi riattivare il bordo se necessario
          // border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dateKeys = dailyData.keys.toList()..sort();
              if (group.x.toInt() < 0 || group.x.toInt() >= dateKeys.length) {
                return null; // Gestisci il caso in cui l'indice sia fuori dai limiti
              }
              final dateString = dateKeys[group.x.toInt()];
              final date = DateTime.parse(dateString);
              final glycemicIndex = dailyData[dateString]?['glycemicIndex'] ?? 0.0;
              return BarTooltipItem(
                '${DateFormat('dd/MM').format(date)}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'IG: ${glycemicIndex.toStringAsFixed(0)}',
                    style: TextStyle(color: barColor.withBlue(900)), // Usa il colore configurabile
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}