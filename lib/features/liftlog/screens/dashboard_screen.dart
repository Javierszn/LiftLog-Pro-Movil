import 'package:flutter/material.dart';
import 'first_review_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'training_plan_screen.dart';
import 'workout_session_screen.dart';

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
              Text('Hola, atleta', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.primary)),
              const SizedBox(height: 4),
              Text('¿Listo para entrenar?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Card(
                color: colors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [Icon(Icons.bolt, color: Colors.white), SizedBox(width: 8), Text('ENTRENAMIENTO DE HOY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1))]),
                    const SizedBox(height: 12),
                    Text('Día de fuerza', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text('Una sesión a la vez. Registra cada serie y sigue tu plan.', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 18),
                    FilledButton.tonalIcon(onPressed: () => _openScreen(context, const WorkoutSessionScreen()), icon: const Icon(Icons.play_arrow), label: const Text('Iniciar sesión')),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Card(child: ListTile(leading: const Icon(Icons.calendar_month_outlined), title: const Text('Plan semanal'), subtitle: const Text('Organiza tus días'), onTap: () => _openScreen(context, const TrainingPlanScreen())))),
                const SizedBox(width: 8),
                Expanded(child: Card(child: ListTile(leading: const Icon(Icons.trending_up), title: const Text('Progreso'), subtitle: const Text('Consulta tus mediciones'), onTap: () => _openScreen(context, const ProgressScreen())))),
              ]),
              const SizedBox(height: 16),
              Text('Tus herramientas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.view_list_outlined),
                  title: const Text('Mis ejercicios'),
                  subtitle: const Text('Agregar, consultar, editar y eliminar'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openScreen(context, const FirstReviewScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
