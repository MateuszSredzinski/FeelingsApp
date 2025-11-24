// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:iconsax/iconsax.dart';

import 'emotions_data.dart';
import 'emotions_data_hive_entry.dart';
import 'entry_repo.dart';
import 'cubbit/entry_cubbit.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(EmotionEntryAdapter());
  final box = await Hive.openBox('entriesBox');

  getIt.registerSingleton<EntryRepository>(EntryRepository(box));
  getIt.registerSingleton<EntryCubit>(EntryCubit(getIt<EntryRepository>())..load());

  runApp(const FeelingApp());
}

class FeelingApp extends StatelessWidget {
  const FeelingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feeling',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider.value(
        value: getIt<EntryCubit>(),
        child: const MainNavigationPage(),
      ),
    );
  }
}

//
// ──────────────────────────────────────────────────────────
//   GŁÓWNY NAVIGATION PAGE
// ──────────────────────────────────────────────────────────
//
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int currentIndex = 0;

  final screens = const [
    EmotionSelectPage(),
    EmotionHistoryPage(),
  ];

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: screens[currentIndex],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => setState(() => currentIndex = i),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Iconsax.smileys),
          label: "Emocje",
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.timer4),
          label: "Historia",
        ),
      ],
    ),
  );
}
}

//
// ──────────────────────────────────────────────────────────
//   EKRAN 1 — WYBÓR EMOCJI
// ──────────────────────────────────────────────────────────
//
class EmotionSelectPage extends StatefulWidget {
  const EmotionSelectPage({super.key});

  @override
  State<EmotionSelectPage> createState() => _EmotionSelectPageState();
}

class _EmotionSelectPageState extends State<EmotionSelectPage> {
  Map<String, int> selectedEmotions = {};

  void toggleEmotionLocally(String name) {
    setState(() {
      selectedEmotions.containsKey(name)
          ? selectedEmotions.remove(name)
          : selectedEmotions[name] = 1;
    });
  }

  void _openPopupFor(Emotion emotion) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setPopupState) {
          return Dialog(
            backgroundColor: Colors.white.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Wybierz emocje z "${emotion.name}"',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: emotion.subEmotions.map((sub) {
                        final intensity = selectedEmotions[sub];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: intensity != null ? Colors.blue : Colors.grey[300],
                              ),
                              onPressed: () {
                                setPopupState(() {
                                  intensity == null
                                      ? selectedEmotions[sub] = 1
                                      : selectedEmotions.remove(sub);
                                });
                                setState(() {});
                              },
                              child: Text(sub,
                                  style: TextStyle(color: intensity != null ? Colors.white : Colors.black)),
                            ),

                            if (intensity != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(6, (index) {
                                  final barValue = index + 1;
                                  return GestureDetector(
                                    onTap: () {
                                      setPopupState(() {
                                        selectedEmotions[sub] = barValue;
                                      });
                                      setState(() {});
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: selectedEmotions[sub]! >= barValue
                                            ? Colors.blue
                                            : Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                          ],
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final cubit = getIt<EntryCubit>();
                        await cubit.add(selectedEmotions);
                        selectedEmotions.clear();
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Zapisz emocje'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wybierz emocje")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: mainEmotions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (context, index) {
            final e = mainEmotions[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => _openPopupFor(e),
                child: Center(
                  child: Text(
                    e.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

//
// ──────────────────────────────────────────────────────────
//   EKRAN 2 — HISTORIA EMOCJI
// ──────────────────────────────────────────────────────────
//
class EmotionHistoryPage extends StatelessWidget {
  const EmotionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<EntryCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Historia emocji")),
      body: BlocBuilder<EntryCubit, List<dynamic>>(
        bloc: cubit,
        builder: (context, state) {
          if (state.isEmpty) {
            return const Center(child: Text('Brak zapisanych wpisów'));
          }
          return ListView.builder(
            itemCount: state.length,
            itemBuilder: (context, index) {
              final entry = state[index] as EmotionEntry;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(entry.title.isEmpty ? "Bez tytułu" : entry.title),
                  subtitle:
                      Text(entry.emotions.entries.map((e) => '${e.key}: ${e.value}/6').join(', ')),
                  trailing: Text(
                    '${entry.dateTime.hour.toString().padLeft(2, '0')}:${entry.dateTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
