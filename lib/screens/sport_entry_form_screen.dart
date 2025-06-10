// lib/screens/sport_entry_form_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/sport_activity.dart';
import '../models/diary_entry.dart';

class SportEntryFormScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final DiaryEntry? diaryEntryToEdit; // Optional: if provided, we are in edit mode
  final DateTime? initialDate; // New: optional initial date for new entries

  const SportEntryFormScreen({super.key, required this.dbHelper, this.diaryEntryToEdit, this.initialDate});

  @override
  State<SportEntryFormScreen> createState() => _SportEntryFormScreenState();
}

class _SportEntryFormScreenState extends State<SportEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  List<SportActivity> _availableSportActivities = [];
  SportActivity? _selectedSportActivity;
  final TextEditingController _durationController = TextEditingController(); // Duration in minutes
  late DateTime _selectedDate; // Changed to late to be initialized in initState
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now(); // Initialize with initialDate or current date

    _loadSportActivities().then((_) {
      if (widget.diaryEntryToEdit != null && widget.diaryEntryToEdit!.type == 'sport') {
        _selectedSportActivity = _availableSportActivities.firstWhere(
              (activity) => activity.id == widget.diaryEntryToEdit!.sportActivityId,
          orElse: () => _availableSportActivities.first, // Fallback if activity not found
        );
        _durationController.text = widget.diaryEntryToEdit!.quantity.toString();
        _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.diaryEntryToEdit!.date);
        final parts = widget.diaryEntryToEdit!.time.split(':');
        _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    });
  }

  Future<void> _loadSportActivities() async {
    final activities = await widget.dbHelper.getSportActivities();
    setState(() {
      _availableSportActivities = activities;
      if (_selectedSportActivity == null && activities.isNotEmpty) {
        _selectedSportActivity = activities.first;
      }
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveDiaryEntry() async {
    if (_formKey.currentState!.validate() && _selectedSportActivity != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedTime = _selectedTime.format(context);

      final newEntry = DiaryEntry(
        id: widget.diaryEntryToEdit?.id, // Use existing ID if editing
        date: formattedDate,
        time: formattedTime,
        type: 'sport',
        sportActivityId: _selectedSportActivity!.id!,
        quantity: double.parse(_durationController.text),
      );

      if (widget.diaryEntryToEdit == null) {
        await widget.dbHelper.insertDiaryEntry(newEntry);
      } else {
        await widget.dbHelper.updateDiaryEntry(newEntry);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } else if (_selectedSportActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favor, seleziona un\'attività sportiva.')),
      );
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diaryEntryToEdit == null ? 'Aggiungi Voce Sport al Diario' : 'Modifica Voce Sport'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<SportActivity>(
                decoration: const InputDecoration(
                  labelText: 'Seleziona Attività Sportiva',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSportActivity,
                items: _availableSportActivities.map((activity) {
                  return DropdownMenuItem(
                    value: activity,
                    child: Text('${activity.name} (${activity.caloriesBurnedPerMinute.toStringAsFixed(2)} cal/min)'),
                  );
                }).toList(),
                onChanged: (SportActivity? newValue) {
                  setState(() {
                    _selectedSportActivity = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Per favore, seleziona un\'attività sportiva';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Durata (minuti)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favor, inserisci la durata';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Inserisci un numero valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Data: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              ListTile(
                title: Text('Ora: ${_selectedTime.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(context),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveDiaryEntry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(widget.diaryEntryToEdit == null ? 'Salva Voce Sport' : 'Aggiorna Voce Sport'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





