import 'package:flutter/material.dart';

class FootballBetScreen extends StatefulWidget {
  const FootballBetScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FootballBetScreenState createState() => _FootballBetScreenState();
}

class _FootballBetScreenState extends State<FootballBetScreen> {
  final List<Map<String, dynamic>> matches = [
    {
      'teams': ['Real Madrid', 'Barcelona'],
      'date': 'Sáb 15 Jun, 20:00',
      'odds': {'1': 2.1, 'X': 3.0, '2': 2.8}
    },
    {
      'teams': ['Bayern Munich', 'Dortmund'],
      'date': 'Dom 16 Jun, 18:30',
      'odds': {'1': 1.8, 'X': 3.2, '2': 4.0}
    },
    {
      'teams': ['Liverpool', 'Manchester City'],
      'date': 'Lun 17 Jun, 21:00',
      'odds': {'1': 2.5, 'X': 3.1, '2': 2.6}
    },
  ];

  Map<String, dynamic>? selectedMatch;
  String? selectedOutcome;
  double betAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apuestas de Fútbol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMatchSelector(),
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
      ),
      items: matches.map((match) {
        return DropdownMenuItem(
          value: match,
          child: Text(
              '${match['teams'][0]} vs ${match['teams'][1]} - ${match['date']}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedMatch = value;
          selectedOutcome = null;
          betAmount = 0.0;
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
            Text(selectedMatch!['date'], style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOddButton('1', '${selectedMatch!['odds']['1']}'),
                _buildOddButton('X', '${selectedMatch!['odds']['X']}'),
                _buildOddButton('2', '${selectedMatch!['odds']['2']}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOddButton(String outcome, String odd) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedOutcome == outcome ? Colors.blue : Colors.grey[200],
        foregroundColor:
            selectedOutcome == outcome ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedOutcome = outcome;
        });
      },
      child: Column(
        children: [
          Text(outcome, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 5),
          Text(odd, style: const TextStyle(fontSize: 16)),
        ],
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
              icon: const Icon(Icons.sports_soccer),
              label: const Text('Confirmar Apuesta'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: betAmount > 0 && selectedOutcome != null
                  ? () => _showBetConfirmation()
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showBetConfirmation() {
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
            Text('Pronóstico: $selectedOutcome'),
            Text('Cuota: ${selectedMatch!['odds'][selectedOutcome]}'),
            Text('Cantidad: \$${betAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            Text(
                'Ganancia potencial: \$${(betAmount * selectedMatch!['odds'][selectedOutcome]).toStringAsFixed(2)}',
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
                  content: Text('Apuesta realizada con éxito!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
