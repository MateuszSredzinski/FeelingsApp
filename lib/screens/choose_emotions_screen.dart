
import 'package:feelings/cubbit/entry_cubbit.dart';
import 'package:feelings/emotions_data.dart';
import 'package:feelings/emotions_data_hive_entry.dart';
import 'package:feelings/main.dart';
import 'package:feelings/settings/settings_screen.dart';
import 'package:feelings/screens/save_summary_popup.dart';
import 'package:feelings/widgets/feelings_dialog.dart';
import 'package:flutter/material.dart';

class EmotionSelectPage extends StatefulWidget {
  const EmotionSelectPage({
    super.key,
    this.initialSelection,
    this.entryIndex,
    this.initialNote,
    this.initialPersonalNote,
  });

  final Map<String, int>? initialSelection;
  final int? entryIndex;
  final String? initialNote;
  final String? initialPersonalNote;

  @override
  State<EmotionSelectPage> createState() => _EmotionSelectPageState();
}

class _EmotionSelectPageState extends State<EmotionSelectPage> {
  late Map<String, int> selectedEmotions;

  @override
  void initState() {
    super.initState();
    selectedEmotions = Map<String, int>.from(widget.initialSelection ?? {});
  }

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
          return FeelingsDialog(
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
                                foregroundColor: intensity != null ? Colors.white : Colors.black87,
                                side: intensity != null
                                    ? const BorderSide(color: Colors.blueAccent, width: 2)
                                    : const BorderSide(color: Colors.transparent),
                              ),
                              onPressed: () {
                                setPopupState(() {
                                  intensity == null
                                      ? selectedEmotions[sub] = 1
                                      : selectedEmotions.remove(sub);
                                });
                                setState(() {});
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (intensity != null) const Icon(Icons.check, size: 16),
                                  if (intensity != null) const SizedBox(width: 4),
                                  Text(sub),
                                ],
                              ),
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
                                        color: (selectedEmotions[sub]! >= barValue)
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
                      onPressed: () {
                        Navigator.of(context).pop(); // zamknij popup wyboru sub-emocji
                      },
                      child: const Text('Zatwierdź'),
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
    final hasSelection = selectedEmotions.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wybierz emocje"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
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
          ),
          if (hasSelection)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openSummaryPopup,
                  child: const Text('Zapisz'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openSummaryPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (dialogContext) {
        return SaveSummaryPopup(
          selectedEmotions: Map<String, int>.from(selectedEmotions),
          initialNote: widget.initialNote,
          initialPersonalNote: widget.initialPersonalNote,
          groupedEmotions: _groupSelectedByMain(),
          onConfirm: (situation, personalNote) async {
            final appliedSituation = situation.isEmpty ? (widget.initialNote ?? '') : situation;
            final appliedPersonalNote =
                personalNote.isEmpty ? (widget.initialPersonalNote ?? '') : personalNote;
            final cubit = getIt<EntryCubit>();
            final entry = EmotionEntry(
              dateTime: DateTime.now(),
              title: appliedSituation,
              situationDescription: appliedSituation,
              personalNote: appliedPersonalNote,
              emotions: Map<String, int>.from(selectedEmotions),
            );

            if (widget.entryIndex != null) {
              await cubit.update(
                widget.entryIndex!,
                selectedEmotions,
                title: appliedSituation,
                situationDescription: appliedSituation,
                personalNote: appliedPersonalNote,
              );
            } else {
              await cubit.addEntry(entry);
            }

            setState(() {
              selectedEmotions.clear();
            });

            if (widget.entryIndex != null && mounted) {
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }

  Map<String, List<MapEntry<String, int>>> _groupSelectedByMain() {
    final Map<String, String> subToMain = {};
    for (final main in mainEmotions) {
      for (final sub in main.subEmotions) {
        subToMain[sub] = main.name;
      }
    }

    final Map<String, List<MapEntry<String, int>>> grouped = {};
    selectedEmotions.forEach((sub, value) {
      final main = subToMain[sub] ?? 'Inne';
      grouped.putIfAbsent(main, () => []);
      grouped[main]!.add(MapEntry(sub, value));
    });
    return grouped;
  }
}
