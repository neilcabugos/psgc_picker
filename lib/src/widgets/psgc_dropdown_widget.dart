import 'package:flutter/material.dart';

class PsgcDropdownWidget extends StatelessWidget {
  const PsgcDropdownWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(contentPadding: EdgeInsets.all(0.0)), // Todo: Add this as parameter
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          items: const [
            DropdownMenuItem(
              child: Text('Select an item') // Todo: Add this as paramter
            )
          ],
          onChanged: (value) => {},
        )
      ),
    );
  }
}