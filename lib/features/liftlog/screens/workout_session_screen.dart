import 'package:flutter/material.dart';

import '../models/lift_entry.dart';
import '../services/local_database.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({
    super.key,
    required this.userId,
    required this.routineName,
    required this.exercises,
  });

  final int userId;
  final String routineName;
  final List<LiftEntry> exercises;

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late final List<bool> _completed = List<bool>.filled(
    widget.exercises.length,
    false,
  );
  int get _completedCount => _completed.where((done) => done).length;
  bool _saving = false;

  Future<void> _finishWorkout() async {
    if (_completedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marca al menos un ejercicio para guardar la sesión.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await LocalDatabase.instance.recordWorkout(
        widget.userId,
        widget.routineName,
        widget.exercises,
        _completed,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.emoji_events_outlined),
          title: const Text('Entrenamiento guardado'),
          content: Text(
            'Completaste $_completedCount de ${widget.exercises.length} ejercicios.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Listo'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar la sesión.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = widget.exercises.isEmpty
        ? 0.0
        : _completedCount / widget.exercises.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Entrenamiento')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                widget.routineName,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Marca cada ejercicio al terminarlo.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Avance de la sesión'),
                          Text(
                            '$_completedCount/${widget.exercises.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(widget.exercises.length, (index) {
                final exercise = widget.exercises[index];
                return Card(
                  child: CheckboxListTile(
                    value: _completed[index],
                    onChanged: (value) =>
                        setState(() => _completed[index] = value ?? false),
                    secondary: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(exercise.name),
                    subtitle: Text(
                      '${exercise.sets} series · ${exercise.reps} repeticiones · ${exercise.weight} kg',
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              }),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _finishWorkout,
                icon: const Icon(Icons.check),
                label: Text(_saving ? 'Guardando…' : 'Finalizar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
