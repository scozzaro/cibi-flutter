// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../database/database_helper.dart';

class StatisticsScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const StatisticsScreen({super.key, required this.dbHelper});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Le chiavi sono state aggiornate per essere più descrittive
  Map<String, Map<String, double>> _dailyData = {};
  bool _isLoading = true;
  int _selectedDays = 7;

  // Costanti per migliorare la leggibilità e la manutenibilità del codice
  static const double _barWidth = 8; // Larghezza per le barre del grafico calorie
  static const double _singleBarWidth = 16; // Larghezza per la barra del grafico indice glicemico
  static const double _leftTitlesReservedSize = 40;
  static const double _bottomTitlesReservedSize = 30;
  static const int _dateAxisStepSmall = 2; // Mostra 1 ogni 2 giorni se <= 15 giorni
  static const int _dateAxisStepLarge = 3; // Mostra 1 ogni 3 giorni se > 15 giorni

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  /// Carica i dati delle calorie (consumate e bruciate) e del carico glicemico
  /// per il periodo selezionato.
  /// Aggiorna `_dailyData` e imposta `_isLoading` su false al termine.
  Future<void> _loadChartData() async {
    setState(() => _isLoading = true);

    Map<String, Map<String, double>> data = {};
    DateTime now = DateTime.now();

    // Inizializza i dati per ogni giorno nel range selezionato
    for (int i = _selectedDays - 1; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      String formattedDate = DateFormat('yyyy-MM-dd').format(day);
      // Inizializza con le nuove chiavi per chiarezza
      data[formattedDate] = {'consumedCalories': 0.0, 'burnedCalories': 0.0, 'glycemicLoad': 0.0};
    }

    // Ottieni le voci del diario dall'inizio del periodo selezionato fino ad oggi
    DateTime startDate = now.subtract(Duration(days: _selectedDays - 1));
    final entries = await widget.dbHelper.getDetailedDiaryEntries(startDate: startDate, endDate: now);

    // Calcola le calorie e il carico glicemico per ogni giorno
    for (var entry in entries) {
      final String entryDate = entry['date'];
      if (data.containsKey(entryDate)) {
        if (entry['type'] == 'food') {
          final caloriesPerUnit = (entry['caloriesPerUnit'] as num?)?.toDouble() ?? 0.0;
          // Aggiorna la chiave 'consumedCalories'
          data[entryDate]!['consumedCalories'] = data[entryDate]!['consumedCalories']! + ((entry['quantity'] ?? 0.0) * caloriesPerUnit);

          final glycemicIndex = (entry['glycemicIndex'] as num?)?.toDouble() ?? 0.0;
          // Calcola il carico glicemico per il cibo. Assumiamo che l'IG si riferisca a 100g.
          // Aggiorna la chiave 'glycemicLoad'
          data[entryDate]!['glycemicLoad'] = data[entryDate]!['glycemicLoad']! + ((entry['quantity'] ?? 0.0) / 100) * glycemicIndex;
        } else if (entry['type'] == 'sport') {
          final caloriesBurnedPerMinute = (entry['caloriesBurnedPerMinute'] as num?)?.toDouble() ?? 0.0;
          // Aggiorna la chiave 'burnedCalories'
          data[entryDate]!['burnedCalories'] = data[entryDate]!['burnedCalories']! + ((entry['quantity'] ?? 0.0) * caloriesBurnedPerMinute);
        }
      }
    }

    setState(() {
      _dailyData = data;
      _isLoading = false;
    });
  }

  /// Aggiorna il numero di giorni da visualizzare nel grafico e ricarica i dati.
  void _updateDays(int days) {
    setState(() {
      _selectedDays = days;
    });
    _loadChartData();
  }

  /// Costruisce i gruppi di barre per il grafico delle Calorie Consumate vs. Bruciate.
  List<BarChartGroupData> _buildCaloriesChartBarGroups() {
    List<BarChartGroupData> barGroups = [];
    List<String> sortedDates = _dailyData.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length; i++) {
      String date = sortedDates[i];
      // Usa le nuove chiavi per le calorie
      final consumedCalories = _dailyData[date]?['consumedCalories'] ?? 0.0;
      final burnedCalories = _dailyData[date]?['burnedCalories'] ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            // Barra per le calorie consumate
            BarChartRodData(
              toY: consumedCalories,
              color: Colors.blueAccent, // Colore per calorie consumate
              width: _barWidth,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
            // Barra per le calorie bruciate
            BarChartRodData(
              toY: burnedCalories,
              color: Colors.orange, // Colore per calorie bruciate
              width: _barWidth,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ],
          // showingTooltipIndicators: [0, 1], // Non strettamente necessario qui, gestito da getTooltipItem
        ),
      );
    }
    return barGroups;
  }

  /// Costruisce i gruppi di barre per il grafico del Carico Glicemico Totale.
  List<BarChartGroupData> _buildGlycemicLoadChartBarGroups() {
    List<BarChartGroupData> barGroups = [];
    List<String> sortedDates = _dailyData.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length; i++) {
      String date = sortedDates[i];
      // Usa la nuova chiave 'glycemicLoad'
      final glycemicLoad = _dailyData[date]?['glycemicLoad'] ?? 0.0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: glycemicLoad, // Rappresenta il carico glicemico
              color: Colors.purple, // Colore per il carico glicemico
              width: _singleBarWidth, // Larghezza maggiore per una singola barra
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ],
          // showingTooltipIndicators: [0], // Non strettamente necessario qui, gestito da getTooltipItem
        ),
      );
    }
    return barGroups;
  }

  /// Fornisce i dati per i titoli dell'asse X e Y per entrambi i grafici.
  FlTitlesData _getChartTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _bottomTitlesReservedSize,
          getTitlesWidget: (value, meta) {
            final dateKeys = _dailyData.keys.toList()..sort();
            final totalDays = dateKeys.length;

            if (value.toInt() < 0 || value.toInt() >= totalDays) return const Text('');

            // Mostra tutti se <= 7 giorni, altrimenti 1 ogni N giorni
            int step = totalDays <= 7 ? 1 : (totalDays <= 15 ? _dateAxisStepSmall : _dateAxisStepLarge);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiche ultimi $_selectedDays giorni'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dailyData.isEmpty
          ? const Center(child: Text('Nessun dato disponibile per i grafici.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Pulsanti per selezionare il periodo di visualizzazione
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDayButton(7),
                _buildDayButton(15),
                _buildDayButton(30),
              ],
            ),
            const SizedBox(height: 20),
            // Titolo per il grafico delle calorie
            Text(
              'Calorie Consumate vs. Bruciate (ultimi $_selectedDays giorni)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Grafico delle Calorie Consumate vs. Bruciate
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  // Calcola maxY basandosi sulle calorie di cibo e sport
                  maxY: _dailyData.values
                      .map((e) => (e['consumedCalories'] ?? 0.0) + (e['burnedCalories'] ?? 0.0))
                      .fold<double>(0.0, (a, b) => a > b ? a : b)
                      .clamp(1.0, double.infinity) *
                      1.2,
                  barGroups: _buildCaloriesChartBarGroups(),
                  // Usa la funzione unificata per i titoli
                  titlesData: _getChartTitlesData(),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final dateKeys = _dailyData.keys.toList()..sort();
                        if (group.x.toInt() < 0 || group.x.toInt() >= dateKeys.length) {
                          return null;
                        }
                        final dateString = dateKeys[group.x.toInt()];
                        final date = DateTime.parse(dateString);
                        final dayData = _dailyData[dateString] ?? {};
                        final consumed = dayData['consumedCalories'] ?? 0.0;
                        final burned = dayData['burnedCalories'] ?? 0.0;
                        return BarTooltipItem(
                          '${DateFormat('dd/MM').format(date)}\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: 'Consumate: ${consumed.toStringAsFixed(0)} kcal\n',
                              style: TextStyle(color: Colors.blueAccent.shade100),
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
              ),
            ),
            const SizedBox(height: 10),
            _buildCaloriesLegend(), // Leggenda per il grafico delle calorie
            const Divider(height: 40, thickness: 2),
            const SizedBox(height: 20),
            // Titolo per il grafico del carico glicemico
            Text(
              'Carico Glicemico Totale (ultimi $_selectedDays giorni)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Grafico del Carico Glicemico Totale
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  // Calcola maxY basandosi solo sul carico glicemico
                  maxY: _dailyData.values
                      .map((e) => e['glycemicLoad'] ?? 0.0)
                      .fold<double>(0.0, (a, b) => a > b ? a : b)
                      .clamp(1.0, double.infinity) *
                      1.2,
                  barGroups: _buildGlycemicLoadChartBarGroups(),
                  // Usa la funzione unificata per i titoli
                  titlesData: _getChartTitlesData(),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final dateKeys = _dailyData.keys.toList()..sort();
                        if (group.x.toInt() < 0 || group.x.toInt() >= dateKeys.length) {
                          return null;
                        }
                        final dateString = dateKeys[group.x.toInt()];
                        final date = DateTime.parse(dateString);
                        final glycemicLoad = _dailyData[dateString]?['glycemicLoad'] ?? 0.0;
                        return BarTooltipItem(
                          '${DateFormat('dd/MM').format(date)}\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: 'GL: ${glycemicLoad.toStringAsFixed(0)}', // Mostra il carico glicemico
                              style: TextStyle(color: Colors.purple.shade100),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildGlycemicLoadLegend(), // Leggenda per il grafico del carico glicemico
          ],
        ),
      ),
    );
  }

  /// Costruisce un pulsante per la selezione del numero di giorni.
  Widget _buildDayButton(int days) {
    return TextButton(
      onPressed: () => _updateDays(days),
      child: Text(
        'Ultimi $days giorni',
        style: TextStyle(
          fontWeight: _selectedDays == days ? FontWeight.bold : FontWeight.normal,
          color: _selectedDays == days ? Colors.blue : Colors.black,
        ),
      ),
    );
  }

  /// Costruisce la leggenda per il grafico delle calorie.
  Widget _buildCaloriesLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Utilizza i colori definiti per le barre per coerenza
        Container(width: 16, height: 16, color: Colors.blueAccent),
        const SizedBox(width: 4),
        const Text(
          'Calorie Consumate',
          style: TextStyle(color: Colors.black),
        ),
        const SizedBox(width: 20),
        Container(width: 16, height: 16, color: Colors.orange),
        const SizedBox(width: 4),
        const Text(
          'Calorie Bruciate',
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  /// Costruisce la leggenda per il grafico del carico glicemico.
  Widget _buildGlycemicLoadLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 16, height: 16, color: Colors.purple),
        const SizedBox(width: 4),
        const Text(
          'Carico Glicemico',
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}