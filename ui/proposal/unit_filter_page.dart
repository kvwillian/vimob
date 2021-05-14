import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/filter/filter.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/common/filter_status_list.dart';
import 'package:vimob/ui/proposal/filter_area.dart';
import 'package:vimob/ui/proposal/filter_price.dart';
import 'package:vimob/ui/proposal/filter_rooms.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';

class UnitFilterPage extends StatefulWidget {
  UnitFilterPage({
    Key key,
    this.developmentState,
  }) : super(key: key);

  final DevelopmentState developmentState;

  @override
  _UnitFilterPageState createState() => _UnitFilterPageState();
}

class _UnitFilterPageState extends State<UnitFilterPage> {
  var _filterAreaRange = Map<FilterRange, double>();
  var _filterPriceRange = Map<FilterRange, double>();
  var _filterRoomsRange = Map<int, bool>();

  @override
  void initState() {
    super.initState();

    _filterAreaRange = widget.developmentState.filterAreaRange;
    _filterPriceRange = widget.developmentState.filterPriceRange;
    _filterRoomsRange = widget.developmentState.filterRoomsRange;
  }

  @override
  Widget build(BuildContext context) {
    var _developmentState = Provider.of<DevelopmentState>(context);

    return Scaffold(
      appBar: AppBarResponsive().show(
          context: context,
          leading: InkWell(
            key: Key("exit_filter_button"),
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.close,
              color: Style.mainTheme.appBarTheme.iconTheme.color,
            ),
          ),
          title: I18n.of(context).searchFilter,
          actions: <Widget>[
            RaisedButton(
              key: Key("clean_filter_button"),
              textColor: Colors.white,
              padding: EdgeInsets.all(Style.horizontal(1)),
              color: Style.buttonCleanFilterColor,
              onPressed: () {
                _developmentState.cleanFilter();
                setState(() {
                  _filterAreaRange = widget.developmentState.filterAreaRange;
                  _filterPriceRange = widget.developmentState.filterPriceRange;
                  _filterRoomsRange = widget.developmentState.filterRoomsRange;
                });
              },
              child: Text(
                I18n.of(context).cleanFilter,
                style: Style.mainTheme.textTheme.button,
              ),
            )
          ]),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.only(bottom: Style.horizontal(15)),
            // shrinkWrap: true,
            children: <Widget>[
              FilterStatusList(
                filterStatus: _developmentState.filterStatus,
                updateFilterStatus: (selected, key) => _developmentState
                    .updateFilterStatus(key: key, selected: selected),
              ),
              FilterRooms(
                filterRoomsRange: _developmentState.filterRoomsRange,
                onTap: (rooms) {
                  setState(() {
                    _filterRoomsRange = rooms;
                  });
                },
              ),
              FilterPrice(
                filterPriceRange: _developmentState.filterPriceRange,
                onChangeEnd: (_currentRange) {
                  setState(() {
                    _filterPriceRange = _currentRange;
                  });
                },
              ),
              FilterArea(
                filterAreaRange: _developmentState.filterAreaRange,
                onChangeEnd: (_currentRange) {
                  setState(() {
                    _filterAreaRange = _currentRange;
                  });
                },
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: -1,
            child: SizedBox(
              width: Style.horizontal(102),
              height: Style.horizontal(13),
              child: RaisedButton(
                key: Key("apply_filter_button"),
                padding: EdgeInsets.all(0),
                textColor: Style.textButtonColorPrimary,
                onPressed: () {
                  _developmentState.updateFilterRooms(
                      newfilterRoomsRange: _filterRoomsRange);

                  _developmentState.updateFilterPrice(
                      newfilterPriceRange: _filterPriceRange);

                  _developmentState.updateFilterArea(
                      newfilterAreaRange: _filterAreaRange);

                  _developmentState.applyFilter(
                    filterAreaRange: _filterAreaRange,
                    filterPriceRange: _filterPriceRange,
                    filterRoomsRange: _filterRoomsRange,
                    filterStatus: _developmentState.filterStatus,
                  );
                  Navigator.pop(context);
                  ShowSnackbar()
                      .showSnackbarSuccess(context, "Filtro aplicado");
                },
                child: Text(I18n.of(context).applyFilter.toUpperCase()),
              ),
            ),
          )
        ],
      ),
    );
  }
}
