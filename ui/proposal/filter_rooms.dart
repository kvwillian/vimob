import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/style.dart';

class FilterRooms extends StatefulWidget {
  const FilterRooms({
    Key key,
    @required this.filterRoomsRange,
    this.onTap,
  }) : super(key: key);

  final Map<int, bool> filterRoomsRange;
  final Function(Map<int, bool>) onTap;

  @override
  _FilterRoomsState createState() => _FilterRoomsState();
}

class _FilterRoomsState extends State<FilterRooms> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          color: Colors.black12,
          padding: EdgeInsets.all(Style.horizontal(4)),
          child: Text(
            I18n.of(context).rooms,
            style: Style.mainTheme.textTheme.bodyText2
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: Style.horizontal(6)),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.filterRoomsRange.keys
                  .map(
                    (room) => Expanded(
                      child: (Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Style.horizontal(2)),
                        child: InkWell(
                          key: Key("room_$room"),
                          onTap: () {
                            setState(() {
                              widget.filterRoomsRange[room] =
                                  !widget.filterRoomsRange[room];
                            });
                            widget.onTap(widget.filterRoomsRange);
                          },
                          child: CircleAvatar(
                            radius: Style.horizontal(5),
                            backgroundColor: widget.filterRoomsRange[room]
                                ? Colors.blue
                                : Colors.grey,
                            child: Text(
                              room.toString(),
                              style: Style.mainTheme.textTheme.bodyText1,
                            ),
                          ),
                        ),
                      )),
                    ),
                  )
                  .toList()),
        )
      ],
    );
  }
}
