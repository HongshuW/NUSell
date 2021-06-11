import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orbital2796_nusell/providers/filtersProvider.dart';

class selectedFilters extends StatefulWidget {
  selectedFilters({Key key}) : super(key: key);

  _selectedFiltersState createState() => _selectedFiltersState();
}
class _selectedFiltersState extends State<selectedFilters> {

  @override
  Widget build(BuildContext context) {
    final selected = Provider.of<filtersProvider>(context);

    if (selected.selectedFilters.isEmpty) {
      return Container();
    } else {
      return Column(
        children: [
          Divider(color: Colors.black),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: selected.toWidgets(),
            ),
          ),
        ],
      );
    }
  }
}