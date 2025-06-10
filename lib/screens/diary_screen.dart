// lib/screens/diary_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/database_helper.dart';
import '../models/diary_entry.dart';
import 'food_entry_form_screen.dart';
import 'sport_entry_form_screen.dart';
import 'package:intl/intl.dart';

class DiaryScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const DiaryScreen({super.key, required this.dbHelper});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _diaryEntriesForSelectedDate = [];
  double _totalFoodCaloriesForDay = 0.0;
  double _totalSportCaloriesBurnedForDay = 0.0;
  double _totalGlycemicIndexForDay = 0.0; // Nuovo: totale indice glicemico per il giorno
  bool _isCalendarExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadDiaryEntriesForDate(_selectedDay);
  }

  Future<void> _loadDiaryEntriesForDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final entries = await widget.dbHelper.getDetailedDiaryEntries(date: formattedDate);

    double sumFoodCalories = 0.0;
    double sumSportCaloriesBurned = 0.0;
    double sumGlycemicIndex = 0.0; // Nuovo: inizializza il totale dell'indice glicemico

    for (var entry in entries) {
      if (entry['type'] == 'food') {
        final caloriesPerUnit = (entry['caloriesPerUnit'] is num)
            ? (entry['caloriesPerUnit'] as num).toDouble()
            : 0.0;
        sumFoodCalories += (entry['quantity'] ?? 0.0) * caloriesPerUnit;

        final glycemicIndex = (entry['glycemicIndex'] is num) // Ottieni l'indice glicemico
            ? (entry['glycemicIndex'] as num).toDouble()
            : 0.0;
        // Modifica qui: dividiamo la quantità per 100 prima di moltiplicare per l'IG
        sumGlycemicIndex += ((entry['quantity'] ?? 0.0) / 100) * glycemicIndex; // Calcola l'indice glicemico ponderato
      } else if (entry['type'] == 'sport') {
        final caloriesBurnedPerMinute = (entry['caloriesBurnedPerMinute'] is num)
            ? (entry['caloriesBurnedPerMinute'] as num).toDouble()
            : 0.0;
        sumSportCaloriesBurned += (entry['quantity'] ?? 0.0) * caloriesBurnedPerMinute;
      }
    }

    setState(() {
      _diaryEntriesForSelectedDate = entries;
      _totalFoodCaloriesForDay = sumFoodCalories;
      _totalSportCaloriesBurnedForDay = sumSportCaloriesBurned;
      _totalGlycemicIndexForDay = sumGlycemicIndex; // Aggiorna la variabile di stato dell'indice glicemico
    });
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDay = _selectedDay.subtract(const Duration(days: 1));
      _focusedDay = _selectedDay;
    });
    _loadDiaryEntriesForDate(_selectedDay);
  }

  void _goToNextDay() {
    setState(() {
      _selectedDay = _selectedDay.add(const Duration(days: 1));
      _focusedDay = _selectedDay;
    });
    _loadDiaryEntriesForDate(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tappable date header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isCalendarExpanded = !_isCalendarExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous Day Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: _goToPreviousDay,
                    color: Colors.grey[700],
                  ),
                  Icon(
                    _isCalendarExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE d MMMM', 'it_IT').format(_selectedDay),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  // Next Day Button
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: _goToNextDay,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
          ),
          // Expandable calendar
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _isCalendarExpanded = false; // richiudi dopo selezione
                });
                _loadDiaryEntriesForDate(selectedDay);
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            crossFadeState: _isCalendarExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          const Divider(height: 1),
          // Calorie summary labels
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cibi mangiati:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Calorie Consumate: ${_totalFoodCaloriesForDay.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Spazio tra le righe di riepilogo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attività Sportive:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Calorie Bruciate: ${_totalSportCaloriesBurnedForDay.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Spazio per il nuovo campo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Indice Glicemico Totale:', // Nuovo: etichetta per l'indice glicemico
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'IG: ${_totalGlycemicIndexForDay.toStringAsFixed(0)}', // Nuovo: visualizza l'indice glicemico totale
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple), // Colore a scelta
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Entry list
          Expanded(
            child: _diaryEntriesForSelectedDate.isEmpty
                ? const Center(child: Text('Nessuna voce per questa data.'))
                : ListView.builder(
              itemCount: _diaryEntriesForSelectedDate.length,
              itemBuilder: (context, index) {
                final entry = _diaryEntriesForSelectedDate[index];
                double calculatedCalories = 0.0;
                String entryDetails = '';
                IconData entryIcon;
                Color iconColor;
                String glycemicIndexInfo = ''; // Aggiunto per l'indice glicemico

                if (entry['type'] == 'food') {
                  final caloriesPerUnit = (entry['caloriesPerUnit'] is num)
                      ? (entry['caloriesPerUnit'] as num).toDouble()
                      : 0.0;
                  calculatedCalories = (entry['quantity'] ?? 0.0) * caloriesPerUnit;
                  final glycemicIndex = (entry['glycemicIndex'] is num)
                      ? (entry['glycemicIndex'] as num).toDouble()
                      : 0.0;
                  glycemicIndexInfo = ' - IG: ${glycemicIndex.toStringAsFixed(0)}'; // Formatta IG
                  entryDetails =
                  '${entry['foodName']} - ${entry['quantity']} ${entry['foodUnit']}';
                  entryIcon = Icons.fastfood;
                  iconColor = Colors.blueAccent;
                } else {
                  final caloriesBurnedPerMinute = (entry['caloriesBurnedPerMinute'] is num)
                      ? (entry['caloriesBurnedPerMinute'] as num).toDouble()
                      : 0.0;
                  calculatedCalories =
                      (entry['quantity'] ?? 0.0) * caloriesBurnedPerMinute;
                  entryDetails =
                  '${entry['sportName']} - ${entry['quantity']} minuti';
                  entryIcon = Icons.directions_run;
                  iconColor = Colors.orange;
                }

                return Card(
                  margin:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: Icon(entryIcon, color: iconColor),
                    title: Text('$entryDetails$glycemicIndexInfo'), // Visualizza IG nel titolo
                    subtitle: Text(
                        'Ora: ${entry['time']} - Calorie: ${calculatedCalories.toStringAsFixed(2)}'),
                    trailing: Row( // Row to hold both edit and delete icons
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue), // Edit icon
                          onPressed: () async {
                            // Convert the map entry back to a DiaryEntry object for the form
                            final diaryEntryToEdit = DiaryEntry.fromMap(entry);
                            if (diaryEntryToEdit.type == 'food') {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FoodEntryFormScreen(
                                    dbHelper: widget.dbHelper,
                                    diaryEntryToEdit: diaryEntryToEdit, // Pass the entry for editing
                                  ),
                                ),
                              );
                            } else if (diaryEntryToEdit.type == 'sport') {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SportEntryFormScreen(
                                    dbHelper: widget.dbHelper,
                                    diaryEntryToEdit: diaryEntryToEdit, // Pass the entry for editing
                                  ),
                                ),
                              );
                            }
                            _loadDiaryEntriesForDate(_selectedDay); // Reload after editing
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await widget.dbHelper.deleteDiaryEntry(entry['id']);
                            _loadDiaryEntriesForDate(_selectedDay);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row( // Changed Column to Row
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
        children: [
          FloatingActionButton.extended(
            heroTag: 'addFoodBtn',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FoodEntryFormScreen(dbHelper: widget.dbHelper, initialDate: _selectedDay), // Pass selected date
                ),
              );
              _loadDiaryEntriesForDate(_selectedDay);
            },
            label: const Text('Aggiungi Cibo'),
            icon: const Icon(Icons.fastfood),
            backgroundColor: Colors.blue,
          ),
          FloatingActionButton.extended(
            heroTag: 'addSportBtn',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SportEntryFormScreen(dbHelper: widget.dbHelper, initialDate: _selectedDay), // Pass selected date
                ),
              );
              _loadDiaryEntriesForDate(_selectedDay);
            },
            label: const Text('Aggiungi Sport'),
            icon: const Icon(Icons.directions_run),
            backgroundColor: Colors.orange,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center the row horizontally
    );
  }
}





