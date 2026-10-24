class LiftEntry {
  final int? id;
  String name;
  String muscleGroup;
  String day;
  int sets;
  int reps;
  double weight;

  LiftEntry({
    this.id,
    required this.name,
    required this.muscleGroup,
    required this.day,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'muscle_group': muscleGroup,
    'day': day,
    'sets': sets,
    'reps': reps,
    'weight': weight,
  };

  factory LiftEntry.fromMap(Map<String, Object?> map) => LiftEntry(
    id: map['id'] as int?,
    name: map['name'] as String,
    muscleGroup: map['muscle_group'] as String,
    day: map['day'] as String,
    sets: map['sets'] as int,
    reps: map['reps'] as int,
    weight: (map['weight'] as num).toDouble(),
  );

  LiftEntry copyWith({int? id}) => LiftEntry(
    id: id ?? this.id,
    name: name,
    muscleGroup: muscleGroup,
    day: day,
    sets: sets,
    reps: reps,
    weight: weight,
  );
}
