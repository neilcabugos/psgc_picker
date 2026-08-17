import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:psgc_picker/src/models/selection_model.dart';

/// Owns PSGC data loading and cascading region/province/city selection
/// state, independent of any particular widget layout. Multiple field
/// widgets (e.g. [PsgcRegionField], [PsgcProvinceField], [PsgcCityField])
/// can share one instance and stay in sync via [ChangeNotifier]
/// notifications, regardless of where each is placed in the widget tree.
///
/// The controller starts loading its data as soon as it's constructed. The
/// caller that constructs a [PsgcPickerController] is responsible for
/// calling [dispose] on it (e.g. from a `State.dispose()`).
class PsgcPickerController extends ChangeNotifier {
  PsgcPickerController({
    this.selectedRegion = '',
    this.selectedProvince = '',
    this.selectedCity = '',
    this.onRegionChanged,
    this.onProvinceChanged,
    this.onCityChanged,
  }) {
    load();
  }

  /// Initial region selection, given as a **name** (not a code). Applied
  /// once, when [load] first resolves. See [PsgcPicker.selectedRegion] for
  /// full matching semantics.
  final String selectedRegion;

  /// Initial province selection, given as a **name** (not a code). Only
  /// applied if [selectedRegion] itself resolves to a match.
  final String selectedProvince;

  /// Initial city/municipality selection, given as a **name** (not a
  /// code). Only applied if [selectedProvince] itself resolves to a match.
  final String selectedCity;

  final ValueChanged<String>? onRegionChanged;
  final ValueChanged<String>? onProvinceChanged;
  final ValueChanged<String>? onCityChanged;

  List<SelectionModel> _regionList = [];
  List<SelectionModel> _provinceList = [];
  List<SelectionModel> _cityList = [];

  List<SelectionModel> _region = [];
  List<SelectionModel> _province = [];
  List<SelectionModel> _city = [];

  String? _selectedRegionCode;
  String? _selectedProvinceCode;
  String? _selectedCityCode;

  bool _isLoading = false;
  Future<void>? _inFlightLoad;
  Object? _loadError;
  bool _disposed = false;

  List<SelectionModel> get regionList => _region;
  List<SelectionModel> get provinceList => _province;
  List<SelectionModel> get cityList => _city;

  String? get selectedRegionCode => _selectedRegionCode;
  String? get selectedProvinceCode => _selectedProvinceCode;
  String? get selectedCityCode => _selectedCityCode;

  bool get isLoading => _isLoading;
  Object? get loadError => _loadError;

  Future<List<SelectionModel>> _getList(String filename) async {
    var res = await rootBundle
        .loadString("packages/psgc_picker/lib/src/assets/$filename.json");
    Iterable list = jsonDecode(res);
    return list.map((e) => SelectionModel.fromJson(e)).toList();
  }

  /// Loads the bundled region/province/city datasets and applies the
  /// initial [selectedRegion]/[selectedProvince]/[selectedCity], if given.
  /// Safe to call more than once; a call made while a load is already in
  /// flight awaits that same load rather than starting a second one.
  Future<void> load() {
    return _inFlightLoad ??= _load().whenComplete(() => _inFlightLoad = null);
  }

  Future<void> _load() async {
    _isLoading = true;
    try {
      _regionList = await _getList('region');
      _provinceList = await _getList('province');
      _cityList = await _getList('city');
    } catch (e) {
      _isLoading = false;
      _loadError = e;
      if (!_disposed) notifyListeners();
      return;
    }

    _region = _regionList;
    var selectRegion = _region.firstWhere(
        (element) => element.name == selectedRegion.trim().toUpperCase(),
        orElse: () => SelectionModel());
    if (selectRegion.code != null) {
      _selectRegionInternal(selectRegion.code!);

      var selectProvince = _province.firstWhere(
          (element) => element.name == selectedProvince.trim().toUpperCase(),
          orElse: () => SelectionModel());
      if (selectProvince.code != null) {
        _selectProvinceInternal(selectProvince.code!);
      }

      var selectCity = _city.firstWhere(
          (element) => element.name == selectedCity.trim().toUpperCase(),
          orElse: () => SelectionModel());
      if (selectCity.code != null) _selectCityInternal(selectCity.code!);
    }

    _isLoading = false;
    if (!_disposed) notifyListeners();
  }

  String? _selectRegionInternal(String value) {
    _selectedRegionCode = value;
    _province.clear();
    _selectedProvinceCode = null;
    _city.clear();
    _selectedCityCode = null;
    _province =
        _provinceList.where((element) => element.regionCode == value).toList();
    if (_province.isEmpty) {
      // NCR-style region with no distinct provinces: treat the region
      // itself as the sole "province" entry and cascade straight into it.
      _province = _region.where((element) => element.code == value).toList();
      _selectProvinceInternal(value);
    }
    var selected = _region.firstWhere((element) => element.code == value,
        orElse: () => SelectionModel());
    if (selected.name != null) onRegionChanged?.call(selected.name!);
    return selected.name;
  }

  /// Selects a region by code, filtering [provinceList] (or cascading
  /// straight to [cityList] for NCR-style regions with no distinct
  /// provinces) and clearing any downstream province/city selection.
  /// Returns the resolved region name, if any.
  String? selectRegion(String value) {
    var name = _selectRegionInternal(value);
    if (!_disposed) notifyListeners();
    return name;
  }

  String? _selectProvinceInternal(String value) {
    _selectedProvinceCode = value;
    _selectedCityCode = null;
    _city.clear();
    _city = _cityList
        .where((element) =>
            element.provinceCode == value || element.regionCode == value)
        .toList();
    var selected = _province.firstWhere((element) => element.code == value,
        orElse: () => SelectionModel());
    if (selected.name != null) onProvinceChanged?.call(selected.name!);
    return selected.name;
  }

  /// Selects a province by code, filtering [cityList] and clearing any
  /// downstream city selection. Returns the resolved province name, if any.
  String? selectProvince(String value) {
    var name = _selectProvinceInternal(value);
    if (!_disposed) notifyListeners();
    return name;
  }

  String? _selectCityInternal(String value) {
    _selectedCityCode = value;
    var selected = _city.firstWhere((element) => element.code == value,
        orElse: () => SelectionModel());
    if (selected.name != null) onCityChanged?.call(selected.name!);
    return selected.name;
  }

  /// Selects a city by code. Returns the resolved city name, if any.
  String? selectCity(String value) {
    var name = _selectCityInternal(value);
    if (!_disposed) notifyListeners();
    return name;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
