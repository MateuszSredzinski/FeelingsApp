
import 'package:feelings/cubbit/entry_cubbit.dart';
import 'package:feelings/emotions_data.dart';
import 'package:feelings/main.dart';
import 'package:flutter/material.dart';

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