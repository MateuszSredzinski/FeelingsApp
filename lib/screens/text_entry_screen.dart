import 'package:flutter/material.dart';
import 'package:feelings/widgets/feelings_dialog.dart';

class TextEntryPopup extends StatefulWidget {
  const TextEntryPopup({super.key, required this.onSave, this.initialText = ''});

  final ValueChanged<String> onSave;
  final String initialText;

  @override
  State<TextEntryPopup> createState() => _TextEntryPopupState();
}

class _TextEntryPopupState extends State<TextEntryPopup> {
  late final TextEditingController _controller;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _canSave = _controller.text.trim().isNotEmpty;
    _controller.addListener(() {
      final enabled = _controller.text.trim().isNotEmpty;
      if (enabled != _canSave) {
        setState(() {
          _canSave = enabled;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() {
    final fullText = _controller.text.trim();
    if (fullText.isEmpty) return;
    widget.onSave(fullText);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FeelingsDialog(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'WPIS',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Anuluj'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _canSave ? _onSave : null,
                      child: const Text('Zapisz'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
