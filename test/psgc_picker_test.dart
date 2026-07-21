import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psgc_picker/psgc_picker.dart';

// Known PSGC entries from lib/src/assets/*.json, used as fixed reference
// points so tests don't need to parse the datasets themselves.
const _ilocosRegionCode = '010000000';
const _ilocosRegionName = 'Ilocos Region';
const _ilocosProvinceCodes = [
  '012800000', // Ilocos Norte
  '012900000', // Ilocos Sur
  '013300000', // La Union
  '015500000', // Pangasinan
];
const _ilocosNorteCode = '012800000';
const _ilocosNorteName = 'Ilocos Norte';
const _adamsCode = '012801000';
const _adamsName = 'Adams';

const _cagayanValleyRegionCode = '020000000';
const _cagayanValleyProvinceCodes = [
  '020900000', // Batanes
  '021500000', // Cagayan
  '023100000', // Isabela
  '025000000', // Nueva Vizcaya
  '025700000', // Quirino
];

const _ncrRegionCode = '130000000';
const _ncrRegionName = 'NCR';
const _ncrCityCount = 17;

void main() {
  List<DropdownButton<String>> dropdowns(WidgetTester tester) => tester
      .widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>))
      .toList();

  // initState kicks off real asset I/O (rootBundle.loadString) that doesn't
  // schedule a frame while in flight, so pumpAndSettle can't detect it and
  // returns before loading finishes. The whole pump-and-poll sequence has to
  // run inside a single runAsync callback so the real Futures actually
  // progress between polls; poll rather than a single fixed delay since load
  // time varies between runs.
  Future<void> pumpPicker(
    WidgetTester tester, {
    String selectedRegion = '',
    String selectedProvince = '',
    String selectedCity = '',
    ValueChanged<String>? onRegionChanged,
    ValueChanged<String>? onProvinceChanged,
    ValueChanged<String>? onCityChanged,
  }) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PsgcPicker(
            selectedRegion: selectedRegion,
            selectedProvince: selectedProvince,
            selectedCity: selectedCity,
            onRegionChanged: onRegionChanged ?? (_) {},
            onProvinceChanged: onProvinceChanged ?? (_) {},
            onCityChanged: onCityChanged ?? (_) {},
          ),
        ),
      ));
      for (var i = 0; i < 40; i++) {
        final regionItems = dropdowns(tester)[0].items;
        if (regionItems != null && regionItems.isNotEmpty) return;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
      throw StateError(
          'PSGC data did not finish loading within the test timeout');
    });
  }

  List<String?> itemCodes(DropdownButton<String> dropdown) =>
      dropdown.items!.map((item) => item.value).toList();

  testWidgets('renders region/province/city dropdowns after loading data',
      (tester) async {
    await pumpPicker(tester);

    expect(find.byType(DropdownButton<String>), findsNWidgets(3));
    final region = dropdowns(tester)[0];
    expect(region.items, isNotEmpty);
  });

  testWidgets('selecting a region filters the province dropdown',
      (tester) async {
    await pumpPicker(tester);

    dropdowns(tester)[0].onChanged!(_ilocosRegionCode);
    await tester.pump();

    final province = dropdowns(tester)[1];
    expect(itemCodes(province), unorderedEquals(_ilocosProvinceCodes));
  });

  testWidgets('selecting a province filters the city dropdown', (tester) async {
    await pumpPicker(tester);

    dropdowns(tester)[0].onChanged!(_ilocosRegionCode);
    await tester.pump();
    dropdowns(tester)[1].onChanged!(_ilocosNorteCode);
    await tester.pump();

    final city = dropdowns(tester)[2];
    expect(itemCodes(city), contains(_adamsCode));
    expect(city.items, isNotEmpty);
  });

  testWidgets(
      'NCR-style region with no distinct provinces falls back to '
      'region-as-province and cascades straight to cities', (tester) async {
    final provinceChanges = <String>[];
    await pumpPicker(
      tester,
      onProvinceChanged: provinceChanges.add,
    );

    dropdowns(tester)[0].onChanged!(_ncrRegionCode);
    await tester.pump();

    final province = dropdowns(tester)[1];
    // The region itself becomes the sole "province" entry.
    expect(itemCodes(province), equals([_ncrRegionCode]));
    // _applyRegion cascades into _applyProvince automatically.
    expect(provinceChanges, equals([_ncrRegionName]));

    final city = dropdowns(tester)[2];
    expect(city.items, hasLength(_ncrCityCount));
  });

  testWidgets('changing region resets and refilters downstream selections',
      (tester) async {
    await pumpPicker(tester);

    dropdowns(tester)[0].onChanged!(_ilocosRegionCode);
    await tester.pump();
    dropdowns(tester)[1].onChanged!(_ilocosNorteCode);
    await tester.pump();
    dropdowns(tester)[2].onChanged!(_adamsCode);
    await tester.pump();

    expect(dropdowns(tester)[1].value, _ilocosNorteCode);
    expect(dropdowns(tester)[2].value, _adamsCode);

    dropdowns(tester)[0].onChanged!(_cagayanValleyRegionCode);
    await tester.pump();

    final province = dropdowns(tester)[1];
    final city = dropdowns(tester)[2];
    expect(itemCodes(province), unorderedEquals(_cagayanValleyProvinceCodes));
    expect(province.value, isNull);
    expect(city.items, isEmpty);
    expect(city.value, isNull);
  });

  testWidgets(
      'initial selectedRegion/selectedProvince/selectedCity names '
      'resolve case-insensitively', (tester) async {
    final regionChanges = <String>[];
    final provinceChanges = <String>[];
    final cityChanges = <String>[];
    await pumpPicker(
      tester,
      selectedRegion: _ilocosRegionName.toLowerCase(),
      selectedProvince: _ilocosNorteName.toUpperCase(),
      selectedCity: _adamsName,
      onRegionChanged: regionChanges.add,
      onProvinceChanged: provinceChanges.add,
      onCityChanged: cityChanges.add,
    );

    expect(dropdowns(tester)[0].value, _ilocosRegionCode);
    expect(dropdowns(tester)[1].value, _ilocosNorteCode);
    expect(dropdowns(tester)[2].value, _adamsCode);
    // SelectionModel.fromJson upper-cases stored names, so callbacks always
    // receive upper-case values regardless of the case passed in.
    expect(regionChanges, equals([_ilocosRegionName.toUpperCase()]));
    expect(provinceChanges, equals([_ilocosNorteName.toUpperCase()]));
    expect(cityChanges, equals([_adamsName.toUpperCase()]));
  });

  testWidgets(
      'unmatched initial selection names leave the picker unselected '
      'without throwing', (tester) async {
    final regionChanges = <String>[];
    await pumpPicker(
      tester,
      selectedRegion: 'Not A Real Region',
      selectedProvince: 'Not A Real Province',
      selectedCity: 'Not A Real City',
      onRegionChanged: regionChanges.add,
    );

    expect(find.byType(DropdownButton<String>), findsNWidgets(3));
    expect(dropdowns(tester)[0].value, isNull);
    expect(dropdowns(tester)[1].items, isEmpty);
    expect(dropdowns(tester)[2].items, isEmpty);
    expect(regionChanges, isEmpty);
  });
}
