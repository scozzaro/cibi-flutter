// lib/models/sport_activity.dart

class SportActivity {
  int? id; // ID unico per l'attività sportiva, generato dal database
  String name; // Nome dell'attività sportiva (es. "Corsa", "Nuoto")
  double caloriesBurnedPerMinute; // Calorie bruciate per minuto per questa attività

  SportActivity({this.id, required this.name, required this.caloriesBurnedPerMinute});

  // Converte un oggetto SportActivity in una Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'caloriesBurnedPerMinute': caloriesBurnedPerMinute,
    };
  }

  // Costruisce un oggetto SportActivity da una Map.
  factory SportActivity.fromMap(Map<String, dynamic> map) {
    return SportActivity(
      id: map['id'],
      name: map['name'],
      caloriesBurnedPerMinute: map['caloriesBurnedPerMinute'],
    );
  }

  @override
  String toString() {
    return 'SportActivity{id: $id, name: $name, caloriesBurnedPerMinute: $caloriesBurnedPerMinute}';
  }
}




