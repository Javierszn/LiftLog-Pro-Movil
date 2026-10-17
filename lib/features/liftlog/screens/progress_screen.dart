import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progreso visual')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera_outlined, size: 72, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 20),
                Text('Tu evolución, paso a paso', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                const Text(
                  'Aquí se podrán guardar fotografías para comparar tu progreso. La conexión con la cámara se agregará en una siguiente etapa.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('La cámara se integrará en la siguiente etapa.')),
                    );
                  },
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Agregar fotografía'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}