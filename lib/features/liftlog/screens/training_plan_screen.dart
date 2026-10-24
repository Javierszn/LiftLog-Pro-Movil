import 'package:flutter/material.dart';

import '../models/lift_entry.dart';
import '../services/local_database.dart';
import 'entry_detail_screen.dart';
import 'first_review_screen.dart';
import 'workout_session_screen.dart';

class TrainingPlanScreen extends StatefulWidget {
  const TrainingPlanScreen({super.key, required this.userId});

  final int userId;

  @override
  State<TrainingPlanScreen> createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  final List<String> _days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  final List<String> _fullDays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  int _selectedDay = DateTime.now().weekday - 1;
  List<LiftEntry> _exercises = [];
  bool _loading = true;

  String get _dayName => _fullDays[_selectedDay];

  @override
  void initState() {
    super.initState();
    _loadDay();
  }

  Future<void> _loadDay() async {
    setState(() => _loading = true);
    final exercises = await LocalDatabase.instance.getExercises(
      widget.userId,
      day: _dayName,
    );
    if (!mounted) return;
    setState(() {
      _exercises = exercises;
      _loading = false;
    });
  }

  Future<void> _editRoutine() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FirstReviewScreen(userId: widget.userId, initialDay: _dayName),
      ),
    );
    if (mounted) _loadDay();
  }

  void _startWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSessionScreen(
          userId: widget.userId,
          routineName: _dayName,
          exercises: _exercises,
        ),
      ),
    ).then((_) {
      if (mounted) _loadDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Plan semanal')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Tu semana',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Consulta las rutinas que organizaste por día.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _days.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_days[index]),
                        selected: index == _selectedDay,
                        onSelected: (_) {
                          setState(() => _selectedDay = index);
                          _loadDay();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: colors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: colors.onPrimaryContainer,
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _dayName,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onPrimaryContainer,
                                  ),
                            ),
                            Text(
                              _loading
                                  ? 'Cargando rutina…'
                                  : '${_exercises.length} ejercicios',
                              style: TextStyle(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Editar rutina',
                        onPressed: _editRoutine,
                        icon: Icon(
                          Icons.edit_outlined,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_exercises.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 42,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text('No hay ejercicios para $_dayName.'),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _editRoutine,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar ejercicios'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._exercises.asMap().entries.map(
                  (item) => Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${item.key + 1}')),
                      title: Text(item.value.name),
                      subtitle: Text(
                        '${item.value.muscleGroup} · ${item.value.sets} × ${item.value.reps} · ${item.value.weight} kg',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EntryDetailScreen(entry: item.value),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_exercises.isNotEmpty && !_loading) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _startWorkout,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Comenzar este entrenamiento'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
