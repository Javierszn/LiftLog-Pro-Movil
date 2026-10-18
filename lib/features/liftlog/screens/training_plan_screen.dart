import 'package:flutter/material.dart';
import 'workout_session_screen.dart';

class TrainingPlanScreen extends StatefulWidget {
  const TrainingPlanScreen({super.key});

  @override
  State<TrainingPlanScreen> createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  final List<String> _days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  int _selectedDay = DateTime.now().weekday - 1;
  final Map<String, List<String>> _routines = {
    'Lunes': ['Press de banca', 'Press inclinado', 'Extensión de tríceps'],
    'Martes': ['Sentadilla', 'Peso muerto rumano', 'Elevación de pantorrilla'],
    'Miércoles': ['Jalón al pecho', 'Remo con mancuerna', 'Curl de bíceps'],
    'Jueves': ['Press militar', 'Elevaciones laterales', 'Face pull'],
    'Viernes': ['Prensa de pierna', 'Curl femoral', 'Abdominales'],
    'Sábado': ['Caminata ligera', 'Movilidad'],
    'Domingo': ['Descanso y recuperación'],
  };

  String get _dayName => const ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'][_selectedDay];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final routine = _routines[_dayName]!;
    return Scaffold(
      appBar: AppBar(title: const Text('Plan semanal')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Text('Tu semana', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Selecciona un día para consultar su rutina.', style: TextStyle(color: colors.onSurfaceVariant)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(_days.length, (index) => ChoiceChip(
              label: Text(_days[index]),
              selected: index == _selectedDay,
              onSelected: (_) => setState(() => _selectedDay = index),
            ))),
            const SizedBox(height: 24),
            Card(color: colors.primaryContainer, child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Icon(_dayName == 'Domingo' ? Icons.spa_outlined : Icons.fitness_center, color: colors.onPrimaryContainer, size: 30),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_dayName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.onPrimaryContainer)),
                  Text(_dayName == 'Domingo' ? 'Recuperación' : '${routine.length} ejercicios', style: TextStyle(color: colors.onPrimaryContainer)),
                ])),
              ]),
            )),
            const SizedBox(height: 12),
            ...routine.asMap().entries.map((item) => Card(child: ListTile(
              leading: CircleAvatar(child: Text('${item.key + 1}')),
              title: Text(item.value),
              subtitle: Text(_dayName == 'Domingo' ? 'Día libre' : '3 series · 8–12 repeticiones'),
              trailing: const Icon(Icons.fitness_center),
            ))),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _dayName == 'Domingo' ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutSessionScreen(routineName: _dayName, exerciseNames: routine))),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Comenzar este entrenamiento'),
            ),
          ]),
        ),
      ),
    );
  }
}
