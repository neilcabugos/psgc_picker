## PSGC Picker

This package is used for listing all the region, province, city, municipality, and barangay. Philippine Standard Geographic Codes

### Usage
```
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Package Testing',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(),
          body: Center(
            child: PsgcPicker(
              regionLabel: 'Region',
              provinceLabel: 'Province',
              cityLabel: 'City/Municipality',
              spacing: 5,
              onRegionChanged: (value) => {print(value)},
              onProvinceChanged: (value) => {print(value)},
              onCityChanged: (value) => {print(value)},
            ),
          ),
        ));
  }
}
```