// lib/screens/food_list_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food.dart';
import 'food_form_screen.dart'; // Changed import to food_form_screen.dart

class FoodListScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const FoodListScreen({super.key, required this.dbHelper});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  List<Food> _foods = [];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  // Loads all food items from the database
  Future<void> _loadFoods() async {
    final foods = await widget.dbHelper.getFoods();
    setState(() {
      _foods = foods;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cibi Registrati:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _foods.isEmpty
                  ? const Center(child: Text('Nessun cibo registrato.'))
                  : ListView.builder(
                itemCount: _foods.length,
                itemBuilder: (context, index) {
                  final food = _foods[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(food.name),
                      subtitle: Text('Unità: ${food.unit} - Calorie/unità: ${food.caloriesPerUnit.toStringAsFixed(2)} - IG: ${food.glycemicIndex.toStringAsFixed(0)}'), // Aggiornato per mostrare l'indice glicemico
                      trailing: Row( // Use Row to place multiple icons
                        mainAxisSize: MainAxisSize.min, // Make row as small as possible
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue), // Edit icon
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FoodFormScreen(
                                    dbHelper: widget.dbHelper,
                                    foodToEdit: food, // Pass the food object to edit
                                  ),
                                ),
                              );
                              _loadFoods(); // Reload data after editing
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red), // Delete icon
                            onPressed: () async {
                              await widget.dbHelper.deleteFood(food.id!);
                              _loadFoods(); // Reload data after deletion
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodFormScreen(dbHelper: widget.dbHelper), // Navigate to FoodFormScreen for adding
            ),
          );
          _loadFoods(); // Reload foods when returning from FoodFormScreen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}




