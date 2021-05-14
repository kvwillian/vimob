import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/filter/filter.dart';
import 'package:vimob/style.dart';

class FilterArea extends StatefulWidget {
  const FilterArea({
    Key key,
    @required this.filterAreaRange,
    this.onChangeEnd,
  }) : super(key: key);

  final Map<FilterRange, double> filterAreaRange;
  final Function(Map<FilterRange, double>) onChangeEnd;

  @override
  _FilterAreaState createState() => _FilterAreaState();
}

class _FilterAreaState extends State<FilterArea> {
  double _min;
  double _max;
  @override
  void initState() {
    super.initState();
    _min = widget.filterAreaRange[FilterRange.currentMin];
    _max = widget.filterAreaRange[FilterRange.currentMax];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          color: Colors.black12,
          padding: EdgeInsets.all(Style.horizontal(4)),
          child: Text(
            I18n.of(context).filterArea,
            style: Style.mainTheme.textTheme.bodyText2
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: Style.horizontal(4)),
          child: Text(
            "${_min.round()}m² - ${_max.round()}m²",
            style: Style.mainTheme.textTheme.headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Style.horizontal(8)),
          child: RangeSlider(
              min: widget.filterAreaRange[FilterRange.min],
              max: widget.filterAreaRange[FilterRange.max],
              values: RangeValues(_min, _max),
              onChangeEnd: (_currentRange) {
                widget.onChangeEnd({
                  FilterRange.currentMax: _currentRange.end,
                  FilterRange.currentMin: _currentRange.start,
                  FilterRange.max: widget.filterAreaRange[FilterRange.max],
                  FilterRange.min: widget.filterAreaRange[FilterRange.min],
                });
              },
              onChanged: (_currentRange) {
                setState(() {
                  _min = _currentRange.start;
                  _max = _currentRange.end;
                });
              }),
        )
      ],
    );
  }
}
