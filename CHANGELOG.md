# Changelog

## [1.1.2](https://github.com/neilcabugos/psgc_picker/compare/1.1.1...1.1.2) (2026-08-18)


### Bug Fixes

* exclude package-name component from release-please tags ([#30](https://github.com/neilcabugos/psgc_picker/issues/30)) ([473202c](https://github.com/neilcabugos/psgc_picker/commit/473202ccec673730f924d6c7805cabbf55d79fe8))
* guard notifyListeners with disposed check in selectors ([#23](https://github.com/neilcabugos/psgc_picker/issues/23)) ([f792873](https://github.com/neilcabugos/psgc_picker/commit/f792873fa56593e04bf7a75cb74521be13159324))
* make load() idempotent after a successful completion ([#26](https://github.com/neilcabugos/psgc_picker/issues/26)) ([ddc61f0](https://github.com/neilcabugos/psgc_picker/commit/ddc61f016ba266787d7f8b6f73327762776b9906))
* use plain version tags/release names for release-please ([#28](https://github.com/neilcabugos/psgc_picker/issues/28)) ([4ee7a41](https://github.com/neilcabugos/psgc_picker/commit/4ee7a411908317158bf3b483fc9f72a435086489))
* validate selector codes against current list ([#25](https://github.com/neilcabugos/psgc_picker/issues/25)) ([af4e695](https://github.com/neilcabugos/psgc_picker/commit/af4e695d9aa9c1fc9afc7f40e0198f76e53bc219))

## [1.1.1](https://github.com/neilcabugos/psgc_picker/compare/psgc_picker-v1.1.0...psgc_picker-v1.1.1) (2026-08-18)


### Bug Fixes

* guard notifyListeners with disposed check in selectors ([#23](https://github.com/neilcabugos/psgc_picker/issues/23)) ([f792873](https://github.com/neilcabugos/psgc_picker/commit/f792873fa56593e04bf7a75cb74521be13159324))
* make load() idempotent after a successful completion ([#26](https://github.com/neilcabugos/psgc_picker/issues/26)) ([ddc61f0](https://github.com/neilcabugos/psgc_picker/commit/ddc61f016ba266787d7f8b6f73327762776b9906))
* validate selector codes against current list ([#25](https://github.com/neilcabugos/psgc_picker/issues/25)) ([af4e695](https://github.com/neilcabugos/psgc_picker/commit/af4e695d9aa9c1fc9afc7f40e0198f76e53bc219))

## 1.1.0
### What's Changed
- Added `PsgcPickerController`, which owns PSGC data loading and cascading selection state independently of any particular widget layout
- Added `PsgcRegionField`, `PsgcProvinceField`, and `PsgcCityField` — standalone dropdowns that bind to a shared `PsgcPickerController` and can be placed anywhere in the widget tree, instead of only as a single fixed `PsgcPicker` column
- Exported `SelectionModel`, needed to reference the type returned by the controller's list getters
- `PsgcPicker` itself is unchanged and now implemented as a thin wrapper around the new controller/fields — fully backward compatible

## 1.0.3
### What's Changed
- Widened Dart SDK constraint to support Dart 3 (previously capped below 3.0.0)
- Hardened asset loading: a failed/malformed JSON load now surfaces as an inline error instead of throwing
- Guarded lookups against unmatched selections instead of throwing (e.g. `firstWhere` on no match)
- Case-insensitive, whitespace-trimmed matching for initial `selectedRegion`/`selectedProvince`/`selectedCity` names, with a `mounted` guard around the async initial-selection flow
- Deduplicated redundant `setState` calls during cascading selection
- Added a real widget test suite (previously untested) and CI workflow
- Corrected package description/README to accurately reflect scope (dropped the inaccurate "municipality, and barangay" claim)
- Bumped `flutter_lints` to 6.x and trimmed non-source files from the published package via `.pubignore`

## 1.0.2
### What's Changed
Added selected values and uppercase text selection
#### Breaking changes
With the current implementation of uppercase selection text. This changes might affect the use of selected values, the dropdown will select nothing because the text is different from the updated one. Even though this effect can be eliminate from our side, we decided to fix it on the next release.

## 1.0.1

- Display region, province, city/municipality dropdown
- Dependent display of list based on selection
- Return string value of the selected item
