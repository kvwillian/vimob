import 'package:flutter/material.dart';
import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/style.dart';

class BuyerCard extends StatelessWidget {
  const BuyerCard({
    Key key,
    @required this.buyer,
    this.onTap,
  }) : super(key: key);

  final Buyer buyer;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Style.horizontal(4), vertical: Style.horizontal(1)),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: Style.horizontal(2)),
                  child: CircleAvatar(
                      radius: Style.horizontal(5),
                      child: Text(
                        buyer.name[0],
                        style: Style.mainTheme.textTheme.bodyText1,
                      )),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      buyer.name,
                      style: Style.mainTheme.textTheme.bodyText2
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(buyer.cpf),
                  ],
                )
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
