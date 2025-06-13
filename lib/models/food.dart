// lib/models/food.dart

class Food {
  int? id; // ID unico per il cibo, generato dal database
  String name; // Nome del cibo
  String unit; // Unità di misura (es. "grammi", "ml", "porzione")
  double caloriesPerUnit; // Calorie per unità del cibo (es. calorie per grammo)
  double glycemicIndex; // Nuovo campo: Indice glicemico del cibo

  Food({
    this.id,
    required this.name,
    required this.unit,
    required this.caloriesPerUnit,
    required this.glycemicIndex, // Aggiornato: ora è richiesto
  });

  // Converte un oggetto Food in una Map. Utile per l'inserimento nel database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'caloriesPerUnit': caloriesPerUnit,
      'glycemicIndex': glycemicIndex, // Aggiunto al map
    };
  }

  // Costruisce un oggetto Food da una Map. Utile per recuperare dati dal database.
  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      unit: map['unit'],
      caloriesPerUnit: map['caloriesPerUnit'],
      glycemicIndex: map['glycemicIndex'] ?? 0.0, // Aggiunto dal map, con fallback
    );
  }

  @override
  String toString() {
    return 'Food{id: $id, name: $name, unit: $unit, caloriesPerUnit: $caloriesPerUnit, glycemicIndex: $glycemicIndex}';
  }
}




