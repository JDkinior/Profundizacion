import 'dart:math';

class MinesweeperGame {
  final int gridSize;
  final int mineCount;
  late List<List<Cell>> grid;
  late Set<Point<int>> mines;
  bool gameOver = false;
  bool gameWon = false;
  int points = 0;

  MinesweeperGame({this.gridSize = 8, this.mineCount = 10}) {
    _initializeGrid();
  }

  void _initializeGrid() {
    grid = List.generate(
      gridSize,
      (i) => List.generate(
        gridSize,
        (j) => Cell(),
        growable: false,
      ),
    );
    mines = {};
  }

  void startNewGame(Point<int> firstClick) {
    gameOver = false;
    gameWon = false;
    points = 0;
    _placeMines(firstClick);
    _calculateNumbers();
  }

  void _placeMines(Point<int> safePoint) {
    final random = Random();
    mines.clear();

    while (mines.length < mineCount) {
      final x = random.nextInt(gridSize);
      final y = random.nextInt(gridSize);
      final point = Point(x, y);

      if (point != safePoint && !mines.contains(point)) {
        mines.add(point);
      }
    }
  }

  void _calculateNumbers() {
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final currentPoint = Point(x, y);
        if (!isMine(currentPoint)) {
          grid[x][y].adjacentMines = _countAdjacentMines(currentPoint);
        }
      }
    }
  }

  int _countAdjacentMines(Point<int> point) {
    int count = 0;
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        final nx = point.x + dx;
        final ny = point.y + dy;
        if (nx >= 0 && nx < gridSize && ny >= 0 && ny < gridSize) {
          if (isMine(Point(nx, ny))) {
            count++;
          }
        }
      }
    }
    return count;
  }

  bool isMine(Point<int> point) => mines.contains(point);

  void revealCell(Point<int> point) {
    if (gameOver || grid[point.x][point.y].revealed) return;

    grid[point.x][point.y].revealed = true;

    if (isMine(point)) {
      gameOver = true;
      points -= 100;
      _revealAllMines();
    } else {
      points += 10;
      if (grid[point.x][point.y].adjacentMines == 0) {
        _revealAdjacentCells(point);
      }
      _checkWin();
    }
  }

  void _revealAdjacentCells(Point<int> point) {
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        final nx = point.x + dx;
        final ny = point.y + dy;
        if (nx >= 0 && nx < gridSize && ny >= 0 && ny < gridSize) {
          revealCell(Point(nx, ny));
        }
      }
    }
  }

  void _revealAllMines() {
    for (final mine in mines) {
      grid[mine.x][mine.y].revealed = true;
    }
  }

  void _checkWin() {
    int unrevealedSafeCells = 0;
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        if (!grid[x][y].revealed && !isMine(Point(x, y))) {
          unrevealedSafeCells++;
        }
      }
    }
    gameWon = unrevealedSafeCells == 0;
    if (gameWon) points += 500;
  }
}

class Cell {
  bool revealed = false;
  int adjacentMines = 0;
}
