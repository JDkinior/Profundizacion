import 'package:flutter/material.dart';
import 'auth_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Email: ${AuthService.currentUserEmail ?? "No autenticado"}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Eliminar Cuenta'),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar tu cuenta permanentemente?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              final success = await AuthService.deleteAccount();
              Navigator.pop(context);

              if (success && context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cuenta eliminada exitosamente')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar la cuenta')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
