// lib/widgets/calories_stacked_bar_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Questo widget visualizza le calorie consumate e bruciate come barre impilate.
class CaloriesStackedBarChartWidget extends StatelessWidget {
  /// I dati giornalieri contenenti 'consumedCalories' e 'burnedCalories'.
  /// Esempio:
  /// {
  ///   '2023-01-01': {'consumedCalories': 2000, 'burnedCalories': 500},
  ///   '2023-01-02': {'consumedCalories': 2200, 'burnedCalories': 700},
  /// }
  final Map<String, Map<String, double>> dailyData;

  const CaloriesStackedBarChartWidget({Key? key, required this.dailyData}) : super(key: key);

  // Costanti per migliorare la leggibilità e la manutenibilità del codice
  static const double _barWidth = 16;
  static const double _leftTitlesReservedSize = 40;
  static const double _bottomTitlesReservedSize = 30;
  static const int _dateAxisStepSmall = 2; // Mostra 1 ogni 2 giorni se <= 15 giorni
  static const int _dateAxisStepLarge = 3; // Mostra 1 ogni 3 giorni se > 15 giorni

  /// Costruisce i gruppi di barre per il grafico.
  /// Ogni gruppo conterrà due BarRodData per le calorie consumate e bruciate.
  List<BarChartGroupData> _buildBarGroups() {
    List<BarChartGroupData> barGroups = [];
    List<String> sortedDates = dailyData.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length; i++) {
      String date = sortedDates[i];
      final consumedCalories = dailyData[date]?['consumedCalories'] ?? 0.0;
      final burnedCalories = dailyData[date]?['burnedCalories'] ?? 0.0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            // Barra per le calorie consumate
            BarChartRodData(
              toY: consumedCalories,
              color: Colors.green.shade400, // Colore per calorie consumate
              width: _barWidth,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
            // Barra per le calorie bruciate
            BarChartRodData(
              toY: burnedCalories,
              color: Colors.orange.shade400, // Colore per calorie bruciate
              width: _barWidth,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ],
          // Non mostriamo indicatori di tooltip individuali per ogni barra qui
          // Il tooltip gestirà entrambi i valori nel getTooltipItem
        ),
      );
    }
    return barGroups;
  }

  /// Configura i titoli degli assi (X e Y).
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

          // Mostra tutti se <= 7 giorni
          if (totalDays <= 7) {
            final date = DateTime.parse(dateKeys[value.toInt()]);
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 4,
              child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10)),
            );
          }

          // Mostra 1 ogni N giorni, adattivo
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
    // Calcola maxY basandosi sulla somma delle calorie consumate e bruciate
    final maxY = dailyData.values
        .map((e) => (e['consumedCalories'] ?? 0.0) + (e['burnedCalories'] ?? 0.0))
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
          border: Border.all(color: const Color(0xff37434d), width: 1),
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
              final dayData = dailyData[dateString] ?? {};
              final consumed = dayData['consumedCalories'] ?? 0.0;
              final burned = dayData['burnedCalories'] ?? 0.0;

              return BarTooltipItem(
                '${DateFormat('dd/MM').format(date)}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Consumate: ${consumed.toStringAsFixed(0)} kcal\n',
                    style: TextStyle(color: Colors.green.shade100),
                  ),
                  TextSpan(
                    text: 'Bruciate: ${burned.toStringAsFixed(0)} kcal',
                    style: TextStyle(color: Colors.orange.shade100),
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