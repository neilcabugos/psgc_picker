import 'package:flutter/material.dart';
import 'package:psgc_picker/src/models/selection_model.dart';

class PsgcDropdownWidget extends StatefulWidget {
  final List<SelectionModel> selection;
  final ValueChanged<String> onSelectionChanged;
  final String? selectedValue;
  final InputDecoration decoration;

  /// When true, renders a type-to-filter combobox instead of a scrolling
  /// [DropdownButton] list.
  final bool searchable;

  const PsgcDropdownWidget(
      {required this.selection,
      required this.onSelectionChanged,
      required this.selectedValue,
      this.decoration =
          const InputDecoration(contentPadding: EdgeInsets.all(0.0)),
      this.searchable = false,
      super.key});

  @override
  State<PsgcDropdownWidget> createState() => _PsgcDropdownWidgetState();
}

class _PsgcDropdownWidgetState extends State<PsgcDropdownWidget> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: _nameFor(widget.selectedValue));
    _focusNode = FocusNode()..addListener(_onFocusChange);
    if (widget.searchable) _scheduleOptionsRefresh();
  }

  @override
  void didUpdateWidget(covariant PsgcDropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.searchable) return;
    if (widget.selectedValue != oldWidget.selectedValue) {
      _syncTextToSelection();
    }
    // Only when the option *list itself* changed identity (e.g. a cascading
    // region/province reselection refiltering the city list) — not merely
    // because [selectedValue] changed, which also happens as the direct
    // result of the user picking an option here. Refreshing in that case too
    // would immediately reopen the options view RawAutocomplete just closed
    // after the pick, with the freshly picked item highlighted.
    if (!identical(widget.selection, oldWidget.selection)) {
      _scheduleOptionsRefresh();
    }
  }

  // RawAutocomplete only recomputes its options list when the field's text
  // actually changes, so it never notices [widget.selection] changing on its
  // own (e.g. selecting a province refiltering the city list) — it keeps
  // showing whatever it last computed (often empty) until the user types.
  // Nudging the controller with a no-op text edit forces a recompute against
  // the current data. Deferred to a microtask so it runs after this build's
  // widget tree (and the RawAutocomplete it reconfigures) has been
  // reconciled, rather than against the still-current, about-to-be-replaced
  // options source.
  void _scheduleOptionsRefresh() {
    Future.microtask(() {
      if (!mounted || !widget.searchable) return;
      final text = _textController.text;
      // Append a zero-width space (U+200B): a no-op edit that RawAutocomplete
      // still treats as a genuine text change.
      _textController.text = '$text​';
      _textController.text = text;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _syncTextToSelection();
  }

  void _syncTextToSelection() {
    final name = _nameFor(widget.selectedValue);
    if (_textController.text != name) _textController.text = name;
  }

  String _nameFor(String? code) {
    if (code == null) return '';
    final match = widget.selection.where((e) => e.code == code);
    return match.isEmpty ? '' : (match.first.name ?? '');
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.searchable) {
      return InputDecorator(
        decoration: widget.decoration,
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          isExpanded: true,
          items: widget.selection
              .map((SelectionModel item) => DropdownMenuItem(
                  value: item.code, child: Text(item.name ?? '')))
              .toList(),
          onChanged: (value) => widget.onSelectionChanged(value!),
          value: widget.selectedValue,
        )),
      );
    }

    return RawAutocomplete<SelectionModel>(
      textEditingController: _textController,
      focusNode: _focusNode,
      displayStringForOption: (option) => option.name ?? '',
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return widget.selection;
        return widget.selection
            .where((item) => (item.name ?? '').toLowerCase().contains(query));
      },
      onSelected: (option) {
        if (option.code != null) widget.onSelectionChanged(option.code!);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: widget.decoration,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.name ?? ''),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
