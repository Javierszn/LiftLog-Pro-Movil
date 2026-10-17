import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registering = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
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
                    Icon(Icons.fitness_center, size: 54, color: colors.primary),
                    const SizedBox(height: 20),
                    Text(
                      _registering ? 'Crea tu cuenta' : 'Bienvenido a LiftLog Pro',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lleva el registro de tu entrenamiento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    if (_registering)
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Escribe tu nombre.' : null,
                      ),
                    if (_registering) const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo electrónico'),
                      validator: (value) => value == null || !value.contains('@') ? 'Escribe un correo válido.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      validator: (value) => value == null || value.length < 6 ? 'Usa al menos 6 caracteres.' : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _continue,
                      child: Text(_registering ? 'Crear cuenta de muestra' : 'Iniciar sesión de muestra'),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _registering = !_registering),
                      child: Text(_registering ? 'Ya tengo una cuenta' : 'Crear una cuenta'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Acceso de demostración. Las cuentas se guardarán cuando integremos la autenticación local.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
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