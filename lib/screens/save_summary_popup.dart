import 'package:flutter/material.dart';

class SaveSummaryPopup extends StatefulWidget {
  const SaveSummaryPopup({
    super.key,
    required this.selectedEmotions,
    required this.onConfirm,
    this.initialNote,
  });

  final Map<String, int> selectedEmotions;
  final Future<void> Function(String note) onConfirm;
  final String? initialNote;

  @override
  State<SaveSummaryPopup> createState() => _SaveSummaryPopupState();
}

class _SaveSummaryPopupState extends State<SaveSummaryPopup> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialNote != null && widget.initialNote!.isNotEmpty) {
      _noteController.text = widget.initialNote!;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.selectedEmotions.entries
                    .map(
                      (e) => Chip(
                        label: Text('${e.key} (${e.value}/6)'),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notatka (opcjonalnie)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.onConfirm(_noteController.text.trim());
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
