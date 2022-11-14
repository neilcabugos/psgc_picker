import 'package:flutter/material.dart';
import 'package:psgc_picker/src/widgets/psgc_dropdown_widget.dart';

class PsgcPicker extends StatefulWidget {
  final double spacing;

  const PsgcPicker({
    this.spacing = 0.0,
    Key? key
  }) : super(key: key);

  @override
  State<PsgcPicker> createState() => _PsgcPickerState();
}

class _PsgcPickerState extends State<PsgcPicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const PsgcDropdownWidget(),
        SizedBox(height: widget.spacing),
        const PsgcDropdownWidget(),
        SizedBox(height: widget.spacing),
        const PsgcDropdownWidget(),
      ],
    );
  }
}