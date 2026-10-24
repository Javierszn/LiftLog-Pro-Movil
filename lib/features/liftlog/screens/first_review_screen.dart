import 'package:flutter/material.dart';

import '../models/lift_entry.dart';
import '../services/local_database.dart';
import 'entry_detail_screen.dart';

class FirstReviewScreen extends StatefulWidget {
  const FirstReviewScreen({
    super.key,
    required this.userId,
    this.initialDay,
    this.showAppBar = true,
  });

  final int userId;
  final String? initialDay;
  final bool showAppBar;

  @override
  State<FirstReviewScreen> createState() => _FirstReviewScreenState();
}

class _FirstReviewScreenState extends State<FirstReviewScreen> {
  final List<String> _muscleGroups = [
    'Pecho',
    'Espalda',
    'Pierna',
    'Hombro',
    'Brazos',
    'Abdomen',
  ];
  final List<String> _days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  List<LiftEntry> _entries = [];
  late String _selectedDay;
  bool _loading = true;

  List<LiftEntry> get _visibleEntries => _selectedDay == 'Todos'
      ? _entries
      : _entries.where((entry) => entry.day == _selectedDay).toList();

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay ?? 'Todos';
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await LocalDatabase.instance.getExercises(widget.userId);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showEntryDialog({LiftEntry? entry}) async {
    final nameController = TextEditingController(text: entry?.name ?? '');
    final setsController = TextEditingController(
      text: entry?.sets.toString() ?? '3',
    );
    final repsController = TextEditingController(
      text: entry?.reps.toString() ?? '10',
    );
    final weightController = TextEditingController(
      text: entry?.weight.toString() ?? '0',
    );
    String selectedGroup = entry?.muscleGroup ?? _muscleGroups.first;
    String selectedDay =
        entry?.day ??
        (_selectedDay == 'Todos'
            ? _days[DateTime.now().weekday - 1]
            : _selectedDay);
    String? errorMessage;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(entry == null ? 'Agregar ejercicio' : 'Editar ejercicio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del ejercicio',
                  ),
                ),
                TextField(
                  controller: setsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Series'),
                ),
                TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Repeticiones'),
                ),
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Peso en kg'),
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: selectedGroup,
                  isExpanded: true,
                  items: _muscleGroups
                      .map(
                        (group) =>
                            DropdownMenuItem(value: group, child: Text(group)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedGroup = value);
                    }
                  },
                ),
                DropdownButton<String>(
                  value: selectedDay,
                  isExpanded: true,
                  items: _days
                      .map(
                        (day) => DropdownMenuItem(value: day, child: Text(day)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedDay = value);
                    }
                  },
                ),
                if (errorMessage != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final sets = int.tryParse(setsController.text);
                final reps = int.tryParse(repsController.text);
                final weight = double.tryParse(
                  weightController.text.replaceAll(',', '.'),
                );
                if (nameController.text.trim().isEmpty ||
                    sets == null ||
                    sets < 1 ||
                    reps == null ||
                    reps < 1 ||
                    weight == null ||
                    weight < 0) {
                  setDialogState(
                    () => errorMessage = 'Revisa el nombre, las series, las repeticiones y el peso.',
                  );
                  return;
                }
                final newEntry = LiftEntry(
                  id: entry?.id,
                  name: nameController.text.trim(),
                  muscleGroup: selectedGroup,
                  day: selectedDay,
                  sets: sets,
                  reps: reps,
                  weight: weight,
                );
                await LocalDatabase.instance.saveExercise(
                  widget.userId,
                  newEntry,
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                await _loadEntries();
                if (mounted) {
                  _showMessage(
                    entry == null
                        ? 'Ejercicio agregado.'
                        : 'Ejercicio actualizado.',
                  );
                }
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

  Future<void> _deleteRoutine() async {
    if (_selectedDay == 'Todos') return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Eliminar rutina del $_selectedDay'),
        content: const Text('Se eliminarán todos los ejercicios de ese día.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final count = await LocalDatabase.instance.deleteRoutine(
      widget.userId,
      _selectedDay,
    );
    await _loadEntries();
    if (mounted) _showMessage('Rutina eliminada: $count ejercicios.');
  }

  Future<void> _deleteEntry(LiftEntry entry) async {
    if (entry.id == null) return;
    await LocalDatabase.instance.deleteExercise(widget.userId, entry.id!);
    await _loadEntries();
    if (mounted) _showMessage('Ejercicio eliminado.');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Mis rutinas'),
              actions: [
                if (_selectedDay != 'Todos')
                  IconButton(
                    tooltip: 'Eliminar rutina del día',
                    onPressed: _deleteRoutine,
                    icon: const Icon(Icons.delete_sweep_outlined),
                  ),
              ],
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: [
                    ...['Todos', ..._days].map(
                      (day) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(day),
                          selected: _selectedDay == day,
                          onSelected: (_) => setState(() => _selectedDay = day),
                        ),
                      ),
                    ),
                    if (!widget.showAppBar && _selectedDay != 'Todos')
                      IconButton(
                        tooltip: 'Eliminar rutina del día',
                        onPressed: _deleteRoutine,
                        icon: const Icon(Icons.delete_sweep_outlined),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _visibleEntries.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 48,
                                color: colors.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedDay == 'Todos'
                                    ? 'Aún no tienes ejercicios.'
                                    : 'No hay ejercicios para $_selectedDay.',
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Agrega ejercicios para organizar tu rutina.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _visibleEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _visibleEntries[index];
                          return Dismissible(
                            key: ValueKey(entry.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: colors.error,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) => _deleteEntry(entry),
                            child: Card(
                              child: ListTile(
                                title: Text(entry.name),
                                subtitle: Text(
                                  '${entry.day} · ${entry.muscleGroup} · ${entry.sets} × ${entry.reps} · ${entry.weight} kg',
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EntryDetailScreen(entry: entry),
                                  ),
                                ),
                                trailing: IconButton(
                                  tooltip: 'Editar ejercicio',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () =>
                                      _showEntryDialog(entry: entry),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEntryDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar ejercicio'),
      ),
    );
  }
}
