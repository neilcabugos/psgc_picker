import 'package:flutter/material.dart';
import 'package:psgc_picker/src/psgc_picker_controller.dart';
import 'package:psgc_picker/src/widgets/psgc_dropdown_widget.dart';

/// A standalone province dropdown bound to a [PsgcPickerController]. Can be
/// placed anywhere in the widget tree independently of [PsgcRegionField]
/// and [PsgcCityField], as long as they all share the same [controller].
class PsgcProvinceField extends StatelessWidget {
  final PsgcPickerController controller;

  /// (optional) Displayed label for the field
  final String? label;

  final InputDecoration? decoration;

  const PsgcProvinceField(
      {required this.controller, this.label, this.decoration, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => PsgcDropdownWidget(
        decoration: decoration ?? InputDecoration(labelText: label),
        selection: controller.provinceList,
        selectedValue: controller.selectedProvinceCode,
        onSelectionChanged: controller.selectProvince,
      ),
    );
  }
}
