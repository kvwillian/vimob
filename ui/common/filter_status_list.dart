import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/filter/filter.dart';
import 'package:vimob/style.dart';

class FilterStatusList extends StatelessWidget {
  const FilterStatusList({
    Key key,
    @required this.filterStatus,
    this.updateFilterStatus,
  }) : super(key: key);

  final Map<String, StatusFilter> filterStatus;
  final Function(bool, String) updateFilterStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      // shrinkWrap: true,
      children: <Widget>[
        Container(
          width: double.infinity,
          color: Colors.black12,
          padding: EdgeInsets.all(Style.horizontal(4)),
          child: Text(
            I18n.of(context).filterStatus,
            style: Style.mainTheme.textTheme.bodyText2
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        ...filterStatus.keys.map((key) {
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Style.horizontal(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          filterStatus[key].status,
                          style: Style.mainTheme.textTheme.headline6
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(filterStatus[key].amount.toString()),
                      ],
                    ),
                    Transform.scale(
                      scale: Style.horizontal(0.3),
                      child: Checkbox(
                          key: Key("check_box_$key"),
                          value: filterStatus[key].selected,
                          onChanged: (selected) {
                            if (filterStatus[key].amount > 0) {
                              updateFilterStatus(selected, key);
                            }
                          }),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey,
              )
            ],
          );
        }).toList(),
      ],
    );
  }
}
