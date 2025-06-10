// lib/screens/sport_form_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/sport_activity.dart';

class SportFormScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final SportActivity? sportActivityToEdit; // Opzionale: se fornito, siamo in modalità modifica

  const SportFormScreen({super.key, required this.dbHelper, this.sportActivityToEdit});

  @override
  State<SportFormScreen> createState() => _SportFormScreenState();
}

class _SportFormScreenState extends State<SportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesBurnedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Se sportActivityToEdit è fornito, precompila i controller
    if (widget.sportActivityToEdit != null) {
      _nameController.text = widget.sportActivityToEdit!.name;
      _caloriesBurnedController.text = widget.sportActivityToEdit!.caloriesBurnedPerMinute.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesBurnedController.dispose();
    super.dispose();
  }

  Future<void> _saveSportActivity() async {
    if (_formKey.currentState!.validate()) {
      final newSportActivity = SportActivity(
        id: widget.sportActivityToEdit?.id, // Mantiene l'ID se in modifica
        name: _nameController.text,
        caloriesBurnedPerMinute: double.parse(_caloriesBurnedController.text),
      );

      if (widget.sportActivityToEdit == null) {
        // Aggiungi nuova attività sportiva
        await widget.dbHelper.insertSportActivity(newSportActivity);
      } else {
        // Aggiorna attività sportiva esistente
        await widget.dbHelper.updateSportActivity(newSportActivity);
      }

      if (!mounted) return;
      Navigator.pop(context); // Torna alla schermata precedente
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sportActivityToEdit == null ? 'Aggiungi Nuova Attività Sportiva' : 'Modifica Attività Sportiva'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Attività Sportiva',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favor, inserisci il nome dell\'attività';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesBurnedController,
                decoration: const InputDecoration(
                  labelText: 'Calorie bruciate per minuto (es. 10.0)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favor, inserisci le calorie bruciate per minuto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Inserisci un numero valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveSportActivity,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(widget.sportActivityToEdit == null ? 'Salva Attività' : 'Aggiorna Attività'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





