import 'package:flutter/material.dart';
import 'package:psgc_picker/src/psgc_picker_controller.dart';
import 'package:psgc_picker/src/widgets/psgc_city_field.dart';
import 'package:psgc_picker/src/widgets/psgc_province_field.dart';
import 'package:psgc_picker/src/widgets/psgc_region_field.dart';

class PsgcPicker extends StatefulWidget {
  final double spacing;

  /// (optional) Displayed label for region
  final String? regionLabel;

  /// (optional) Displayed label for province
  final String? provinceLabel;

  /// (optional) Displayed label for city
  final String? cityLabel;

  /// (required) returns a function with string value from [region] selection
  final ValueChanged<String> onRegionChanged;

  /// (required) returns a function with string value from [province] selection
  final ValueChanged<String> onProvinceChanged;

  /// (required) returns a function with string value from [city] selection
  final ValueChanged<String> onCityChanged;

  /// Initial region selection, given as a **name** (not a code), e.g.
  /// `'Ilocos Region'`. Matching against the loaded dataset is
  /// case-insensitive and trims leading/trailing whitespace. A name that
  /// doesn't match any entry silently leaves the region (and downstream
  /// province/city) unselected — it does not throw.
  final String selectedRegion;

  /// Initial province selection, given as a **name** (not a code). Same
  /// case-insensitive, trimmed matching and silent-no-op-on-mismatch
  /// behavior as [selectedRegion]. Only applied if [selectedRegion] itself
  /// resolves to a match.
  final String selectedProvince;

  /// Initial city/municipality selection, given as a **name** (not a code).
  /// Same case-insensitive, trimmed matching and silent-no-op-on-mismatch
  /// behavior as [selectedRegion]. Only applied if [selectedProvince] itself
  /// resolves to a match.
  final String selectedCity;

  const PsgcPicker(
      {required this.onRegionChanged,
      required this.onProvinceChanged,
      required this.onCityChanged,
      required this.selectedRegion,
      required this.selectedProvince,
      required this.selectedCity,
      this.spacing = 0.0,
      this.regionLabel,
      this.provinceLabel,
      this.cityLabel,
      super.key});

  @override
  State<PsgcPicker> createState() => _PsgcPickerState();
}

class _PsgcPickerState extends State<PsgcPicker> {
  late final PsgcPickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PsgcPickerController(
      selectedRegion: widget.selectedRegion,
      selectedProvince: widget.selectedProvince,
      selectedCity: widget.selectedCity,
      onRegionChanged: widget.onRegionChanged,
      onProvinceChanged: widget.onProvinceChanged,
      onCityChanged: widget.onCityChanged,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.loadError != null) {
          return Text('Failed to load PSGC data: ${_controller.loadError}');
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PsgcRegionField(controller: _controller, label: widget.regionLabel),
            SizedBox(height: widget.spacing),
            PsgcProvinceField(
                controller: _controller, label: widget.provinceLabel),
            SizedBox(height: widget.spacing),
            PsgcCityField(controller: _controller, label: widget.cityLabel),
          ],
        );
      },
    );
  }
}
