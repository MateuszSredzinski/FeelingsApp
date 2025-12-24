
import 'package:feelings/cubbit/entry_cubbit.dart';
import 'package:feelings/emotions_data.dart';
import 'package:feelings/emotions_data_hive_entry.dart';
import 'package:feelings/main.dart';
import 'package:feelings/theme/app_gradients.dart';
import 'package:feelings/settings/settings_screen.dart';
import 'package:feelings/settings/settings_cubit.dart';
import 'package:feelings/screens/save_summary_popup.dart';
import 'package:feelings/widgets/feelings_dialog.dart';
import 'package:feelings/screens/text_entry_screen.dart';
import 'package:feelings/widgets/intensity_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late Map<String, int> selectedSubEmotions;
  String? typedNote;

  @override
  void initState() {
    super.initState();
    selectedSubEmotions = Map<String, int>.from(widget.initialSelection ?? {});
    typedNote = widget.initialPersonalNote;
  }

  void _openPopupFor(Emotion emotion, bool intensityEnabled) {
    if (intensityEnabled) {
      final keysToFix = selectedSubEmotions.entries
          .where((entry) => entry.value == 0)
          .map((entry) => entry.key)
          .toList();
      if (keysToFix.isNotEmpty) {
        setState(() {
          for (final key in keysToFix) {
            selectedSubEmotions[key] = 1;
          }
        });
      }
    }
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
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: emotion.subEmotions.length,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240,
                          mainAxisExtent: 56,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          final sub = emotion.subEmotions[index];
                          final intensity = selectedSubEmotions[sub] ?? 0;
                          final isSelected = selectedSubEmotions.containsKey(sub);
                          final showIntensity = intensityEnabled && isSelected;
                          final reserveSpace = intensityEnabled;
                          final displayValue =
                              intensity == 0 ? 1 : intensity.clamp(1, 4);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    curve: Curves.easeOut,
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(16),
                                      border: isSelected
                                          ? Border.all(color: Colors.blueAccent, width: 1.5)
                                          : Border.all(color: Colors.transparent),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        setPopupState(() {
                                          if (isSelected) {
                                            selectedSubEmotions.remove(sub);
                                          } else {
                                            selectedSubEmotions[sub] = intensityEnabled ? 1 : 0;
                                          }
                                        });
                                        setState(() {});
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isSelected) const Icon(Icons.check, size: 14, color: Colors.white),
                                            if (isSelected) const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                sub,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: isSelected ? Colors.white : Colors.black87,
                                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Visibility(
                                  visible: showIntensity,
                                  maintainSize: reserveSpace,
                                  maintainAnimation: reserveSpace,
                                  maintainState: reserveSpace,
                                  child: IntensityButton(
                                    value: displayValue,
                                    maxValue: 4,
                                    size: 30,
                                    enabled: showIntensity,
                                    onChanged: (next) {
                                      setPopupState(() {
                                        selectedSubEmotions[sub] = next;
                                      });
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
    final intensityEnabled = context.watch<SettingsCubit>().state;
    final hasSelection =
        selectedSubEmotions.isNotEmpty || (typedNote != null && typedNote!.isNotEmpty);
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
                      final selectedForMain = selectedSubEmotions.entries
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
                          onTap: () => _openPopupFor(e, intensityEnabled),
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
    final intensityEnabled = context.read<SettingsCubit>().state;
    final mapForSave = intensityEnabled
        ? _normalizeIntensity(selectedSubEmotions)
        : {for (final key in selectedSubEmotions.keys) key: 0};
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: false,
      builder: (dialogContext) {
        return SaveSummaryPopup(
          initialPersonalNote: typedNote ?? widget.initialPersonalNote,
          groupedEmotions: _groupSelectedByMain(mapForSave),
          intensityEnabled: intensityEnabled,
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
              subEmotionIntensity: Map<String, int>.from(mapForSave),
              isDeleted: false,
              deletedAt: null,
            );

            if (widget.entryIndex != null) {
              await cubit.update(
                widget.entryIndex!,
                mapForSave,
                title: appliedSituation,
                situationDescription: appliedSituation,
                personalNote: appliedPersonalNote,
              );
            } else {
              await cubit.addEntry(entry);
              createdAt = entry.dateTime;
            }

            setState(() {
              selectedSubEmotions.clear();
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

  Map<String, List<MapEntry<String, int>>> _groupSelectedByMain(
      [Map<String, int>? source]) {
    final Map<String, String> subToMain = {};
    for (final main in mainEmotions) {
      for (final sub in main.subEmotions) {
        subToMain[sub] = main.name;
      }
    }

    final Map<String, List<MapEntry<String, int>>> grouped = {};
    final data = source ?? selectedSubEmotions;
    data.forEach((sub, value) {
      final main = subToMain[sub] ?? 'Inne';
      grouped.putIfAbsent(main, () => []);
      grouped[main]!.add(MapEntry(sub, value));
    });
    return grouped;
  }

  Map<String, int> _normalizeIntensity(Map<String, int> source) {
    final result = <String, int>{};
    for (final entry in source.entries) {
      final value = entry.value;
      result[entry.key] = value == 0 ? 1 : value.clamp(1, 4);
    }
    return result;
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
