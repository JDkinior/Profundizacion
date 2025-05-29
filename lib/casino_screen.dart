import 'dart:math';

import 'package:flutter/material.dart';
import 'games/minesweeper_game.dart';

class CasinoScreen extends StatefulWidget {
  const CasinoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CasinoScreenState createState() => _CasinoScreenState();
}

class _CasinoScreenState extends State<CasinoScreen> {
  late MinesweeperGame game;
  final int gridSize = 8;

  @override
  void initState() {
    super.initState();
    game = MinesweeperGame();
  }

  void _startNewGame() {
    setState(() {
      game = MinesweeperGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Casino - Buscaminas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Puntos: ${game.points}', style: const TextStyle(fontSize: 20)),
                _buildGameStatus(),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    final x = index ~/ gridSize;
                    final y = index % gridSize;
                    return _buildCell(x, y);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int x, int y) {
    final cell = game.grid[x][y];
    final isMine = game.isMine(Point(x, y));

    return GestureDetector(
      onTap: () => _handleTap(x, y),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: cell.revealed
              ? (isMine ? Colors.red : Colors.grey[200])
              : Colors.blue,
        ),
        child: Center(
          child: cell.revealed
              ? isMine
                  ? const Icon(Icons.warning, color: Colors.black)
                  : Text(
                      cell.adjacentMines > 0 ? '${cell.adjacentMines}' : '',
                      style: TextStyle(
                        fontSize: 20,
                        color: _getNumberColor(cell.adjacentMines),
                      ),
                    )
              : null,
        ),
      ),
    );
  }

  void _handleTap(int x, int y) {
    if (!game.gameOver && !game.gameWon) {
      if (!game.grid[x][y].revealed) {
        if (game.mines.isEmpty) game.startNewGame(Point(x, y));

        setState(() {
          game.revealCell(Point(x, y));
        });
      }
    }
  }

  Color _getNumberColor(int number) {
    switch (number) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  Widget _buildGameStatus() {
    if (game.gameOver) {
      return const Text('¡Perdiste!',
          style: TextStyle(color: Colors.red, fontSize: 20));
    }
    if (game.gameWon) {
      return const Text('¡Ganaste!',
          style: TextStyle(color: Colors.green, fontSize: 20));
    }
    return const Text('Jugando...',
        style: TextStyle(color: Colors.blue, fontSize: 20));
  }
}
