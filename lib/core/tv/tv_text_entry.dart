import 'package:flutter/material.dart';

import 'tv.dart';
import 'tv_input_navigation.dart';

/// Keeps the keyboard closed during traversal. OK opens an editor, and Back
/// can dismiss the editor without applying an incomplete query or URL.
class TvTextEntry extends StatelessWidget {
  const TvTextEntry({
    super.key,
    required this.field,
    this.autofocus = false,
    this.submitOnDone = false,
  });

  final TextField field;
  final bool autofocus;
  final bool submitOnDone;

  @override
  Widget build(BuildContext context) {
    if (!isTvPlatform) return field;
    final controller = field.controller!;
    final label =
        field.decoration?.labelText ??
        field.decoration?.hintText ??
        MaterialLocalizations.of(context).searchFieldLabel;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => OutlinedButton(
        autofocus: autofocus,
        onPressed: field.enabled == false ? null : () => _edit(context, label),
        style: OutlinedButton.styleFrom(
          alignment: AlignmentDirectional.centerStart,
          minimumSize: const Size.fromHeight(44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.text.isEmpty ? label : value.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_outlined),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, String label) async {
    final controller = field.controller!;
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _TvTextEditor(
        label: label,
        initialValue: controller.text,
        keyboardType: field.keyboardType,
      ),
    );
    if (!context.mounted || value == null) return;
    if (value != controller.text) {
      controller.text = value;
      field.onChanged?.call(value);
    }
    if (submitOnDone) field.onSubmitted?.call(value);
  }
}

class _TvTextEditor extends StatefulWidget {
  const _TvTextEditor({
    required this.label,
    required this.initialValue,
    required this.keyboardType,
  });

  final String label;
  final String initialValue;
  final TextInputType? keyboardType;

  @override
  State<_TvTextEditor> createState() => _TvTextEditorState();
}

class _TvTextEditorState extends State<_TvTextEditor> {
  final _focusNode = FocusNode();
  late final _draft = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _focusNode.dispose();
    _draft.dispose();
    super.dispose();
  }

  void _finish() => Navigator.of(context).pop(_draft.text);

  @override
  Widget build(BuildContext context) {
    final strings = MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.label),
      scrollable: true,
      content: SizedBox(
        width: 460,
        child: TvInputNavigation(
          focusNode: _focusNode,
          child: TextField(
            controller: _draft,
            focusNode: _focusNode,
            autofocus: true,
            keyboardType: widget.keyboardType,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _finish(),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                tooltip: strings.deleteButtonTooltip,
                icon: const Icon(Icons.clear),
                onPressed: _draft.clear,
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancelButtonLabel),
        ),
        FilledButton(onPressed: _finish, child: Text(strings.okButtonLabel)),
      ],
    );
  }
}
