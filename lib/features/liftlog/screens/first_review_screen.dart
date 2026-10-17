import 'package:flutter/material.dart';
import '../models/lift_entry.dart';
import 'entry_detail_screen.dart';

class FirstReviewScreen extends StatefulWidget {
  const FirstReviewScreen({super.key});

  @override
  State<FirstReviewScreen> createState() => _FirstReviewScreenState();
}

class _FirstReviewScreenState extends State<FirstReviewScreen> {
  final List<LiftEntry> _entries = [
    LiftEntry(name: 'Press de banca', muscleGroup: 'Pecho', day: 'Lunes', sets: 4, reps: 8, weight: 40),
    LiftEntry(name: 'Sentadilla', muscleGroup: 'Pierna', day: 'Martes', sets: 3, reps: 10, weight: 50),
  ];

  final List<String> _muscleGroups = ['Pecho', 'Espalda', 'Pierna', 'Hombro', 'Brazos'];
  final List<String> _days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showEntryDialog({LiftEntry? entry}) async {
    final nameController = TextEditingController(text: entry?.name ?? '');
    final setsController = TextEditingController(text: entry?.sets.toString() ?? '');
    final repsController = TextEditingController(text: entry?.reps.toString() ?? '');
    final weightController = TextEditingController(text: entry?.weight.toString() ?? '');
    String selectedGroup = entry?.muscleGroup ?? _muscleGroups.first;
    String selectedDay = entry?.day ?? _days.first;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(entry == null ? 'Agregar ejercicio' : 'Editar ejercicio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre del ejercicio')),
                TextField(controller: setsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Series')),
                TextField(controller: repsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Repeticiones')),
                TextField(controller: weightController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Peso en kg')),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: selectedGroup,
                  isExpanded: true,
                  items: _muscleGroups.map((group) => DropdownMenuItem(value: group, child: Text(group))).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedGroup = value);
                  },
                ),
                DropdownButton<String>(
                  value: selectedDay,
                  isExpanded: true,
                  items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedDay = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final sets = int.tryParse(setsController.text);
                final reps = int.tryParse(repsController.text);
                final weight = double.tryParse(weightController.text.replaceAll(',', '.'));
                if (nameController.text.trim().isEmpty || sets == null || reps == null || weight == null) {
                  _showMessage('Completa los datos con valores válidos.');
                  return;
                }

                final newEntry = LiftEntry(
                  name: nameController.text.trim(),
                  muscleGroup: selectedGroup,
                  day: selectedDay,
                  sets: sets,
                  reps: reps,
                  weight: weight,
                );

                setState(() {
                  if (entry == null) {
                    _entries.add(newEntry);
                  } else {
                    final index = _entries.indexOf(entry);
                    if (index != -1) _entries[index] = newEntry;
                  }
                });
                Navigator.pop(dialogContext);
                _showMessage(entry == null ? 'Ejercicio agregado.' : 'Ejercicio actualizado.');
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LiftLog Pro · Mis ejercicios')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _entries.isEmpty
              ? const Center(child: Text('Todavía no hay ejercicios. Agrega el primero.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Dismissible(
                      key: ObjectKey(entry),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        setState(() => _entries.removeAt(index));
                        _showMessage('Ejercicio eliminado.');
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(entry.name),
                          subtitle: Text('${entry.day} · ${entry.muscleGroup} · ${entry.sets} × ${entry.reps} · ${entry.weight} kg'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EntryDetailScreen(entry: entry)),
                            );
                          },
                          trailing: IconButton(
                            tooltip: 'Editar ejercicio',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showEntryDialog(entry: entry),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}