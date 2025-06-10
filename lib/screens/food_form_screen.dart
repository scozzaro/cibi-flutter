// lib/screens/food_form_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food.dart';

class FoodFormScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Food? foodToEdit; // Optional: if provided, we are in edit mode

  const FoodFormScreen({super.key, required this.dbHelper, this.foodToEdit});

  @override
  State<FoodFormScreen> createState() => _FoodFormScreenState();
}

class _FoodFormScreenState extends State<FoodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _glycemicIndexController = TextEditingController(); // Nuovo controller

  @override
  void initState() {
    super.initState();
    // If foodToEdit is provided, pre-fill the controllers
    if (widget.foodToEdit != null) {
      _nameController.text = widget.foodToEdit!.name;
      _unitController.text = widget.foodToEdit!.unit;
      _caloriesController.text = widget.foodToEdit!.caloriesPerUnit.toString();
      _glycemicIndexController.text = widget.foodToEdit!.glycemicIndex.toStringAsFixed(0); // Pre-fill con l'indice glicemico
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _caloriesController.dispose();
    _glycemicIndexController.dispose(); // Dispose del nuovo controller
    super.dispose();
  }

  Future<void> _saveFood() async {
    if (_formKey.currentState!.validate()) {
      final newFood = Food(
        id: widget.foodToEdit?.id, // Keep the ID if editing
        name: _nameController.text,
        unit: _unitController.text,
        caloriesPerUnit: double.parse(_caloriesController.text),
        glycemicIndex: double.parse(_glycemicIndexController.text), // Aggiunto indice glicemico
      );

      if (widget.foodToEdit == null) {
        // Add new food
        await widget.dbHelper.insertFood(newFood);
      } else {
        // Update existing food
        await widget.dbHelper.updateFood(newFood);
      }

      if (!mounted) return;
      Navigator.pop(context); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodToEdit == null ? 'Aggiungi Nuovo Cibo' : 'Modifica Cibo'),
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
                  labelText: 'Nome Cibo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favor, inserisci il nome del cibo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unità di Misura (es. grammi, ml, porzione)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favor, inserisci l\'unità di misura';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calorie per Unità (es. 0.52 per grammo)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favor, inserisci le calorie per unità';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Inserisci un numero valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // Spazio per il nuovo campo
              TextFormField(
                controller: _glycemicIndexController,
                decoration: const InputDecoration(
                  labelText: 'Indice Glicemico (es. 39 per mela)', // Nuovo campo
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favor, inserisci l\'indice glicemico';
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
                  onPressed: _saveFood,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(widget.foodToEdit == null ? 'Salva Cibo' : 'Aggiorna Cibo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





