import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistroDatosPage extends StatefulWidget {
  @override
  _RegistroDatosPageState createState() => _RegistroDatosPageState();
}

class _RegistroDatosPageState extends State<RegistroDatosPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  void _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Las contraseñas no coinciden')));
      return;
    }

    setState(() => _loading = true);

    try {
      // Crear usuario con email y contraseña
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _correoController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Aquí podrías guardar nombres y apellidos en Firestore o Realtime DB si quieres

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registro exitoso')));

      Navigator.of(context).pop(); // Volver a login o pantalla anterior
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Usuario')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombresController,
                decoration: InputDecoration(labelText: 'Nombres'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingrese nombres' : null,
              ),
              TextFormField(
                controller: _apellidosController,
                decoration: InputDecoration(labelText: 'Apellidos'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingrese apellidos' : null,
              ),
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Ingrese correo';
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!regex.hasMatch(val)) return 'Correo inválido';
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (val) => val == null || val.length < 6
                    ? 'Contraseña mínima 6 caracteres'
                    : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirmar Contraseña'),
                obscureText: true,
                validator: (val) => val == null || val.isEmpty
                    ? 'Confirme la contraseña'
                    : null,
              ),
              SizedBox(height: 20),
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registrar,
                      child: Text('Registrar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
