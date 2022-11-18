import 'package:flutter/material.dart';
import 'package:psgc_picker/src/models/selection_model.dart';

class PsgcDropdownWidget extends StatelessWidget {
  final List<SelectionModel> selection;
  final ValueChanged<String> onSelectionChanged;
  final String? selectedValue;
  final InputDecoration decoration;

  const PsgcDropdownWidget(
      {required this.selection,
      required this.onSelectionChanged,
      required this.selectedValue,
      this.decoration =
          const InputDecoration(contentPadding: EdgeInsets.all(0.0)),
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: decoration,
      child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
        isExpanded: true,
        items: selection
            .map((SelectionModel item) =>
                DropdownMenuItem(value: item.code, child: Text(item.name!)))
            .toList(),
        onChanged: (value) => onSelectionChanged(value!),
        value: selectedValue,
      )),
    );
  }
}
