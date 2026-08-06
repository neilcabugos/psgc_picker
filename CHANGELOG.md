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
