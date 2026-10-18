import 'package:flutter/material.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key, this.routineName = 'Día de fuerza', this.exerciseNames});

  final String routineName;
  final List<String>? exerciseNames;

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late final List<String> _exercises = widget.exerciseNames ?? ['Press de banca', 'Sentadilla', 'Remo con mancuerna', 'Press militar'];
  late final List<bool> _completed = List<bool>.filled(_exercises.length, false);
  int get _completedCount => _completed.where((done) => done).length;

  Future<void> _finishWorkout() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.emoji_events_outlined),
        title: const Text('Entrenamiento terminado'),
        content: Text('Completaste $_completedCount de ${_exercises.length} ejercicios. ¡Buen trabajo!'),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Listo'))],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = _exercises.isEmpty ? 0.0 : _completedCount / _exercises.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Entrenamiento')),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text(widget.routineName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Marca cada ejercicio al terminarlo.', style: TextStyle(color: colors.onSurfaceVariant)),
          const SizedBox(height: 20),
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Avance de la sesión'), Text('$_completedCount/${_exercises.length}', style: const TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, minHeight: 8, borderRadius: BorderRadius.circular(8)),
          ]))),
          const SizedBox(height: 12),
          ...List.generate(_exercises.length, (index) => Card(child: CheckboxListTile(
            value: _completed[index],
            onChanged: (value) => setState(() => _completed[index] = value ?? false),
            secondary: CircleAvatar(child: Text('${index + 1}')),
            title: Text(_exercises[index]),
            subtitle: const Text('3 series · 8–12 repeticiones'),
            controlAffinity: ListTileControlAffinity.trailing,
          ))),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: _finishWorkout, icon: const Icon(Icons.check), label: const Text('Finalizar sesión')),
        ]),
      )),
    );
  }
}
