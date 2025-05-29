// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:minitas/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  final TextEditingController _emailController = TextEditingController(); 
  final TextEditingController _currentPasswordController = TextEditingController(); 
  final TextEditingController _newPasswordController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      _emailController.text = _currentUser!.email ?? '';
    }
  }

  Future<void> _updateEmail() async {
    if (_currentUser == null || _emailController.text.trim().isEmpty || _emailController.text.trim() == _currentUser!.email) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un nuevo correo electrónico válido.'), backgroundColor: Colors.orange));
      return;
    }
    try {
      await _currentUser!.verifyBeforeUpdateEmail(_emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo de verificación enviado a ${_emailController.text.trim()}. Por favor verifica para actualizar.'), backgroundColor: Colors.green)
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar correo: ${e.message}'), backgroundColor: Colors.red));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error inesperado.'), backgroundColor: Colors.red));
    }
  }

  Future<void> _changePassword() async {
    if (_currentUser == null || _newPasswordController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa la nueva contraseña.'), backgroundColor: Colors.orange));
      return;
    }
    if (_newPasswordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La nueva contraseña debe tener al menos 6 caracteres.'), backgroundColor: Colors.orange));
      return;
    }

    try {
      await _currentUser!.updatePassword(_newPasswordController.text.trim());
      _newPasswordController.clear();
      _currentPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada exitosamente.'), backgroundColor: Colors.green)
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esta operación es sensible y requiere autenticación reciente. Por favor, inicia sesión de nuevo e inténtalo.'), backgroundColor: Colors.orange, duration: Duration(seconds: 5))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cambiar contraseña: ${e.message}'), backgroundColor: Colors.red));
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error inesperado.'), backgroundColor: Colors.red));
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { 
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Información del Usuario', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Correo Electrónico'),
                  subtitle: Text(_currentUser!.email ?? 'No disponible'),
                ),
              ),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Correo Verificado'),
                  subtitle: Text(_currentUser!.emailVerified ? 'Sí' : 'No'),
                  trailing: !_currentUser!.emailVerified
                      ? TextButton(
                          onPressed: () async {
                            await _currentUser!.sendEmailVerification();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Correo de verificación enviado.'), backgroundColor: Colors.blue),
                            );
                          },
                          child: const Text('Verificar ahora'),
                        )
                      : null,
                ),
              ),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.perm_identity),
                  title: const Text('UID'),
                  subtitle: Text(_currentUser!.uid),
                ),
              ),
              const SizedBox(height: 30),

              Text('Actualizar Correo', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Nuevo Correo Electrónico', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _updateEmail,
                child: const Text('Enviar verificación para actualizar correo'),
              ),
              const SizedBox(height: 30),

              Text('Cambiar Contraseña', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'Nueva Contraseña', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Cambiar Contraseña'),
              ),

              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () async {
                    await _authService.signOut();
                  },
                  child: const Text('Cerrar Sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
