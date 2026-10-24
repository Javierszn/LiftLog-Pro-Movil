import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/lift_entry.dart';
import '../services/local_database.dart';
import 'access_screen.dart';
import 'first_review_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'training_plan_screen.dart';
import 'workout_session_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.user,
    required this.onThemeChanged,
  });

  final AppUser user;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late AppUser _user = widget.user;
  int _selectedTab = 0;
  List<int> _weeklyActivity = List<int>.filled(7, 0);
  List<LiftEntry> _todayExercises = [];
  bool _loading = true;

  static const List<String> _days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  String get _today => _days[DateTime.now().weekday - 1];
  int get _weekTotal => _weeklyActivity.where((count) => count > 0).length;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final database = LocalDatabase.instance;
    final activity = await database.getWeeklyActivity(_user.id);
    final exercises = await database.getExercises(_user.id, day: _today);
    if (!mounted) return;
    setState(() {
      _weeklyActivity = activity;
      _todayExercises = exercises;
      _loading = false;
    });
  }

  void _selectTab(int index) {
    setState(() => _selectedTab = index);
    if (index == 0) _loadSummary();
  }

  Future<void> _openPlan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrainingPlanScreen(userId: _user.id)),
    );
    if (mounted) _loadSummary();
  }

  void _startWorkout() {
    if (_todayExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega ejercicios a tu rutina para iniciar.'),
        ),
      );
      _selectTab(1);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSessionScreen(
          userId: _user.id,
          routineName: _today,
          exercises: _todayExercises,
        ),
      ),
    ).then((_) {
      if (mounted) _loadSummary();
    });
  }

  Future<void> _logout() async {
    await LocalDatabase.instance.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => AccessScreen(onThemeChanged: widget.onThemeChanged),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['LiftLog Pro', 'Mis rutinas', 'Progreso', 'Perfil'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedTab]),
        actions: _selectedTab == 0
            ? [
                IconButton(
                  tooltip: 'Mi perfil',
                  onPressed: () => _selectTab(3),
                  icon: const Icon(Icons.person_outline),
                ),
              ]
            : null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: IndexedStack(
            index: _selectedTab,
            children: [
              _DashboardHome(
                user: _user,
                activity: _weeklyActivity,
                weekTotal: _weekTotal,
                today: _today,
                todayExercises: _todayExercises,
                loading: _loading,
                onStart: _startWorkout,
                onPlan: _openPlan,
                onRoutines: () => _selectTab(1),
              ),
              FirstReviewScreen(userId: _user.id, showAppBar: false),
              ProgressScreen(userId: _user.id, showAppBar: false),
              ProfileScreen(
                user: _user,
                onThemeChanged: widget.onThemeChanged,
                onLogout: _logout,
                onUserChanged: (user) => setState(() => _user = user),
                showAppBar: false,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Rutinas',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Progreso',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({
    required this.user,
    required this.activity,
    required this.weekTotal,
    required this.today,
    required this.todayExercises,
    required this.loading,
    required this.onStart,
    required this.onPlan,
    required this.onRoutines,
  });

  final AppUser user;
  final List<int> activity;
  final int weekTotal;
  final String today;
  final List<LiftEntry> todayExercises;
  final bool loading;
  final VoidCallback onStart;
  final VoidCallback onPlan;
  final VoidCallback onRoutines;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = (weekTotal / user.weeklyGoal).clamp(0.0, 1.0).toDouble();
    final firstName = user.name.trim().split(' ').first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(
          'Hola, $firstName',
          style: textTheme.titleMedium?.copyWith(color: colors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          'Tu entrenamiento',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: colors.primary,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'RUTINA DE HOY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  today,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  loading
                      ? 'Cargando tus ejercicios…'
                      : '${todayExercises.length} ejercicios en tu rutina',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (todayExercises.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...todayExercises
                      .take(2)
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• ${entry.name}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  if (todayExercises.length > 2)
                    Text(
                      'y ${todayExercises.length - 2} más',
                      style: const TextStyle(color: Colors.white70),
                    ),
                ],
                const SizedBox(height: 18),
                FilledButton.tonalIcon(
                  onPressed: loading ? null : onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar entrenamiento'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Esta semana',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$weekTotal / ${user.weeklyGoal} días',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 18),
                _WeeklyChart(values: activity),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickCard(
                icon: Icons.calendar_month_outlined,
                label: 'Plan semanal',
                onTap: onPlan,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickCard(
                icon: Icons.fitness_center,
                label: 'Editar rutinas',
                onTap: onRoutines,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final largest = values.fold<int>(
      1,
      (current, value) => value > current ? value : current,
    );
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return SizedBox(
      height: 108,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final height = values[index] == 0
              ? 8.0
              : 18 + 54 * values[index] / largest;
          final weekday =
              DateTime.now().subtract(Duration(days: 6 - index)).weekday - 1;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${values[index]}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 5),
                Container(
                  height: height,
                  width: 20,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  labels[weekday],
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
