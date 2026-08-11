import 'package:flutter/material.dart';
import 'package:psgc_picker/src/psgc_picker_controller.dart';
import 'package:psgc_picker/src/widgets/psgc_dropdown_widget.dart';

/// A standalone city/municipality dropdown bound to a
/// [PsgcPickerController]. Can be placed anywhere in the widget tree
/// independently of [PsgcRegionField] and [PsgcProvinceField], as long as
/// they all share the same [controller].
class PsgcCityField extends StatelessWidget {
  final PsgcPickerController controller;

  /// (optional) Displayed label for the field
  final String? label;

  final InputDecoration? decoration;

  const PsgcCityField(
      {required this.controller, this.label, this.decoration, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => PsgcDropdownWidget(
        decoration: decoration ?? InputDecoration(labelText: label),
        selection: controller.cityList,
        selectedValue: controller.selectedCityCode,
        onSelectionChanged: controller.selectCity,
      ),
    );
  }
}
