import 'package:flutter/material.dart';
import 'package:feelings/widgets/feelings_dialog.dart';

class SaveSummaryPopup extends StatefulWidget {
  const SaveSummaryPopup({
    super.key,
    required this.selectedEmotions,
    required this.onConfirm,
    this.initialNote,
    this.initialPersonalNote,
    required this.groupedEmotions,
  });

  final Map<String, int> selectedEmotions;
  final Future<void> Function(String situation, String personalNote) onConfirm;
  final String? initialNote;
  final String? initialPersonalNote;
  final Map<String, List<MapEntry<String, int>>> groupedEmotions;

  @override
  State<SaveSummaryPopup> createState() => _SaveSummaryPopupState();
}

class _SaveSummaryPopupState extends State<SaveSummaryPopup> {
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _personalNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialNote != null && widget.initialNote!.isNotEmpty) {
        _situationController.text = widget.initialNote!;
    }
    if (widget.initialPersonalNote != null && widget.initialPersonalNote!.isNotEmpty) {
      _personalNoteController.text = widget.initialPersonalNote!;
    }
  }

  @override
  void dispose() {
    _situationController.dispose();
    _personalNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FeelingsDialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Text(
                'Podsumowanie emocji',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                controller: _situationController,
                decoration: const InputDecoration(
                  labelText: 'Opis sytuacji',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
                      _situationController.text.trim(),
                      _personalNoteController.text.trim(),
                    );
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Zatwierdź zapis'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
