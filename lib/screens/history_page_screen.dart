import 'dart:async';

import 'package:feelings/cubbit/entry_cubbit.dart';
import 'package:feelings/emotions_data.dart';
import 'package:feelings/emotions_data_hive_entry.dart';
import 'package:feelings/main.dart';
import 'package:feelings/theme/app_gradients.dart';
import 'package:feelings/screens/choose_emotions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feelings/widgets/adaptive_pinned_dialog.dart';
import 'package:feelings/settings/settings_screen.dart';
import 'package:feelings/settings/settings_cubit.dart';

class EmotionHistoryPage extends StatefulWidget {
  const EmotionHistoryPage({
    super.key,
    this.highlightedDateTime,
    this.onHighlightConsumed,
  });

  final DateTime? highlightedDateTime;
  final VoidCallback? onHighlightConsumed;

  @override
  State<EmotionHistoryPage> createState() => _EmotionHistoryPageState();
}

class _EmotionHistoryPageState extends State<EmotionHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  DateTime? _activeHighlight;
  Timer? _flashTimer;
  bool _flashOn = false;

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<EntryCubit>();
    final intensityEnabled = context.watch<SettingsCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historia emocji"),
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
      body: BlocBuilder<EntryCubit, List<EmotionEntry>>(
        bloc: cubit,
        builder: (context, state) {
          final visibleEntries = <MapEntry<int, EmotionEntry>>[];
          for (var i = 0; i < state.length; i++) {
            final entry = state[i];
            if (!entry.isDeleted) {
              visibleEntries.add(MapEntry(i, entry));
            }
          }

          visibleEntries.sort(
            (a, b) => b.value.dateTime.compareTo(a.value.dateTime),
          );

          if (visibleEntries.isEmpty) {
            return const Center(child: Text('Brak zapisanych wpisów'));
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: visibleEntries.length,
            itemBuilder: (context, index) {
              final item = visibleEntries[index];
              final entry = item.value;
              final originalIndex = item.key;
              final isHighlighted =
                  _activeHighlight != null && entry.dateTime.isAtSameMomentAs(_activeHighlight!);

              final sweepColors = AppGradients.tileSweepColors;
              final factor = _flashOn ? 1.15 : 0.9; // mocniejszy flash, nadal subtelny
              final gradient = isHighlighted
                  ? SweepGradient(
                      colors: sweepColors
                          .map((c) => c.withOpacity((c.opacity * factor).clamp(0.0, 1.0)))
                          .toList(growable: false),
                      startAngle: 0,
                      endAngle: 2 * 3.1415926535,
                    )
                  : null;
              final shadowColor = isHighlighted
                  ? sweepColors.first.withOpacity(_flashOn ? 0.4 : 0.24)
                  : Colors.transparent;

              return AnimatedScale(
                duration: const Duration(milliseconds: 220),
                scale: isHighlighted && _flashOn ? 1.02 : 1.0,
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    boxShadow: isHighlighted
                        ? [
                            BoxShadow(
                              color: shadowColor,
                              blurRadius: 18,
                              spreadRadius: 3,
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showEntryDialog(context, entry, originalIndex, intensityEnabled),
                      onLongPress: () => _confirmDelete(context, originalIndex),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.subEmotionIntensity.isNotEmpty
                                        ? entry.subEmotionIntensity.entries.map((e) => e.key).join(', ')
                                        : 'Brak wybranych emocji',
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.personalNote.isNotEmpty ? entry.personalNote : 'Brak wpisu',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                
                                  const SizedBox(height: 2),
                                  if (_relativeLabel(entry.dateTime) != null) ...[
                                    Text(
                                      _relativeLabel(entry.dateTime)!,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Text(
                                    '${_weekdayName(entry.dateTime)} ${_formatDate(entry.dateTime)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (entry.editedAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Edyt.: ${_formatTime(entry.editedAt!)}, ${_formatDate(entry.editedAt!)}',
                                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _applyHighlight(widget.highlightedDateTime);
  }

  @override
  void didUpdateWidget(covariant EmotionHistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedDateTime != null &&
        widget.highlightedDateTime != oldWidget.highlightedDateTime) {
      _applyHighlight(widget.highlightedDateTime);
    }
  }

  void _applyHighlight(DateTime? date) {
    if (date == null) return;
    _flashTimer?.cancel();
    _activeHighlight = date;
    _flashOn = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {});
      int ticks = 0;
      _flashTimer = Timer.periodic(const Duration(milliseconds: 320), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() => _flashOn = !_flashOn);
        ticks++;
        if (ticks >= 12) {
          timer.cancel();
          setState(() {
            _activeHighlight = null;
            _flashOn = false;
          });
          widget.onHighlightConsumed?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _showEntryDialog(
    BuildContext context,
    EmotionEntry entry,
    int index,
    bool intensityEnabled,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (dialogContext) {
        return AdaptivePinnedDialog(
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Wybrane emocje',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _confirmDelete(
                    context,
                    index,
                    onCancel: () => _showEntryDialog(
                      context,
                      entry,
                      index,
                      intensityEnabled,
                    ),
                  );
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EmotionSelectPage(
                        initialSelection: Map<String, int>.from(entry.subEmotionIntensity),
                        entryIndex: index,
                        initialNote: entry.situationDescription,
                        initialPersonalNote: entry.personalNote,
                      ),
                    ),
                  );
                  if (result == true && context.mounted) {
                    final updatedState = getIt<EntryCubit>().state;
                    if (index >= 0 && index < updatedState.length) {
                      _showEntryDialog(context, updatedState[index], index, intensityEnabled);
                    }
                  }
                },
                child: const Text('Edytuj'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Zamknij'),
              ),
            ],
          ),
          bodyChildren: [
            if (_groupEntryByMain(entry).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _groupEntryByMain(entry).entries.map((group) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: group.value.map((emotion) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                  onPressed: null,
                                  child: Text(
                                    emotion.key,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                if (intensityEnabled && emotion.value > 0) ...[
                                  const SizedBox(height: 6),
                                  _buildIntensityDots(emotion.value),
                                ],
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Brak wybranych emocji'),
              ),
            const SizedBox(height: 12),
            const Text(
              'Notatka dla siebie',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              entry.personalNote.isNotEmpty ? entry.personalNote : 'Brak wpisu',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int index, {VoidCallback? onCancel}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (dialogContext) {
        return AdaptivePinnedDialog(
          header: const Text(
            'Przenieść wpis do kosza?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  if (onCancel != null) onCancel();
                },
                child: const Text('Anuluj'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  await getIt<EntryCubit>().deleteToTrash(index);
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
                child: const Text('Przenieś do kosza'),
              ),
            ],
          ),
          bodyChildren: const [
            Text('Wpis zostanie oznaczony jako usunięty i trafi do kosza.'),
          ],
        );
      },
    );
  }

  Widget _buildIntensityDots(int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final dotValue = i + 1;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: value >= dotValue ? Colors.blue : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

  String _weekdayName(DateTime dt) {
    const names = [
      'Poniedziałek',
      'Wtorek',
      'Środa',
      'Czwartek',
      'Piątek',
      'Sobota',
      'Niedziela',
    ];
    return names[(dt.weekday - 1) % 7];
  }

  String? _relativeLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diffDays = today.difference(target).inDays;
    if (diffDays == 0) {
      return 'Dzisiaj ${_formatTime(dt)}';
    } else if (diffDays == 1) {
      return 'Wczoraj ${_formatTime(dt)}';
    } else if (diffDays == 2) {
      return 'Przedwczoraj ${_formatTime(dt)}';
    }
    return null;
  }

  Map<String, List<MapEntry<String, int>>> _groupEntryByMain(EmotionEntry entry) {
    final Map<String, String> subToMain = {};
    for (final main in mainEmotions) {
      for (final sub in main.subEmotions) {
        subToMain[sub] = main.name;
      }
    }

    final Map<String, List<MapEntry<String, int>>> grouped = {};
    entry.subEmotionIntensity.forEach((sub, value) {
      final main = subToMain[sub] ?? 'Inne';
      grouped.putIfAbsent(main, () => []);
      grouped[main]!.add(MapEntry(sub, value));
    });
    return grouped;
  }
}
