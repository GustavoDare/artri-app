class Remedy {
  final int id;
  final String name;
  final String dosage;
  final String hour;
  final List<int> daysOfWeek;
  final int? reminderMinutes;
  final int userId; // Campo adicionado para separar por usuário

  Remedy({
    required this.id,
    required this.name,
    required this.dosage,
    required this.hour,
    required this.daysOfWeek,
    this.reminderMinutes,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'hour': hour,
      'days_of_week': daysOfWeek,
      'reminder_minutes': reminderMinutes,
      'user_id': userId,
    };
  }

  factory Remedy.fromMap(Map<String, dynamic> map) {
    return Remedy(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'] ?? '',
      hour: map['hour'] ?? '',
      daysOfWeek: List<int>.from(map['days_of_week'] ?? []),
      reminderMinutes: map['reminder_minutes'],
      userId: map['user_id'] ?? 0,
    );
  }
}