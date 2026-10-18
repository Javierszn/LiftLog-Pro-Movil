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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil y ajustes')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CircleAvatar(radius: 42, backgroundColor: colors.primaryContainer, child: Icon(Icons.person_outline, size: 46, color: colors.onPrimaryContainer)),
              const SizedBox(height: 12),
              Text('Atleta LiftLog', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 28),
              Text('Preferencias', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Meta semanal'),
                  subtitle: Text('$_weeklyGoal días de entrenamiento'),
                  trailing: DropdownButton<int>(
                    value: _weeklyGoal,
                    items: _goalOptions.map((goal) => DropdownMenuItem(value: goal, child: Text('$goal'))).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _weeklyGoal = value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
