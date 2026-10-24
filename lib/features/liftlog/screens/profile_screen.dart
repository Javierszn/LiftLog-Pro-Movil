import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/local_database.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.onThemeChanged,
    required this.onLogout,
    required this.onUserChanged,
    this.showAppBar = true,
  });

  final AppUser user;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLogout;
  final ValueChanged<AppUser> onUserChanged;
  final bool showAppBar;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AppUser _user = widget.user;
  final List<int> _goalOptions = [2, 3, 4, 5, 6];
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final darkMode = await LocalDatabase.instance.isDarkMode();
    if (mounted) setState(() => _darkMode = darkMode);
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _user.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName.isEmpty) return;
    final updatedUser = _user.copyWith(name: newName);
    await LocalDatabase.instance.updateUser(updatedUser);
    if (!mounted) return;
    setState(() => _user = updatedUser);
    widget.onUserChanged(updatedUser);
  }

  Future<void> _changeGoal(int? goal) async {
    if (goal == null) return;
    final updatedUser = _user.copyWith(weeklyGoal: goal);
    await LocalDatabase.instance.updateUser(updatedUser);
    if (!mounted) return;
    setState(() => _user = updatedUser);
    widget.onUserChanged(updatedUser);
  }

  Future<void> _changeTheme(bool enabled) async {
    setState(() => _darkMode = enabled);
    await LocalDatabase.instance.setDarkMode(enabled);
    widget.onThemeChanged(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Perfil y ajustes'))
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  _user.name.isEmpty ? '?' : _user.name[0].toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: colors.onPrimaryContainer),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _user.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                _user.email,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _editName,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar nombre'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Preferencias',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Meta semanal'),
                  subtitle: Text('${_user.weeklyGoal} días de entrenamiento'),
                  trailing: DropdownButton<int>(
                    value: _user.weeklyGoal,
                    items: _goalOptions
                        .map(
                          (goal) => DropdownMenuItem(
                            value: goal,
                            child: Text('$goal'),
                          ),
                        )
                        .toList(),
                    onChanged: _changeGoal,
                  ),
                ),
              ),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Modo oscuro'),
                  value: _darkMode,
                  onChanged: _changeTheme,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
