import 'package:flutter/material.dart';
import 'package:minitas/basketball_bet_screen.dart';
import 'package:minitas/football_bet_screen.dart';
import 'auth_service.dart';
import 'casino_screen.dart';
import 'tennis_bet_screen.dart'; // Asegúrate de tener este archivo

class HomeScreen extends StatelessWidget {
  final List<Game> games = [
    Game(
      id: 1,
      name: 'Fútbol',
      icon: Icons.sports_soccer,
      color: Colors.green,
      screen: FootballBetScreen(), // Pantalla temporal
    ),
    Game(
      id: 2,
      name: 'Básquetbol',
      icon: Icons.sports_basketball,
      color: Colors.orange,
      screen: BasketballBetScreen(),
    ),
    Game(
      id: 3,
      name: 'Tenis',
      icon: Icons.sports_tennis,
      color: Colors.blue,
      screen: TennisBetScreen(),
    ),
    Game(
      id: 4,
      name: 'Casino',
      icon: Icons.casino,
      color: Colors.purple,
      screen: CasinoScreen(), // Pantalla del Buscaminas
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apuestas Deportivas'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return _buildGameCard(games[index], context);
          },
        ),
      ),
    );
  }

  Widget _buildGameCard(Game game, BuildContext context) {
    return Card(
      elevation: 4,
      color: game.color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _navigateToGame(context, game),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(game.icon, size: 50, color: game.color),
            SizedBox(height: 10),
            Text(
              game.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: game.color,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Apuestas disponibles',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => game.screen),
    );
  }
}

class Game {
  final int id;
  final String name;
  final IconData icon;
  final Color color;
  final Widget screen;

  Game({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.screen,
  });
}

// Pantalla temporal para los otros juegos
class PlaceholderScreen extends StatelessWidget {
  final String gameName;

  const PlaceholderScreen({Key? key, required this.gameName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Próximamente...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Sección en desarrollo',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
