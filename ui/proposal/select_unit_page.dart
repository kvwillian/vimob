import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/block.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/development/unit.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/proposal/unit_card.dart';
import 'package:vimob/ui/proposal/unit_filter_page.dart';
import 'package:vimob/utils/animation/widget_animation.dart';

class SelectUnitPage extends StatefulWidget {
  const SelectUnitPage({
    Key key,
    @required this.development,
  }) : super(key: key);

  final Development development;

  @override
  _SelectUnitPageState createState() => _SelectUnitPageState();
}

class _SelectUnitPageState extends State<SelectUnitPage>
    with SingleTickerProviderStateMixin {
  int dropdownValue;

  @override
  Widget build(BuildContext context) {
    var developmentState = Provider.of<DevelopmentState>(context);

    return Scaffold(
      appBar: AppBarResponsive().show(
        context: context,
        title: I18n.of(context).newProposal,
        leading: InkWell(
          key: Key("exit_unit_page_button"),
          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Icon(
            Icons.close,
            color: Style.mainTheme.appBarTheme.iconTheme.color,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Style.horizontal(2)),
            child: InkWell(
              key: Key("filter_units_button"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UnitFilterPage(
                      developmentState:
                          Provider.of<DevelopmentState>(context, listen: false),
                    ),
                  ),
                );
              },
              child: SvgPicture.asset(
                "assets/common/filter_outline.svg",
                width: Style.horizontal(5),
                color: Style.mainTheme.appBarTheme.iconTheme.color,
              ),
            ),
          ),
        ],
      ),
      body: WidgetAnimation(
        child: Container(
          height: Style.vertical(100),
          color: Colors.black.withAlpha(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSubtitle(context),
              StreamBuilder<DevelopmentUnit>(
                  stream: developmentState.currentDevelopmentUnit,
                  builder: (context, developmentUnit) {
                    if (developmentUnit.hasData) {
                      return Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  left: Style.horizontal(8),
                                  right: Style.horizontal(8),
                                  top: Style.horizontal(2)),
                              child: Wrap(
                                children: <Widget>[
                                  _buildDevelopmentName(
                                      widget.development.name),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: Style.horizontal(2)),
                                    child: Text(
                                      I18n.of(context).blocks,
                                      style:
                                          Style.mainTheme.textTheme.bodyText2,
                                    ),
                                  ),
                                  developmentUnit.data.blocks != null
                                      ? _buildBlockSelection(
                                          developmentUnit.data.blocks)
                                      : DropdownButtonFormField<String>(
                                          items: [
                                            DropdownMenuItem<String>(
                                              value: "",
                                              child: Text(
                                                "",
                                                style: Style.mainTheme.textTheme
                                                    .bodyText2,
                                              ),
                                            )
                                          ],
                                          value: "",
                                          onChanged: (value) {},
                                        ),
                                ],
                              ),
                            ),
                            developmentUnit.data.blocks != null
                                ? FutureBuilder<Iterable<Unit>>(
                                    future: developmentState
                                        .currentDevelopmentUnit.value.blocks
                                        .firstWhere((block) =>
                                            block.externalId == dropdownValue)
                                        .units,
                                    builder: (context, units) {
                                      if (!units.hasData)
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              top: Style.vertical(8.0)),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      return _buildGridView(units.data);
                                    })
                                : Padding(
                                    padding: EdgeInsets.only(
                                        top: Style.vertical(8.0)),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                          ],
                        ),
                      );
                    } else {
                      return Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildDevelopmentName(String name) {
    return Padding(
      padding: EdgeInsets.only(bottom: Style.horizontal(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: Style.titleSecondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildBlockSelection(List<Block> blocks) {
    List<DropdownMenuItem<int>> dropdownValues;
    if (blocks != null) {
      dropdownValues = blocks
          .where((block) => block.active)
          .map<DropdownMenuItem<int>>((Block block) {
        return DropdownMenuItem<int>(
          value: block.externalId,
          child: Text(
            block.name,
            style: Style.mainTheme.textTheme.bodyText2,
          ),
        );
      }).toList();

      if (dropdownValue == null) {
        dropdownValue = dropdownValues.first.value;
        ProposalState().selectedBlock = blocks
            ?.where((block) => block.externalId == dropdownValues.first.value)
            ?.first;
      }
    }

    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
          ),
          value: dropdownValue,
          onChanged: (int newValue) {
            ProposalState().selectedBlock =
                blocks.where((block) => block.externalId == newValue).first;
            setState(() {
              dropdownValue = newValue;
            });
          },
          items: dropdownValues),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Style.horizontal(3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: InkWell(
                key: Key("arrow_back"),
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
            Expanded(
                flex: 5, child: Center(child: Text(I18n.of(context).units))),
            Spacer()
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(Iterable<Unit> unitList) {
    var floors = Map<int, List<Unit>>();

    if (unitList != null && dropdownValue != null) {
      unitList.forEach((unit) {
        if (floors.containsKey(unit.floor)) {
          floors[unit.floor].add(unit);
          floors[unit.floor].sort((a, b) => a.name.compareTo(b.name));
        } else {
          floors[unit.floor] = [unit];
        }
      });

      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            top: Style.horizontal(4),
          ),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: Style.horizontal(8),
            ),
            children: floors.keys
                .map((floor) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        widget.development.type != "land"
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: Style.horizontal(4)),
                                child: Text(
                                  "$floorº ${I18n.of(context).floor}",
                                  style: Style.mainTheme.textTheme.bodyText2
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              )
                            : Container(),
                        GridView.count(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          primary: false,
                          crossAxisCount: 4,
                          children: floors[floor]
                              .map((unit) => new UnitCard(
                                    unit: unit,
                                  ))
                              .toList(),
                        ),
                      ],
                    ))
                .toList()
                .reversed
                .toList(),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
