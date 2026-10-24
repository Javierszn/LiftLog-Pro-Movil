import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/local_database.dart';
import 'dashboard_screen.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key, required this.onThemeChanged});

  final ValueChanged<bool> onThemeChanged;

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registering = false;
  bool _working = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final user = await LocalDatabase.instance.currentUser();
    if (user != null && mounted) _openDashboard(user);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _openDashboard(AppUser user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DashboardScreen(user: user, onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _working = true);
    try {
      final database = LocalDatabase.instance;
      final AppUser? user = _registering
          ? await database.registerUser(
              _nameController.text,
              _emailController.text,
              _passwordController.text,
            )
          : await database.loginUser(
              _emailController.text,
              _passwordController.text,
            );
      if (!mounted) return;
      if (user == null) {
        _showMessage(
          _registering
              ? 'Ese correo ya está registrado.'
              : 'Correo o contraseña incorrectos.',
        );
        return;
      }
      _openDashboard(user);
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo abrir tu cuenta. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      _registering
                          ? 'Crea tu cuenta'
                          : 'Bienvenido a LiftLog Pro',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Organiza tus rutinas y registra tu evolución.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    if (_registering) ...[
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Escribe tu nombre.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: (value) =>
                          value == null ||
                              !RegExp(r'^.+@.+\..+$').hasMatch(value.trim())
                          ? 'Escribe un correo válido.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _showPassword
                              ? 'Ocultar contraseña'
                              : 'Mostrar contraseña',
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 6
                          ? 'Usa al menos 6 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _working ? null : _continue,
                      child: _working
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _registering ? 'Crear cuenta' : 'Iniciar sesión',
                            ),
                    ),
                    TextButton(
                      onPressed: _working
                          ? null
                          : () => setState(() => _registering = !_registering),
                      child: Text(
                        _registering
                            ? 'Ya tengo una cuenta'
                            : 'Crear una cuenta',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
