// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'emotions_data.dart'; // lista mainEmotions i klasa Emotion
import 'emotions_data_hive_entry.dart';
import 'entry_repo.dart';
import 'cubbit/entry_cubbit.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Zarejestruj adapter
  Hive.registerAdapter(EmotionEntryAdapter());

  // Otwórz box
  final box = await Hive.openBox('entriesBox');

  // Zarejestruj repo i cubit w get_it
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
        child: const HomePage(),
      ),
    );
  }
}

// MODELE ENTRY już w models/emotion_entry.dart

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // selectedEmotions trzymamy lokalnie w UI aż do zapisu
  Map<String, int> selectedEmotions = {};

  void _toggleEmotionLocally(String name) {
    setState(() {
      if (selectedEmotions.containsKey(name)) {
        selectedEmotions.remove(name);
      } else {
        selectedEmotions[name] = 1;
      }
    });
  }

  void _openPopupFor(Emotion emotion) {
    // podobny popup jak wcześniej — ale zapis poprzez Cubit
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
                    Text('Wybierz emocje z "${emotion.name}"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                  if (intensity == null) {
                                    selectedEmotions[sub] = 1;
                                  } else {
                                    selectedEmotions.remove(sub);
                                  }
                                });
                                setState(() {}); // zsynchronizuj UI główny
                              },
                              child: Text(sub, style: TextStyle(color: intensity != null ? Colors.white : Colors.black)),
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
                                        color: selectedEmotions[sub]! >= barValue ? Colors.blue : Colors.grey[300],
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
                        // zapisz przez Cubit
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
    final cubit = getIt<EntryCubit>();
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          children: [
            const Text('Wybierz główną emocję:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // GRID głównych emocji (2 kolumny), pokazujemy max 5 widocznych + reszta przewijana
            SizedBox(
              height: 580,
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: mainEmotions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final e = mainEmotions[index];
                  final isSelected = selectedEmotions.containsKey(e.name);
                  return Card(
                    
                    color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade400, width: 1.2),
                    ),
                    child: Padding(
                      
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(

                      child: Column(
                        
                        children: [
                          ElevatedButton(
                            
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                            ),
                            onPressed: () => _openPopupFor(e),
                            child: Text(
                              
                              e.name,
                              style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            
                            runSpacing: 4,
                            children: e.subEmotions.take(3).map((sub) {
                              final sel = selectedEmotions.containsKey(sub);
                              return GestureDetector(
                                onTap: () {
                                  _toggleEmotionLocally(sub);
                                },
                                child: Chip(
                                  backgroundColor: sel ? Colors.blue : Colors.grey[300],
                                  label: Text(sub, style: TextStyle(color: sel ? Colors.white : Colors.black)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],)
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Twoje wpisy:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // lista wpisów połączona z Cubit
            Expanded(
              child: BlocBuilder<EntryCubit, List<dynamic>>(
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
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(entry.title.isEmpty ? 'Bez tytułu' : entry.title),
                          subtitle: Text(entry.emotions.entries.map((e) => '${e.key}: ${e.value}/6').join(', ')),
                          trailing: Text('${entry.dateTime.hour.toString().padLeft(2,'0')}:${entry.dateTime.minute.toString().padLeft(2,'0')}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
