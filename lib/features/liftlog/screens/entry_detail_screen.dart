import 'package:flutter/material.dart';
import '../models/lift_entry.dart';

class EntryDetailScreen extends StatelessWidget {
  final LiftEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del ejercicio')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                Text('Grupo muscular: ${entry.muscleGroup}'),
                Text('Día: ${entry.day}'),
                Text('Series: ${entry.sets}'),
                Text('Repeticiones: ${entry.reps}'),
                Text('Peso: ${entry.weight} kg'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}