import 'package:flutter/material.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final List<_ProgressRecord> _records = [];

  Future<void> _addRecord() async {
    final controller = TextEditingController();
    final weight = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Registrar peso'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Peso en kg', suffixText: 'kg'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.replaceAll(',', '.'));
              if (value != null && value > 0) Navigator.pop(dialogContext, value);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (weight != null && mounted) {
      setState(() => _records.insert(0, _ProgressRecord(weight: weight, date: DateTime.now())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final latest = _records.isEmpty ? null : _records.first;
    final previous = _records.length < 2 ? null : _records[1];
    final difference = latest != null && previous != null ? latest.weight - previous.weight : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi progreso')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        icon: const Icon(Icons.add),
        label: const Text('Registrar peso'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              Text('Tu evolución', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Lleva un registro de tus mediciones.', style: TextStyle(color: colors.onSurfaceVariant)),
              const SizedBox(height: 20),
              Card(
                color: colors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    CircleAvatar(radius: 26, backgroundColor: colors.surface, child: Icon(Icons.monitor_weight_outlined, color: colors.primary)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Último registro'),
                      const SizedBox(height: 4),
                      Text(latest == null ? 'Agrega tu primera medición' : '${latest.weight.toStringAsFixed(1)} kg', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ])),
                    if (difference != null)
                      Text('${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)} kg', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              Text('Historial', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_records.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    child: Column(children: [
                      Icon(Icons.show_chart, size: 44, color: colors.primary),
                      const SizedBox(height: 10),
                      const Text('Aún no tienes mediciones.'),
                      const SizedBox(height: 4),
                      const Text('Usa “Registrar peso” para comenzar.', textAlign: TextAlign.center),
                    ]),
                  ),
                )
              else
                ..._records.map((record) => Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: colors.secondaryContainer, child: Icon(Icons.monitor_weight_outlined, color: colors.onSecondaryContainer)),
                    title: Text('${record.weight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${record.date.day}/${record.date.month}/${record.date.year}'),
                    trailing: IconButton(
                      tooltip: 'Eliminar registro',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _records.remove(record)),
                    ),
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRecord {
  const _ProgressRecord({required this.weight, required this.date});

  final double weight;
  final DateTime date;
}
