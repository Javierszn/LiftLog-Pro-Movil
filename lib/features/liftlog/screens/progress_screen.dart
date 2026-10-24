import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/local_database.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({
    super.key,
    required this.userId,
    this.showAppBar = true,
  });

  final int userId;
  final bool showAppBar;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  List<Map<String, Object?>> _records = [];
  List<Map<String, Object?>> _photos = [];
  List<Map<String, Object?>> _liftHistory = [];
  bool _loading = true;
  bool _addingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final database = LocalDatabase.instance;
    final records = await database.getWeightRecords(widget.userId);
    final photos = await database.getProgressPhotos(widget.userId);
    final liftHistory = await database.getLiftHistory(widget.userId);
    if (!mounted) return;
    setState(() {
      _records = records;
      _photos = photos;
      _liftHistory = liftHistory;
      _loading = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addWeight() async {
    final controller = TextEditingController();
    final weight = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Registrar peso'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Peso corporal',
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );
              if (value != null && value > 0) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (weight == null) return;
    await LocalDatabase.instance.addWeightRecord(widget.userId, weight);
    await _loadProgress();
    if (mounted) _showMessage('Medición guardada.');
  }

  Future<void> _takePhoto() async {
    setState(() => _addingPhoto = true);
    try {
      final photo = await _imagePicker.pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (photo == null) return;
      final Uint8List bytes = await photo.readAsBytes();
      await LocalDatabase.instance.addProgressPhoto(widget.userId, bytes);
      await _loadProgress();
      if (mounted) _showMessage('Foto guardada en tu progreso.');
    } catch (_) {
      if (mounted) {
        _showMessage(
          'No se pudo acceder a la imagen. Revisa el permiso de cámara.',
        );
      }
    } finally {
      if (mounted) setState(() => _addingPhoto = false);
    }
  }

  Future<void> _deleteWeight(Map<String, Object?> record) async {
    final id = record['id'] as int?;
    if (id == null) return;
    await LocalDatabase.instance.deleteWeightRecord(widget.userId, id);
    await _loadProgress();
  }

  Future<void> _deletePhoto(Map<String, Object?> photo) async {
    final id = photo['id'] as int?;
    if (id == null) return;
    await LocalDatabase.instance.deleteProgressPhoto(widget.userId, id);
    await _loadProgress();
  }

  String _formatDate(Object? value) {
    final date = DateTime.parse(value as String);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final latest = _records.isEmpty ? null : _records.first;
    final previous = _records.length < 2 ? null : _records[1];
    final latestWeight = latest == null
        ? null
        : (latest['weight'] as num).toDouble();
    final previousWeight = previous == null
        ? null
        : (previous['weight'] as num).toDouble();
    final difference = latestWeight != null && previousWeight != null
        ? latestWeight - previousWeight
        : null;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Mi progreso'))
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  children: [
                    Text(
                      'Tu evolución',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Guarda tus mediciones y fotos de entrenamiento.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      color: colors.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: colors.surface,
                              child: Icon(
                                Icons.monitor_weight_outlined,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Último registro'),
                                  const SizedBox(height: 4),
                                  Text(
                                    latestWeight == null
                                        ? 'Sin mediciones'
                                        : '${latestWeight.toStringAsFixed(1)} kg',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (latest != null)
                                    Text(_formatDate(latest['recorded_at'])),
                                ],
                              ),
                            ),
                            if (difference != null)
                              Text(
                                '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)} kg',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: _addWeight,
                          icon: const Icon(Icons.add),
                          label: const Text('Registrar peso'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _addingPhoto ? null : _takePhoto,
                          icon: _addingPhoto
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add_a_photo_outlined),
                          label: Text(kIsWeb ? 'Agregar foto' : 'Tomar foto'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Mediciones',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_records.isEmpty)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.show_chart),
                          title: Text('Todavía no hay mediciones'),
                          subtitle: Text(
                            'Registra tu peso para iniciar el historial.',
                          ),
                        ),
                      )
                    else
                      ..._records.map(
                        (record) => Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colors.secondaryContainer,
                              child: Icon(
                                Icons.monitor_weight_outlined,
                                color: colors.onSecondaryContainer,
                              ),
                            ),
                            title: Text(
                              '${(record['weight'] as num).toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(_formatDate(record['recorded_at'])),
                            trailing: IconButton(
                              tooltip: 'Eliminar medición',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteWeight(record),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 22),
                    Text(
                      'Historial de levantamientos',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_liftHistory.isEmpty)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.history),
                          title: Text('Todavía no hay sesiones'),
                          subtitle: Text(
                            'Completa una rutina para guardar tus levantamientos.',
                          ),
                        ),
                      )
                    else
                      ..._liftHistory
                          .take(12)
                          .map(
                            (lift) => Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: colors.secondaryContainer,
                                  child: Icon(
                                    Icons.fitness_center,
                                    color: colors.onSecondaryContainer,
                                  ),
                                ),
                                title: Text(
                                  lift['exercise_name'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${lift['routine_name']} · ${lift['sets']} × ${lift['reps']} · ${_formatDate(lift['completed_at'])}',
                                ),
                                trailing: Text(
                                  '${(lift['weight'] as num).toStringAsFixed(1)} kg',
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 22),
                    Text(
                      'Fotos de progreso',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_photos.isEmpty)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.photo_camera_outlined),
                          title: Text('Todavía no hay fotos'),
                          subtitle: Text(
                            'Las fotos que agregues aparecerán aquí.',
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _photos.length,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 180,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemBuilder: (context, index) {
                          final photo = _photos[index];
                          final bytes = photo['image_bytes'] as Uint8List;
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                InkWell(
                                  onTap: () => showDialog<void>(
                                    context: context,
                                    builder: (_) => Dialog(
                                      child: Image.memory(
                                        bytes,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  child: Image.memory(bytes, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  left: 6,
                                  bottom: 6,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: colors.surface.withValues(
                                        alpha: 0.85,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        _formatDate(photo['captured_at']),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton.filledTonal(
                                    tooltip: 'Eliminar foto',
                                    onPressed: () => _deletePhoto(photo),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
