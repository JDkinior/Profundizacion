import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Necesario para BuildContext si lo usas para mostrar SnackBar

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para escuchar cambios de estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Registrarse con Email y Contraseña
  Future<UserCredential?> signUpWithEmailPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'La contraseña proporcionada es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        message = 'La cuenta ya existe para ese correo electrónico.';
      } else if (e.code == 'invalid-email') {
        message = 'El correo electrónico no es válido.';
      } else {
        message = 'Ocurrió un error de registro. Inténtalo de nuevo.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      print('Error de registro: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado.'), backgroundColor: Colors.red),
      );
      print('Error inesperado de registro: $e');
      return null;
    }
  }

  // Iniciar Sesión con Email y Contraseña
  Future<UserCredential?> signInWithEmailPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No se encontró ningún usuario para ese correo electrónico.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta proporcionada para ese usuario.';
      } else if (e.code == 'invalid-email') {
        message = 'El correo electrónico no es válido.';
      } else  if (e.code == 'INVALID_LOGIN_CREDENTIALS'){
         message = 'Credenciales de inicio de sesión inválidas.';
      }
      else {
        message = 'Ocurrió un error de inicio de sesión. Inténtalo de nuevo.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      print('Error de inicio de sesión: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado.'), backgroundColor: Colors.red),
      );
      print('Error inesperado de inicio de sesión: $e');
      return null;
    }
  }

  // Cerrar Sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Enviar correo de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo de restablecimiento de contraseña enviado. Revisa tu bandeja de entrada.'), backgroundColor: Colors.green),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No se encontró ningún usuario para ese correo electrónico.';
      } else if (e.code == 'invalid-email') {
        message = 'El correo electrónico no es válido.';
      } else {
        message = 'Error al enviar el correo de restablecimiento.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      print('Error al enviar correo de restablecimiento: ${e.code} - ${e.message}');
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado.'), backgroundColor: Colors.red),
      );
      print('Error inesperado al enviar correo de restablecimiento: $e');
    }
  }
}