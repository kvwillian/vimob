import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/unit.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/unit_detail_dialog.dart';

class UnitCard extends StatelessWidget {
  UnitCard({Key key, @required this.unit}) : super(key: key);

  final Unit unit;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Style.horizontal(2)),
      ),
      elevation: 5.0,
      child: InkWell(
        onTap: () async {
          await showDialog(
              context: context,
              builder: (context) => UnitDetailDialog(unit: unit));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                direction: Axis.vertical,
                spacing: Style.horizontal(1),
                children: <Widget>[
                  Text(
                    unit.name,
                    style: Style.mainTheme.textTheme.bodyText2
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${unit.area.privateSquareMeters.toStringAsFixed(2)}m²',
                    style: Style.textMetricsUnitCard,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(7.0),
                    bottomRight: Radius.circular(7.0)),
                child: Container(
                  width: double.infinity,
                  color: Provider.of<CompanyState>(context, listen: false)
                      .companyStatuses
                      .units[unit.status]
                      .color,
                  alignment: Alignment(0.0, 0.0),
                  child: Text(
                    "${I18n.of(context).formatCurrencyCompact(unit.price)}",
                    style: Style.mainTheme.textTheme.bodyText1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
