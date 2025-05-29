import 'package:flutter/material.dart';
import 'package:minitas/auth_service.dart';
import 'package:minitas/profile_screen.dart';
import 'package:minitas/casino_screen.dart';
import 'package:minitas/football_bet_screen.dart';
import 'package:minitas/basketball_bet_screen.dart';
import 'package:minitas/tennis_bet_screen.dart';


class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser; // Obtener el usuario actual

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minitas Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, 
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: <Widget>[
            if (user != null) 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Bienvenido, ${user.email ?? 'Usuario'}!',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Juegos y Apuestas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildGameButton(
              context,
              title: 'Casino (Buscaminas)',
              icon: Icons.casino,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CasinoScreen()),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildGameButton(
              context,
              title: 'Apuestas de Fútbol',
              icon: Icons.sports_soccer,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FootballBetScreen()),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildGameButton(
              context,
              title: 'Apuestas de Baloncesto',
              icon: Icons.sports_basketball,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BasketballBetScreen()),
                );
              },
            ),
            const SizedBox(height: 15),
             _buildGameButton(
              context,
              title: 'Apuestas de Tenis',
              icon: Icons.sports_tennis,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TennisBetScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(BuildContext context, {required String title, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(title),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}