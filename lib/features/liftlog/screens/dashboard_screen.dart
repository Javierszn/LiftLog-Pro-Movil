import 'package:flutter/material.dart';
import 'first_review_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LiftLog Pro'),
        actions: [
          IconButton(
            tooltip: 'Mi perfil',
            onPressed: () => _openScreen(context, const ProfileScreen()),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Tu entrenamiento, en orden', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Elige una sección para continuar.', style: TextStyle(color: colors.onSurfaceVariant)),
              const SizedBox(height: 24),
              Card(
                color: colors.primaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.fitness_center, size: 34),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Constancia antes que prisa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Registra tus ejercicios y revisa tu avance.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.view_list_outlined),
                  title: const Text('Mis ejercicios'),
                  subtitle: const Text('Agregar, consultar, editar y eliminar'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openScreen(context, const FirstReviewScreen()),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Progreso visual'),
                  subtitle: const Text('Sección preparada para el registro con cámara'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openScreen(context, const ProgressScreen()),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('Perfil y ajustes'),
                  subtitle: const Text('Configurar una meta semanal'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openScreen(context, const ProfileScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}