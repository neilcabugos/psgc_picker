import 'package:flutter_test/flutter_test.dart';
import 'package:psgc_picker/psgc_picker.dart';

// Same known PSGC entries used in test/psgc_picker_test.dart.
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
  testWidgets('load populates regionList with no widget pumped',
      (tester) async {
    late PsgcPickerController controller;
    await tester.runAsync(() async {
      controller = PsgcPickerController();
      await controller.load();
    });

    expect(controller.regionList, isNotEmpty);
    expect(controller.loadError, isNull);
    expect(controller.isLoading, isFalse);
    controller.dispose();
  });

  testWidgets('selectRegion filters provinceList', (tester) async {
    late PsgcPickerController controller;
    await tester.runAsync(() async {
      controller = PsgcPickerController();
      await controller.load();
      controller.selectRegion(_ilocosRegionCode);
    });

    expect(controller.provinceList.map((e) => e.code),
        unorderedEquals(_ilocosProvinceCodes));
    controller.dispose();
  });

  testWidgets('selectProvince filters cityList', (tester) async {
    late PsgcPickerController controller;
    await tester.runAsync(() async {
      controller = PsgcPickerController();
      await controller.load();
      controller.selectRegion(_ilocosRegionCode);
      controller.selectProvince(_ilocosNorteCode);
    });

    expect(controller.cityList.map((e) => e.code), contains(_adamsCode));
    controller.dispose();
  });

  testWidgets(
      'NCR-style region cascades straight to province and city, firing '
      'onProvinceChanged once', (tester) async {
    final provinceChanges = <String>[];
    late PsgcPickerController controller;
    await tester.runAsync(() async {
      controller = PsgcPickerController(onProvinceChanged: provinceChanges.add);
      await controller.load();
      controller.selectRegion(_ncrRegionCode);
    });

    expect(
        controller.provinceList.map((e) => e.code), equals([_ncrRegionCode]));
    expect(provinceChanges, equals([_ncrRegionName]));
    expect(controller.cityList, hasLength(_ncrCityCount));
    controller.dispose();
  });

  testWidgets('changing region resets and refilters downstream selections',
      (tester) async {
    late PsgcPickerController controller;
    await tester.runAsync(() async {
      controller = PsgcPickerController();
      await controller.load();
      controller.selectRegion(_ilocosRegionCode);
      controller.selectProvince(_ilocosNorteCode);
      controller.selectCity(_adamsCode);
    });

    expect(controller.selectedProvinceCode, _ilocosNorteCode);
    expect(controller.selectedCityCode, _adamsCode);

    await tester.runAsync(() async {
      controller.selectRegion(_cagayanValleyRegionCode);
    });

    expect(controller.provinceList.map((e) => e.code),
        unorderedEquals(_cagayanValleyProvinceCodes));
    expect(controller.selectedProvinceCode, isNull);
    expect(controller.cityList, isEmpty);
    expect(controller.selectedCityCode, isNull);
    controller.dispose();
  });

  testWidgets(
      'initial selectedRegion/selectedProvince/selectedCity resolve '
      'case-insensitively', (tester) async {
    final regionChanges = <String>[];
    final provinceChanges = <String>[];
    final cityChanges = <String>[];
    late PsgcPickerController controller;
    await tester.runAsync(() async {
      controller = PsgcPickerController(
        selectedRegion: _ilocosRegionName.toLowerCase(),
        selectedProvince: _ilocosNorteName.toUpperCase(),
        selectedCity: _adamsName,
        onRegionChanged: regionChanges.add,
        onProvinceChanged: provinceChanges.add,
        onCityChanged: cityChanges.add,
      );
      await controller.load();
    });

    expect(controller.selectedRegionCode, _ilocosRegionCode);
    expect(controller.selectedProvinceCode, _ilocosNorteCode);
    expect(controller.selectedCityCode, _adamsCode);
    expect(regionChanges, equals([_ilocosRegionName.toUpperCase()]));
    expect(provinceChanges, equals([_ilocosNorteName.toUpperCase()]));
    expect(cityChanges, equals([_adamsName.toUpperCase()]));
    controller.dispose();
  });

  testWidgets(
      'unmatched initial selection names leave lists empty '
      'without throwing', (tester) async {
    final regionChanges = <String>[];
    late PsgcPickerController controller;
    await tester.runAsync(() async {
      controller = PsgcPickerController(
        selectedRegion: 'Not A Real Region',
        selectedProvince: 'Not A Real Province',
        selectedCity: 'Not A Real City',
        onRegionChanged: regionChanges.add,
      );
      await controller.load();
    });

    expect(controller.selectedRegionCode, isNull);
    expect(controller.provinceList, isEmpty);
    expect(controller.cityList, isEmpty);
    expect(regionChanges, isEmpty);
    controller.dispose();
  });

  testWidgets(
      'each select call notifies listeners exactly once, including '
      'the NCR cascade', (tester) async {
    late PsgcPickerController controller;
    await tester.runAsync(() async {
      controller = PsgcPickerController();
      await controller.load();
    });

    var notifyCount = 0;
    controller.addListener(() => notifyCount++);

    controller.selectRegion(_ilocosRegionCode);
    expect(notifyCount, 1);
    controller.selectProvince(_ilocosNorteCode);
    expect(notifyCount, 2);
    controller.selectCity(_adamsCode);
    expect(notifyCount, 3);

    // NCR flattening cascades _selectProvinceInternal inside
    // _selectRegionInternal, but should still notify only once.
    controller.selectRegion(_ncrRegionCode);
    expect(notifyCount, 4);

    controller.dispose();
  });

  testWidgets('dispose during an in-flight load does not throw',
      (tester) async {
    final controller = PsgcPickerController();
    controller.dispose();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
  });

  testWidgets(
      'selecting an unknown/stale code is a no-op that leaves state '
      'unchanged', (tester) async {
    final regionChanges = <String>[];
    final provinceChanges = <String>[];
    final cityChanges = <String>[];
    late PsgcPickerController controller;
    await tester.runAsync(() async {
      controller = PsgcPickerController(
        onRegionChanged: regionChanges.add,
        onProvinceChanged: provinceChanges.add,
        onCityChanged: cityChanges.add,
      );
      await controller.load();
      controller.selectRegion(_ilocosRegionCode);
      controller.selectProvince(_ilocosNorteCode);
      controller.selectCity(_adamsCode);
    });
    regionChanges.clear();
    provinceChanges.clear();
    cityChanges.clear();

    var notifyCount = 0;
    controller.addListener(() => notifyCount++);

    expect(controller.selectRegion('not-a-real-code'), isNull);
    expect(controller.selectProvince('not-a-real-code'), isNull);
    expect(controller.selectCity('not-a-real-code'), isNull);

    expect(notifyCount, 0);
    expect(regionChanges, isEmpty);
    expect(provinceChanges, isEmpty);
    expect(cityChanges, isEmpty);
    expect(controller.selectedRegionCode, _ilocosRegionCode);
    expect(controller.selectedProvinceCode, _ilocosNorteCode);
    expect(controller.selectedCityCode, _adamsCode);
    controller.dispose();
  });
}
