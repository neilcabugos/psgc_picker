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
      home: Scaffold(
        appBar: AppBar(),
        body: Padding(
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
        ),
      ),
    );
  }
}
