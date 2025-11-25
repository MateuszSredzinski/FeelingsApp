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
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialText.isNotEmpty) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final fullText = _controller.text.trim();
    if (fullText.isEmpty) return;
    widget.onSave(fullText);
    if (mounted) Navigator.of(context).pop();
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
                TextField(
                  controller: _controller,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'Wpis',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Zapisz'),
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
