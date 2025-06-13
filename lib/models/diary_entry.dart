// lib/models/diary_entry.dart

class DiaryEntry {
  int? id; // ID unico per l'entrata, generato dal database
  String date; // Data dell'entrata (es. "YYYY-MM-DD")
  String time; // Ora dell'entrata (es. "HH:MM")
  String type; // Tipo di entrata: 'food' o 'sport'
  int? foodId; // ID del cibo collegato (nullable se type è 'sport')
  int? sportActivityId; // ID dell'attività sportiva collegata (nullable se type è 'food')
  double quantity; // Quantità per il cibo, durata in minuti per l'attività sportiva

  DiaryEntry({
    this.id,
    required this.date,
    required this.time,
    required this.type,
    this.foodId,
    this.sportActivityId,
    required this.quantity,
  }) : assert((type == 'food' && foodId != null && sportActivityId == null) ||
      (type == 'sport' && sportActivityId != null && foodId == null),
  'Per il tipo "food", foodId non deve essere nullo e sportActivityId deve essere nullo. '
      'Per il tipo "sport", sportActivityId non deve essere nullo e foodId deve essere nullo.');


  // Converte un oggetto DiaryEntry in una Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'type': type,
      'foodId': foodId,
      'sportActivityId': sportActivityId,
      'quantity': quantity,
    };
  }

  // Costruisce un oggetto DiaryEntry da una Map.
  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      date: map['date'],
      time: map['time'],
      type: map['type'],
      foodId: map['foodId'],
      sportActivityId: map['sportActivityId'],
      quantity: map['quantity'],
    );
  }

  @override
  String toString() {
    return 'DiaryEntry{id: $id, date: $date, time: $time, type: $type, foodId: $foodId, sportActivityId: $sportActivityId, quantity: $quantity}';
  }
}




