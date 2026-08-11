import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psgc_picker/psgc_picker.dart';

// Same known PSGC entries used in test/psgc_picker_test.dart.
const _ilocosRegionCode = '010000000';
const _ilocosProvinceCodes = [
  '012800000', // Ilocos Norte
  '012900000', // Ilocos Sur
  '013300000', // La Union
  '015500000', // Pangasinan
];

void main() {
  // initState-driven asset I/O doesn't schedule a frame while in flight, so
  // pumpAndSettle can't detect it. Poll for the region dropdown's items
  // inside a single runAsync block, same approach as
  // test/psgc_picker_test.dart's pumpPicker helper.
  Future<void> waitForLoad(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      final region = tester
          .widgetList<DropdownButton<String>>(
              find.byType(DropdownButton<String>))
          .first;
      if (region.items != null && region.items!.isNotEmpty) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    }
    throw StateError(
        'PSGC data did not finish loading within the test timeout');
  }

  testWidgets(
      'region and province fields placed in separate subtrees stay in '
      'sync via a shared controller', (tester) async {
    late PsgcPickerController controller;
    addTearDown(() => controller.dispose());

    await tester.runAsync(() async {
      controller = PsgcPickerController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Card(child: PsgcRegionField(controller: controller)),
              Card(child: PsgcProvinceField(controller: controller)),
            ],
          ),
        ),
      ));
      await waitForLoad(tester);
    });

    final regionDropdown = tester
        .widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>))
        .first;
    regionDropdown.onChanged!(_ilocosRegionCode);
    await tester.pump();

    final provinceDropdown = tester
        .widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>))
        .last;
    expect(provinceDropdown.items!.map((e) => e.value),
        unorderedEquals(_ilocosProvinceCodes));
  });

  testWidgets('unmounting one field does not error or desync a sibling field',
      (tester) async {
    late PsgcPickerController controller;
    addTearDown(() => controller.dispose());
    var showCity = true;

    await tester.runAsync(() async {
      controller = PsgcPickerController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                PsgcRegionField(controller: controller),
                if (showCity) PsgcCityField(controller: controller),
                TextButton(
                  onPressed: () => setState(() => showCity = !showCity),
                  child: const Text('toggle'),
                ),
              ],
            ),
          ),
        ),
      ));
      await waitForLoad(tester);
    });

    expect(find.byType(DropdownButton<String>), findsNWidgets(2));

    await tester.tap(find.text('toggle'));
    await tester.pump();
    expect(find.byType(DropdownButton<String>), findsNWidgets(1));

    await tester.tap(find.text('toggle'));
    await tester.pump();
    expect(find.byType(DropdownButton<String>), findsNWidgets(2));

    final regionDropdown = tester
        .widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>))
        .first;
    expect(regionDropdown.items, isNotEmpty);
  });

  testWidgets('two region fields sharing one controller stay in sync',
      (tester) async {
    late PsgcPickerController controller;
    addTearDown(() => controller.dispose());

    await tester.runAsync(() async {
      controller = PsgcPickerController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              PsgcRegionField(controller: controller),
              PsgcRegionField(controller: controller),
            ],
          ),
        ),
      ));
      await waitForLoad(tester);
    });

    final first = tester
        .widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>))
        .first;
    first.onChanged!(_ilocosRegionCode);
    await tester.pump();

    final dropdowns = tester
        .widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>))
        .toList();
    expect(dropdowns[0].value, _ilocosRegionCode);
    expect(dropdowns[1].value, _ilocosRegionCode);
  });
}
