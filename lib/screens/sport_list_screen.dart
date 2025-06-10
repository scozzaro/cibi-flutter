// lib/screens/sport_list_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/sport_activity.dart';
import 'sport_form_screen.dart'; // Nuovo import

class SportListScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const SportListScreen({super.key, required this.dbHelper});

  @override
  State<SportListScreen> createState() => _SportListScreenState();
}

class _SportListScreenState extends State<SportListScreen> {
  List<SportActivity> _sportActivities = [];

  @override
  void initState() {
    super.initState();
    _loadSportActivities();
  }

  // Carica tutte le attività sportive dal database
  Future<void> _loadSportActivities() async {
    final activities = await widget.dbHelper.getSportActivities();
    setState(() {
      _sportActivities = activities;
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
              'Attività Sportive Registrate:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _sportActivities.isEmpty
                  ? const Center(child: Text('Nessuna attività sportiva registrata.'))
                  : ListView.builder(
                itemCount: _sportActivities.length,
                itemBuilder: (context, index) {
                  final activity = _sportActivities[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(activity.name),
                      subtitle: Text('Calorie bruciate/min: ${activity.caloriesBurnedPerMinute.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SportFormScreen(
                                    dbHelper: widget.dbHelper,
                                    sportActivityToEdit: activity, // Passa l'oggetto attività da modificare
                                  ),
                                ),
                              );
                              _loadSportActivities(); // Ricarica i dati dopo la modifica
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await widget.dbHelper.deleteSportActivity(activity.id!);
                              _loadSportActivities(); // Ricarica i dati dopo l'eliminazione
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
              builder: (context) => SportFormScreen(dbHelper: widget.dbHelper), // Naviga a SportFormScreen per aggiungere
            ),
          );
          _loadSportActivities(); // Ricarica le attività quando si torna da SportFormScreen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}





