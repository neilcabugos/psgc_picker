import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psgc_picker/src/models/selection_model.dart';
import 'package:psgc_picker/src/widgets/psgc_dropdown_widget.dart';

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
      Key? key})
      : super(key: key);

  @override
  State<PsgcPicker> createState() => _PsgcPickerState();
}

class _PsgcPickerState extends State<PsgcPicker> {
  List<SelectionModel> _regionList = [];
  List<SelectionModel> _provinceList = [];
  List<SelectionModel> _cityList = [];

  List<SelectionModel> _region = [];
  List<SelectionModel> _province = [];
  List<SelectionModel> _city = [];

  String? _selectedRegionCode;
  String? _selectedProvinceCode;
  String? _selectedCityCode;

  Object? _loadError;

  Future<List<SelectionModel>> getList(String filename) async {
    var res = await rootBundle
        .loadString("packages/psgc_picker/lib/src/assets/$filename.json");
    Iterable list = jsonDecode(res);
    return list.map((e) => SelectionModel.fromJson(e)).toList();
  }

  void initializeList() async {
    try {
      _regionList = await getList('region');
      _provinceList = await getList('province');
      _cityList = await getList('city');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e);
      return;
    }
    if (!mounted) return;
    setState(() {
      _region = _regionList;
      var selectRegion = _region.firstWhere(
          (element) =>
              element.name == widget.selectedRegion.trim().toUpperCase(),
          orElse: () => SelectionModel());
      if (selectRegion.code != null) {
        _applyRegion(selectRegion.code!);

        var selectProvince = _province.firstWhere(
            (element) =>
                element.name == widget.selectedProvince.trim().toUpperCase(),
            orElse: () => SelectionModel());
        if (selectProvince.code != null) _applyProvince(selectProvince.code!);

        var selectCity = _city.firstWhere(
            (element) =>
                element.name == widget.selectedCity.trim().toUpperCase(),
            orElse: () => SelectionModel());
        if (selectCity.code != null) _applyCity(selectCity.code!);
      }
    });
  }

  void _applyRegion(String value) {
    if (!mounted) return;
    setState(() {
      _selectedRegionCode = value;
      _province.clear();
      _selectedProvinceCode = null;
      _city.clear();
      _selectedCityCode = null;
      _province = _provinceList
          .where((element) => element.regionCode == value)
          .toList();
      if (_province.isEmpty) {
        // NCR-style region with no distinct provinces: treat the region
        // itself as the sole "province" entry and cascade straight into it,
        // without nesting another setState inside this one.
        _province = _region.where((element) => element.code == value).toList();
        _selectProvince(value);
      }
      var selected = _region.firstWhere((element) => element.code == value,
          orElse: () => SelectionModel());
      if (selected.name != null) widget.onRegionChanged(selected.name!);
    });
  }

  void _applyProvince(String value) {
    if (!mounted) return;
    setState(() => _selectProvince(value));
  }

  void _selectProvince(String value) {
    _selectedProvinceCode = value;
    _selectedCityCode = null;
    _city.clear();
    _city = _cityList
        .where((element) =>
            element.provinceCode == value || element.regionCode == value)
        .toList();
    var selected = _province.firstWhere((element) => element.code == value,
        orElse: () => SelectionModel());
    if (selected.name != null) widget.onProvinceChanged(selected.name!);
  }

  void _applyCity(String value) {
    if (!mounted) return;
    setState(() {
      _selectedCityCode = value;
      var selected = _city.firstWhere((element) => element.code == value,
          orElse: () => SelectionModel());
      if (selected.name != null) widget.onCityChanged(selected.name!);
    });
  }

  @override
  void initState() {
    initializeList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Text('Failed to load PSGC data: $_loadError');
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PsgcDropdownWidget(
          decoration: InputDecoration(labelText: widget.regionLabel),
          selection: _region,
          selectedValue: _selectedRegionCode,
          onSelectionChanged: (value) => _applyRegion(value),
        ),
        SizedBox(height: widget.spacing),
        PsgcDropdownWidget(
          decoration: InputDecoration(labelText: widget.provinceLabel),
          selection: _province,
          selectedValue: _selectedProvinceCode,
          onSelectionChanged: (value) => _applyProvince(value),
        ),
        SizedBox(height: widget.spacing),
        PsgcDropdownWidget(
          decoration: InputDecoration(labelText: widget.cityLabel),
          selection: _city,
          selectedValue: _selectedCityCode,
          onSelectionChanged: (value) => _applyCity(value),
        ),
      ],
    );
  }
}
