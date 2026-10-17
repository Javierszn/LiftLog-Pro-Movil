import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _weeklyGoal = 4;
  final List<int> _goalOptions = [2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil y ajustes')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const CircleAvatar(radius: 38, child: Icon(Icons.person_outline, size: 42)),
              const SizedBox(height: 12),
              Text('Atleta LiftLog', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 28),
              Card(
                child: ListTile(
                  title: const Text('Meta semanal'),
                  subtitle: Text('$_weeklyGoal días de entrenamiento por semana'),
                  trailing: DropdownButton<int>(
                    value: _weeklyGoal,
                    items: _goalOptions.map((goal) => DropdownMenuItem(value: goal, child: Text('$goal'))).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _weeklyGoal = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'La meta se conserva durante esta sesión. El guardado de preferencias se añadirá con la persistencia de datos.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}