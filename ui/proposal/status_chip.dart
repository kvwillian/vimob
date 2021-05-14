import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/style.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    Key key,
    @required this.status,
  }) : super(key: key);

  final String status;

  @override
  Widget build(BuildContext context) {
    var companyStatuses = Provider.of<CompanyState>(context).companyStatuses;

    if (companyStatuses.proposals.containsKey(status)) {
      return Container(
        key: Key("status_chip_background"),
        decoration: BoxDecoration(
            color: companyStatuses.proposals[status].color ?? Colors.white,
            borderRadius:
                BorderRadius.all(Radius.circular(Style.horizontal(4)))),
        padding: EdgeInsets.symmetric(
            horizontal: Style.horizontal(4), vertical: Style.horizontal(1)),
        child: Text(
          I18n.of(context).translateStatus(
              companyStatusConfig: companyStatuses.proposals[status]),
          textAlign: TextAlign.center,
          style: Style.mainTheme.textTheme.bodyText1
              .copyWith(fontWeight: FontWeight.bold),
          key: Key("status_chip_text"),
        ),
      );
    } else {
      return Container(
        key: Key("status_chip_invisible"),
      );
    }
  }
}
