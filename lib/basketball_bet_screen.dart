import 'package:flutter/material.dart';

class BasketballBetScreen extends StatefulWidget {
  const BasketballBetScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BasketballBetScreenState createState() => _BasketballBetScreenState();
}

class _BasketballBetScreenState extends State<BasketballBetScreen> {
  final List<Map<String, dynamic>> matches = [
    {
      'teams': ['Lakers', 'Warriors'],
      'league': 'NBA',
      'date': 'Vie 14 Jun, 20:30',
      'odds': {
        '1': 1.9,
        '2': 2.1,
        '1_5+': 3.2,
        '2_5+': 3.0,
        'over_220': 1.8,
        'under_220': 1.9
      }
    },
    {
      'teams': ['Barcelona', 'Real Madrid'],
      'league': 'EuroLeague',
      'date': 'Sáb 15 Jun, 19:00',
      'odds': {
        '1': 2.3,
        '2': 1.8,
        '1_10+': 4.5,
        '2_10+': 3.8,
        'over_180': 2.0,
        'under_180': 1.8
      }
    },
  ];

  Map<String, dynamic>? selectedMatch;
  String? selectedBetType;
  double betAmount = 0.0;
  final Map<String, String> betCategories = {
    'winner': 'Ganador del Partido',
    'spread': 'Margen de Victoria',
    'total': 'Total de Puntos'
  };
  String currentCategory = 'winner';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apuestas de Baloncesto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMatchSelector(),
            const SizedBox(height: 20),
            _buildCategorySelector(),
            const SizedBox(height: 20),
            if (selectedMatch != null) _buildBettingPanel(),
            if (selectedMatch != null) _buildBetForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchSelector() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      decoration: const InputDecoration(
        labelText: 'Seleccionar Partido',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.sports_basketball),
      ),
      items: matches.map((match) {
        return DropdownMenuItem(
          value: match,
          child: Text(
              '${match['teams'][0]} vs ${match['teams'][1]} - ${match['league']}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedMatch = value;
          selectedBetType = null;
          betAmount = 0.0;
        });
      },
    );
  }

  Widget _buildCategorySelector() {
    return SegmentedButton<String>(
      segments: betCategories.entries.map((entry) {
        return ButtonSegment(
          value: entry.key,
          label: Text(entry.value),
        );
      }).toList(),
      selected: {currentCategory},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          currentCategory = newSelection.first;
          selectedBetType = null;
        });
      },
    );
  }

  Widget _buildBettingPanel() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${selectedMatch!['teams'][0]} vs ${selectedMatch!['teams'][1]}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('${selectedMatch!['league']} - ${selectedMatch!['date']}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            _buildOddsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildOddsGrid() {
    final Map<String, double> odds = selectedMatch!['odds'];
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: _getCurrentCategoryOdds(odds).entries.map((entry) {
        return _buildOddCard(entry.key, entry.value.toString());
      }).toList(),
    );
  }

  Map<String, double> _getCurrentCategoryOdds(Map<String, double> odds) {
    switch (currentCategory) {
      case 'winner':
        return {'1': odds['1']!, '2': odds['2']!};
      case 'spread':
        return {
          '${selectedMatch!['teams'][0]} +5': odds['1_5+']!,
          '${selectedMatch!['teams'][1]} +5': odds['2_5+']!,
        };
      case 'total':
        return {
          'Over ${_getTotalPoints()}': odds['over_${_getTotalPoints()}']!,
          'Under ${_getTotalPoints()}': odds['under_${_getTotalPoints()}']!,
        };
      default:
        return {};
    }
  }

  int _getTotalPoints() {
    return selectedMatch!['league'] == 'NBA' ? 220 : 180;
  }

  Widget _buildOddCard(String label, String odd) {
    return GestureDetector(
      onTap: () => setState(() => selectedBetType = label),
      child: Container(
        decoration: BoxDecoration(
          color: selectedBetType == label ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedBetType == label ? Colors.blue : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Text(odd,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBetForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad a apostar',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  betAmount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.sports_basketball),
              label: const Text('Confirmar Apuesta'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: (betAmount > 0 && selectedBetType != null)
                  ? () => _showBetConfirmation()
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showBetConfirmation() {
    final odd = _getSelectedOdd();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Apuesta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Partido: ${selectedMatch!['teams'][0]} vs ${selectedMatch!['teams'][1]}'),
            Text('Categoría: ${betCategories[currentCategory]}'),
            Text('Selección: $selectedBetType'),
            Text('Cuota: ${odd}x'),
            Text('Cantidad: \$${betAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            Text(
                'Ganancia potencial: \$${(betAmount * odd).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Apostar'),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Apuesta en baloncesto realizada!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  double _getSelectedOdd() {
    final categoryOdds = _getCurrentCategoryOdds(selectedMatch!['odds']);
    return categoryOdds[selectedBetType]!;
  }
}
