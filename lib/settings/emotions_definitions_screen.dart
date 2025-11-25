import 'package:flutter/material.dart';
import 'package:feelings/emotions_data.dart';

class EmotionsDefinitionsScreen extends StatelessWidget {
  const EmotionsDefinitionsScreen({super.key});

  static const Map<String, String> definitions = {
    'SZCZĘŚLIWY': 'Poczucie spełnienia, radości i energii do działania.',
    'ZASKOCZONY': 'Stan nagłego zaciekawienia lub zdumienia wobec nowości.',
    'SŁABY': 'Doświadczanie zmęczenia, braku sił lub przeciążenia.',
    'LĘKLIWY': 'Niepokój, niepewność lub obawa przed konsekwencjami.',
    'ROZGNIEWANY': 'Irytacja, frustracja lub poczucie zagrożenia.',
    'ZNIESMACZONY': 'Niechęć, odrzucenie lub wstręt wobec sytuacji.',
    'SMUTNY': 'Poczucie straty, przygnębienia lub osamotnienia.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Definicje emocji')),
      body: ListView.builder(
        itemCount: mainEmotions.length,
        itemBuilder: (context, index) {
          final emotion = mainEmotions[index];
          final definition = definitions[emotion.name] ?? 'Brak definicji';
          return ExpansionTile(
            title: Text(emotion.name),
            subtitle: Text(definition),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: emotion.subEmotions
                      .map((sub) => Chip(label: Text(sub)))
                      .toList(),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
