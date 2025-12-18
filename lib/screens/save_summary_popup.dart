import 'dart:math';

import 'package:flutter/material.dart';
import 'package:feelings/widgets/feelings_dialog.dart';

class SaveSummaryPopup extends StatefulWidget {
  const SaveSummaryPopup({
    super.key,
    required this.selectedEmotions,
    required this.onConfirm,
    this.initialPersonalNote,
    required this.groupedEmotions,
  });

  final Map<String, int> selectedEmotions;
  final Future<void> Function(String situation, String personalNote) onConfirm;
  final String? initialPersonalNote;
  final Map<String, List<MapEntry<String, int>>> groupedEmotions;

  @override
  State<SaveSummaryPopup> createState() => _SaveSummaryPopupState();
}

class _SaveSummaryPopupState extends State<SaveSummaryPopup> {
  final TextEditingController _personalNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPersonalNote != null && widget.initialPersonalNote!.isNotEmpty) {
      _personalNoteController.text = widget.initialPersonalNote!;
    }
  }

  @override
  void dispose() {
    _personalNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FeelingsDialog(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Padding(
  padding: const EdgeInsets.symmetric(),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        'Podsumowanie emocji',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  ),
),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.groupedEmotions.entries.map((group) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: group.value
                                .map(
                                  (e) => Chip(
                                    label: Text('${e.key} (${e.value}/6)'),
                                    backgroundColor: Colors.blue.withOpacity(0.1),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _personalNoteController,
                decoration: const InputDecoration(
                  labelText: 'Notatka dla siebie',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.onConfirm(
                      '',
                      _personalNoteController.text.trim(),
                    );
                    if (mounted) {
                      Navigator.of(context).pop(true);
                    }
                    },
                    child: const Text('Zatwierdź zapis'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
