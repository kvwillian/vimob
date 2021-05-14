import 'package:flutter/material.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/web_view_page.dart';
import 'package:vimob/ui/proposal/select_unit_page.dart';
import 'package:vimob/ui/proposal/unit_detail_dialog.dart';

class DevelopmentMap extends StatelessWidget {
  const DevelopmentMap({
    Key key,
    @required this.development,
    @required this.userId,
    @required this.devId,
  }) : super(key: key);

  final Development development;
  final String userId;
  final String devId;

  @override
  Widget build(BuildContext context) {
    return WebViewPage(
      onWebViewCreated: (webViewController) {
        DevelopmentState().developmentMapWebViewController = webViewController;
      },
      fullscreen: false,
      url:
          "${CompanyState().urlMap}/vendas/espelhomapaapp.aspx?userId=$userId&devId=$devId",
      title: "Mapa",
      action: [
        Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: InkWell(
            child: Icon(
              Icons.grid_on,
              color: Style.mainTheme.appBarTheme.actionsIconTheme.color,
              size: Style.mainTheme.appBarTheme.actionsIconTheme.size,
            ),
            onTap: () async {
              openSelectUnitPage(development, context);
            },
          ),
        ),
      ],
      onPageStarted: (url) async {
        print(url);
        ProposalState().selectedDevelopment = development;

        if (url.contains("und=")) {
          var unitExternalId = url.split("und=").last;
          if (unitExternalId != null) {
            var futureUnitList = DevelopmentState()
                .currentDevelopmentUnit
                .value
                .blocks
                .map((e) => e.units);
            var unitList = await Future.wait(futureUnitList);
            var units = unitList.expand((unit) => unit);
            ProposalState().selectedUnit = units.firstWhere(
                (unit) => unit.externalId.toString() == unitExternalId);

            if (ProposalState().selectedUnit != null) {
              ProposalState().selectedBlock = DevelopmentState()
                  .currentDevelopmentUnit
                  .value
                  .blocks
                  .firstWhere((block) =>
                      ProposalState().selectedUnit.block.id == block.id);
            }

            if (ProposalState().selectedUnit != null) {
              await PaymentState().fetchPaymentsList();
              await showDialog(
                  context: context,
                  builder: (context) => UnitDetailDialog(
                        unit: ProposalState().selectedUnit,
                      ));
            }
            //
          }
        }
      },
    );
  }

  Future openSelectUnitPage(
      Development development, BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return SelectUnitPage(
          development: development,
        );
      }),
    );
  }
}
