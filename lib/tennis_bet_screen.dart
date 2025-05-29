import 'package:flutter/material.dart';

class TennisBetScreen extends StatefulWidget {
  const TennisBetScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TennisBetScreenState createState() => _TennisBetScreenState();
}

class _TennisBetScreenState extends State<TennisBetScreen> {
  final List<Map<String, dynamic>> matches = [
    {
      'players': ['Nadal', 'Djokovic'],
      'tournament': 'Roland Garros',
      'date': 'Vie 14 Jun, 15:00',
      'odds': {'1': 1.8, '2': 2.0},
      'setOdds': {'2-0': 3.5, '2-1': 4.2, '1-2': 5.0, '0-2': 4.0}
    },
    {
      'players': ['Federer', 'Alcaraz'],
      'tournament': 'Wimbledon',
      'date': 'Sáb 15 Jun, 18:30',
      'odds': {'1': 2.3, '2': 1.7},
      'setOdds': {'3-0': 2.8, '3-1': 3.5, '3-2': 5.5, '2-3': 6.0}
    },
  ];

  Map<String, dynamic>? selectedMatch;
  String? selectedOutcome;
  String? selectedSetScore;
  double betAmount = 0.0;
  // ignore: unused_field
  bool _showAdvanced = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apuestas de Tenis')),
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
        suffixIcon: Icon(Icons.sports_tennis),
      ),
      items: matches.map((match) {
        return DropdownMenuItem(
          value: match,
          child: Text(
              '${match['players'][0]} vs ${match['players'][1]} - ${match['tournament']}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedMatch = value;
          selectedOutcome = null;
          selectedSetScore = null;
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
              '${selectedMatch!['players'][0]} vs ${selectedMatch!['players'][1]}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('${selectedMatch!['tournament']} - ${selectedMatch!['date']}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOddButton('1', '${selectedMatch!['odds']['1']}'),
                _buildOddButton('2', '${selectedMatch!['odds']['2']}'),
              ],
            ),
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text('Apuestas de sets', style: TextStyle(fontSize: 16)),
              initiallyExpanded: false,
              onExpansionChanged: (expanded) =>
                  setState(() => _showAdvanced = expanded),
              children: [
                Wrap(
                  spacing: 10,
                  children: [
                    ...selectedMatch!['setOdds'].entries.map((entry) {
                      return CustomTennisChip(
                        label: Text('${entry.key} (${entry.value}x)'),
                        selected: selectedSetScore == entry.key,
                        onSelected: (selected) {
                          setState(() {
                            selectedSetScore = selected ? entry.key : null;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
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
            selectedOutcome == outcome ? Colors.green : Colors.grey[200],
        foregroundColor:
            selectedOutcome == outcome ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedOutcome = outcome;
          selectedSetScore = null;
        });
      },
      child: Column(
        children: [
          Text(
              outcome == '1'
                  ? selectedMatch!['players'][0]
                  : selectedMatch!['players'][1],
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Text(odd,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              icon: const Icon(Icons.sports_tennis),
              label: const Text('Confirmar Apuesta'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: (betAmount > 0 &&
                      (selectedOutcome != null || selectedSetScore != null))
                  ? () => _showBetConfirmation()
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showBetConfirmation() {
    final isSetBet = selectedSetScore != null;
    final odd = isSetBet
        ? selectedMatch!['setOdds'][selectedSetScore]
        : selectedMatch!['odds'][selectedOutcome];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Apuesta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Partido: ${selectedMatch!['players'][0]} vs ${selectedMatch!['players'][1]}'),
            Text(
                'Tipo: ${isSetBet ? 'Resultado en sets' : 'Ganador del partido'}'),
            Text(
                'Pronóstico: ${isSetBet ? selectedSetScore! : selectedOutcome == '1' ? selectedMatch!['players'][0] : selectedMatch!['players'][1]}'),
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
                  content: Text('Apuesta en tenis realizada!'),
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

class CustomTennisChip extends StatelessWidget {
  final Widget label;
  final bool selected;
  final Function(bool) onSelected;

  const CustomTennisChip({super.key, 
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: DefaultTextStyle.merge(
        style: TextStyle(
          color: selected ? Colors.green[900] : Colors.black,
        ),
        child: label,
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor:
          Colors.green[100], // Color de fondo cuando está seleccionado
      backgroundColor: Colors.grey[200], // Color de fondo normal
    );
  }
}
