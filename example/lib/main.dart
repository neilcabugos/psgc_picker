import 'package:flutter/material.dart';
import 'package:psgc_picker/psgc_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(tabs: [
            Tab(text: 'PsgcPicker'),
            Tab(text: 'Standalone fields'),
          ]),
        ),
        body: const TabBarView(
          children: [
            _PickerDemo(),
            _StandaloneFieldsDemo(),
          ],
        ),
      ),
    );
  }
}

class _PickerDemo extends StatelessWidget {
  const _PickerDemo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PsgcPicker(
        regionLabel: 'Region',
        provinceLabel: 'Province',
        cityLabel: 'City/Municipality',
        selectedRegion: 'CALABARZON',
        selectedProvince: 'RIZAL',
        selectedCity: 'CAINTA',
        spacing: 10,
        onRegionChanged: (value) => {
          // Get the selected value here
        },
        onProvinceChanged: (value) => {
          // Get the selected value here
        },
        onCityChanged: (value) => {
          // Get the selected value here
        },
      ),
    );
  }
}

/// Demonstrates placing the region/province/city dropdowns independently
/// (here, in separate Cards) instead of using [PsgcPicker]'s single fixed
/// column, by sharing one [PsgcPickerController] across them.
class _StandaloneFieldsDemo extends StatefulWidget {
  const _StandaloneFieldsDemo();

  @override
  State<_StandaloneFieldsDemo> createState() => _StandaloneFieldsDemoState();
}

class _StandaloneFieldsDemoState extends State<_StandaloneFieldsDemo> {
  late final PsgcPickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PsgcPickerController(
      selectedRegion: 'CALABARZON',
      selectedProvince: 'RIZAL',
      selectedCity: 'CAINTA',
      onRegionChanged: (value) => {
        // Get the selected value here
      },
      onProvinceChanged: (value) => {
        // Get the selected value here
      },
      onCityChanged: (value) => {
        // Get the selected value here
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PsgcRegionField(controller: _controller, label: 'Region'),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                PsgcProvinceField(controller: _controller, label: 'Province'),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PsgcCityField(
                controller: _controller, label: 'City/Municipality'),
          ),
        ),
      ],
    );
  }
}
