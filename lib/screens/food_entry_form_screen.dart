// lib/screens/food_entry_form_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/food.dart';
import '../models/diary_entry.dart';

class FoodEntryFormScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final DiaryEntry? diaryEntryToEdit; // Optional: if provided, we are in edit mode
  final DateTime? initialDate; // New: optional initial date for new entries

  const FoodEntryFormScreen({super.key, required this.dbHelper, this.diaryEntryToEdit, this.initialDate});

  @override
  State<FoodEntryFormScreen> createState() => _FoodEntryFormScreenState();
}

class _FoodEntryFormScreenState extends State<FoodEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Food> _availableFoods = [];
  Food? _selectedFood;
  final TextEditingController _quantityController = TextEditingController();
  late DateTime _selectedDate; // Changed to late to be initialized in initState
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now(); // Initialize with initialDate or current date

    _loadFoods().then((_) {
      if (widget.diaryEntryToEdit != null && widget.diaryEntryToEdit!.type == 'food') {
        _selectedFood = _availableFoods.firstWhere(
              (food) => food.id == widget.diaryEntryToEdit!.foodId,
          orElse: () => _availableFoods.first, // Fallback if food not found
        );
        _quantityController.text = widget.diaryEntryToEdit!.quantity.toString();
        _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.diaryEntryToEdit!.date);
        final parts = widget.diaryEntryToEdit!.time.split(':');
        _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    });
  }

  Future<void> _loadFoods() async {
    final foods = await widget.dbHelper.getFoods();
    setState(() {
      _availableFoods = foods;
      if (_selectedFood == null && foods.isNotEmpty) {
        _selectedFood = foods.first;
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
    if (_formKey.currentState!.validate() && _selectedFood != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedTime = _selectedTime.format(context);

      final newEntry = DiaryEntry(
        id: widget.diaryEntryToEdit?.id, // Use existing ID if editing
        date: formattedDate,
        time: formattedTime,
        type: 'food',
        foodId: _selectedFood!.id!,
        quantity: double.parse(_quantityController.text),
      );

      if (widget.diaryEntryToEdit == null) {
        await widget.dbHelper.insertDiaryEntry(newEntry);
      } else {
        await widget.dbHelper.updateDiaryEntry(newEntry);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } else if (_selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favor, seleziona un cibo.')),
      );
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diaryEntryToEdit == null ? 'Aggiungi Voce Cibo al Diario' : 'Modifica Voce Cibo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Food>(
                decoration: const InputDecoration(
                  labelText: 'Seleziona Cibo',
                  border: OutlineInputBorder(),
                ),
                value: _selectedFood,
                items: _availableFoods.map((food) {
                  return DropdownMenuItem(
                    value: food,
                    child: Text('${food.name} (${food.unit}) - ${food.caloriesPerUnit.toStringAsFixed(2)} cal/unità - IG: ${food.glycemicIndex.toStringAsFixed(0)}'), // Aggiornato per mostrare l'indice glicemico
                  );
                }).toList(),
                onChanged: (Food? newValue) {
                  setState(() {
                    _selectedFood = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Per favor, seleziona un cibo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantità',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favor, inserisci la quantità';
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
                  child: Text(widget.diaryEntryToEdit == null ? 'Salva Voce Cibo' : 'Aggiorna Voce Cibo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




