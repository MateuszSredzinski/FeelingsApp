
import 'package:feelings/cubbit/entry_cubbit.dart';
import 'package:feelings/emotions_data.dart';
import 'package:feelings/emotions_data_hive_entry.dart';
import 'package:feelings/main.dart';
import 'package:feelings/theme/app_gradients.dart';
import 'package:feelings/settings/settings_screen.dart';
import 'package:feelings/screens/save_summary_popup.dart';
import 'package:feelings/widgets/feelings_dialog.dart';
import 'package:feelings/screens/text_entry_screen.dart';
import 'package:flutter/material.dart';

class EmotionSelectPage extends StatefulWidget {
  const EmotionSelectPage({
    super.key,
    this.initialSelection,
    this.entryIndex,
    this.initialNote,
    this.initialPersonalNote,
    this.onEntryCreated,
  });

  final Map<String, int>? initialSelection;
  final int? entryIndex;
  final String? initialNote;
  final String? initialPersonalNote;
  final void Function(DateTime createdAt)? onEntryCreated;

  @override
  State<EmotionSelectPage> createState() => _EmotionSelectPageState();
}

class _EmotionSelectPageState extends State<EmotionSelectPage> {
  late Map<String, int> selectedEmotions;
  String? typedNote;

  @override
  void initState() {
    super.initState();
    selectedEmotions = Map<String, int>.from(widget.initialSelection ?? {});
    typedNote = widget.initialPersonalNote;
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
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setPopupState) {
          return FeelingsDialog(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
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
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection =
        selectedEmotions.isNotEmpty || (typedNote != null && typedNote!.isNotEmpty);
    final totalItems = mainEmotions.length + 1; // plus "Wpis"
    final notePreview = (typedNote ?? '').split('\n').first.trim();
    final hasNote = notePreview.isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                  itemCount: totalItems,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    if (index < mainEmotions.length) {
                      final e = mainEmotions[index];
                      final selectedForMain = selectedEmotions.entries
                          .where((entry) => e.subEmotions.contains(entry.key))
                          .map((entry) => entry.key)
                          .toList();
                      final count = selectedForMain.length;
                      final hasSelectionForMain = count > 0;
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: hasSelectionForMain ? 6 : 2,
                        shadowColor:
                            hasSelectionForMain ? const Color(0xFFE91E63).withOpacity(0.2) : null,
                        child: InkWell(
                          onTap: () => _openPopupFor(e),
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: hasSelectionForMain ? AppGradients.frozenSweep() : null,
                                  border: hasSelectionForMain
                                      ? Border.all(
                                          width: 1.8,
                                          color: AppGradients.sweepColors.first.withOpacity(0.8),
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    e.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              if (hasSelectionForMain)
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: IgnorePointer(
                                    child: _CountBadge(count: count),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: hasNote ? 6 : 2,
                      shadowColor:
                          hasNote ? AppGradients.sweepColors.first.withOpacity(0.2) : null,
                      child: InkWell(
                        onTap: _openTextEntryPopup,
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: hasNote ? AppGradients.frozenSweep() : null,
                            border: hasNote
                                ? Border.all(
                                    width: 1.8,
                                    color: AppGradients.sweepColors.first.withOpacity(0.8),
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'WPIS',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (notePreview.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    notePreview,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: hasNote ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
      ),
    );
  }

  Future<void> _openSummaryPopup() async {
    final isEditing = widget.entryIndex != null;
    DateTime? createdAt;
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: false,
      builder: (dialogContext) {
        return SaveSummaryPopup(
          selectedEmotions: Map<String, int>.from(selectedEmotions),
          initialPersonalNote: typedNote ?? widget.initialPersonalNote,
          groupedEmotions: _groupSelectedByMain(),
          onConfirm: (situation, personalNote) async {
            final appliedSituation = widget.initialNote ?? '';
            final appliedPersonalNote = personalNote.isEmpty
                ? (typedNote ?? widget.initialPersonalNote ?? '')
                : personalNote;
            final cubit = getIt<EntryCubit>();
            final entry = EmotionEntry(
              dateTime: DateTime.now(),
              title: appliedSituation,
              situationDescription: appliedSituation,
              personalNote: appliedPersonalNote,
              emotions: Map<String, int>.from(selectedEmotions),
              isDeleted: false,
              deletedAt: null,
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
              createdAt = entry.dateTime;
            }

            setState(() {
              selectedEmotions.clear();
              typedNote = null;
            });
          },
        );
      },
    );

    if (result == true && mounted) {
      if (isEditing) {
        Navigator.of(context).pop(true);
      } else if (createdAt != null) {
        widget.onEntryCreated?.call(createdAt!);
      }
    }
  }

  void _openTextEntryPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: false,
      builder: (context) => TextEntryPopup(
        initialText: typedNote ?? '',
        onSave: (text) {
          setState(() {
            typedNote = text;
          });
        },
      ),
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

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count >= 100 ? '99+' : '$count';
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
