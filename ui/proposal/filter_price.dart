import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/filter/filter.dart';
import 'package:vimob/style.dart';

class FilterPrice extends StatefulWidget {
  const FilterPrice({
    Key key,
    @required this.filterPriceRange,
    this.onChangeEnd,
  }) : super(key: key);

  final Map<FilterRange, double> filterPriceRange;
  final Function(Map<FilterRange, double>) onChangeEnd;

  @override
  _FilterPriceState createState() => _FilterPriceState();
}

class _FilterPriceState extends State<FilterPrice> {
  double _min;
  double _max;
  @override
  void initState() {
    super.initState();
    _min = widget.filterPriceRange[FilterRange.currentMin];
    _max = widget.filterPriceRange[FilterRange.currentMax];
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
            I18n.of(context).filterPrice,
            style: Style.mainTheme.textTheme.bodyText2
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: Style.horizontal(4)),
          child: Text(
            "R\$ ${I18n.of(context).formatCurrency(_min.floorToDouble())} - R\$ ${I18n.of(context).formatCurrency(_max)}",
            style: Style.mainTheme.textTheme.headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Style.horizontal(8)),
          child: RangeSlider(
              min: widget.filterPriceRange[FilterRange.min],
              max: widget.filterPriceRange[FilterRange.max],
              values: RangeValues(_min, _max),
              onChangeEnd: (_currentRange) {
                widget.onChangeEnd({
                  FilterRange.currentMax: _currentRange.end,
                  FilterRange.currentMin: _currentRange.start,
                  FilterRange.max: widget.filterPriceRange[FilterRange.max],
                  FilterRange.min: widget.filterPriceRange[FilterRange.min],
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
