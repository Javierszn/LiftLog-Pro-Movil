class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.weeklyGoal,
  });

  final int id;
  final String name;
  final String email;
  final int weeklyGoal;

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
    id: map['id'] as int,
    name: map['name'] as String,
    email: map['email'] as String,
    weeklyGoal: map['weekly_goal'] as int? ?? 4,
  );

  AppUser copyWith({String? name, int? weeklyGoal}) => AppUser(
    id: id,
    name: name ?? this.name,
    email: email,
    weeklyGoal: weeklyGoal ?? this.weeklyGoal,
  );
}
