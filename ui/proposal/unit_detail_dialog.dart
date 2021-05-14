import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/development/development_bloc.dart';
import 'package:vimob/blocs/proposal/proposal_bloc.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/models/development/block.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/unit.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/booking/booking_page.dart';
import 'package:vimob/ui/payment/select_payment_plan_page.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';
import 'package:vimob/utils/widgets/confirmation_dialog.dart';
import 'package:vimob/utils/widgets/success_feedback_page.dart';

class UnitDetailDialog extends StatefulWidget {
  const UnitDetailDialog({
    Key key,
    @required this.unit,
  }) : super(key: key);

  final Unit unit;

  @override
  _UnitDetailDialogState createState() => _UnitDetailDialogState();
}

class _UnitDetailDialogState extends State<UnitDetailDialog> {
  Timer _timer;

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthenticationState>(context);

    return Dialog(
      child: Container(
        height: Style.horizontal(100),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                width: double.infinity,
                color: Provider.of<CompanyState>(context, listen: false)
                    .companyStatuses
                    .units[widget.unit.status]
                    .color,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Style.horizontal(2),
                      horizontal: Style.horizontal(4)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: Style.horizontal(2)),
                        child: Text(
                          widget.unit.type == "land"
                              ? "${I18n.of(context).land} ${widget.unit.name}"
                              : "${I18n.of(context).unit} ${widget.unit.name}",
                          style: Style.mainTheme.appBarTheme.textTheme.headline6
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: Style.horizontal(7),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.only(top: Style.horizontal(4)),
                  child: Wrap(
                    children: <Widget>[
                      buildUnitDetail(
                          context,
                          I18n.of(context).status,
                          I18n.of(context).translateStatus(
                              companyStatusConfig: Provider.of<CompanyState>(
                                      context,
                                      listen: false)
                                  .companyStatuses
                                  .units[widget.unit.status])),
                      buildUnitDetail(context, I18n.of(context).price,
                          "R\$ ${NumberFormat.currency(locale: "pt_BR", decimalDigits: 2, name: "").format(widget.unit.price).trim()}"),
                      buildUnitDetail(context, I18n.of(context).block,
                          widget.unit.block.name),
                      buildUnitDetail(context, I18n.of(context).typology,
                          widget.unit.typology),
                      widget.unit.type == "land"
                          ? Container()
                          : buildUnitDetail(context, I18n.of(context).rooms,
                              widget.unit.room.toString()),
                      buildUnitDetail(context, I18n.of(context).totalArea,
                          "${widget.unit.area.privateSquareMeters.toStringAsFixed(2)} m²"),
                    ],
                  ),
                )),
            (widget.unit.status == "available" ||
                        widget.unit.status == "inAttendance" ||
                        widget.unit.status == "avaliation" ||
                        (widget.unit.status == "reserved" &&
                            widget.unit.reservedBy ==
                                AuthenticationState().user.uid)) &&
                    widget.unit.price != 0
                ? Padding(
                    padding: EdgeInsets.only(bottom: Style.horizontal(4)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        (widget.unit.status != "reserved")
                            ? (AuthenticationState()
                                    .user
                                    .userPermissions
                                    .reserveEnabled)
                                ? buildReserveUnitButton(context)
                                : Container()
                            : buildReleaseUnitButton(context),
                        buildSelectButton(context)
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Align buildSelectButton(BuildContext context) {
    return Align(
      alignment: Alignment(0, 0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width *
            (AuthenticationState().user.userPermissions.reserveEnabled ||
                    widget.unit.reservedBy == AuthenticationState().user.uid
                ? 0.33
                : 0.66),
        child: RaisedButton(
          textColor: Style.textButtonColorPrimary,
          color: Colors.blueAccent,
          child: Text(
            I18n.of(context).select.toUpperCase(),
          ),
          onPressed: () async {
            ProposalState().selectedUnit = widget.unit;
            await PaymentState().fetchPaymentsList();

            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return SelectPaymentPlanPage(
                    paymentState: Provider.of<PaymentState>(context));
              }),
            );
          },
        ),
      ),
    );
  }

  Padding buildReserveUnitButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: Style.horizontal(4)),
      child: Align(
        alignment: Alignment(0, 0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.33,
          child: OutlineButton(
            borderSide:
                BorderSide(color: Style.mainTheme.primaryColor, width: 2),
            textColor: Style.textButtonColorPrimary,
            color: Colors.blueAccent,
            child: Text(
              I18n.of(context).reserve.toUpperCase(),
              style: Style.mainTheme.textTheme.bodyText1
                  .copyWith(color: Style.mainTheme.primaryColor),
            ),
            onPressed: () async {
              if (ConnectivityState().hasInternet) {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookingPage(
                              unit: widget.unit,
                            )));
              } else {
                ShowSnackbar().showSnackbarError(
                    context, I18n.of(context).checkConnection);
              }
            },
          ),
        ),
      ),
    );
  }

  Padding buildReleaseUnitButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: Style.horizontal(4)),
      child: Align(
        alignment: Alignment(0, 0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.33,
          child: OutlineButton(
            borderSide:
                BorderSide(color: Style.mainTheme.primaryColor, width: 2),
            textColor: Style.textButtonColorPrimary,
            color: Colors.blueAccent,
            child: Text(
              I18n.of(context).releaseUnit.toUpperCase(),
              style: Style.mainTheme.textTheme.bodyText1
                  .copyWith(color: Style.mainTheme.primaryColor),
            ),
            onPressed: () async {
              await showDialog(
                barrierDismissible: false,
                builder: (context) => ConfirmationDialog(
                  onTap: () async {
                    if (ConnectivityState().hasInternet) {
                      await _cancelRequest(context);
                    } else {
                      ShowSnackbar().showSnackbarError(
                          context, I18n.of(context).checkConnection);
                    }
                  },
                  text: I18n.of(context).confirmReleaseText,
                  title: I18n.of(context).confirmRelease,
                ),
                context: context,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildUnitDetail(BuildContext context, String info, String data) {
    return Padding(
      padding: EdgeInsets.all(Style.horizontal(2)),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: Style.horizontal(4.0), bottom: Style.horizontal(1.5)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    info,
                    textAlign: TextAlign.left,
                    style: Style.mainTheme.textTheme.bodyText2
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    data,
                    style: Style.mainTheme.textTheme.bodyText2,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
        ],
      ),
    );
  }

  Future _cancelRequest(BuildContext context) async {
    User user = AuthenticationState().user;

    Company company = user.companies[user.company];

    Block block = DevelopmentState()
        .currentDevelopmentUnit
        .value
        .blocks
        .firstWhere((b) => b.id == widget.unit.block.id);

    DevelopmentReference development =
        DevelopmentState().currentDevelopmentUnit.value.development;

    try {
      Stream<DocumentSnapshot> response = await DevelopmentBloc()
          .releaseReserveRequest(
              user, widget.unit, block, development, company);

      StreamSubscription<DocumentSnapshot> streamResponse;

      _timer = Timer.periodic(Duration(seconds: 10), (timer) {
        ShowSnackbar()
            .showSnackbarError(context, I18n.of(context).reserveErrorText);

        DevelopmentBloc().deleteBookingRequest(widget.unit.id);

        print("timeout");
        _timer.cancel();
      });

      if (response != null) {
        streamResponse = response.listen((snapshotDoc) async {
          if (snapshotDoc.exists) {
            switch (snapshotDoc.data()['synchronized']) {
              case 'success':
                ProposalBloc().updateUnit(widget.unit.id, "available", null);
                ProposalBloc().updateUnitDevelopmentUnits(
                    company.id,
                    development.id,
                    widget.unit,
                    "available",
                    DevelopmentState().currentDevelopmentUnit.value.blocks,
                    reservedBy: null);

                streamResponse.cancel();

                _timer.cancel();

                DevelopmentBloc().deleteBookingRequest(widget.unit.id);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SuccessFeedbackPage(
                              message: I18n.of(context).releaseSuccessText,
                              onTimeEnd: () {
                                int count = 0;
                                Navigator.of(context)
                                    .popUntil((_) => count++ >= 3);
                              },
                            )));

                DevelopmentState().mapRefresh();
                break;
              case 'error':
                ShowSnackbar().showSnackbarError(
                    context, I18n.of(context).reserveErrorText);

                DevelopmentBloc().deleteBookingRequest(widget.unit.id);
                break;
              case 'pending':
                Navigator.pop(context);
                await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          child: Container(
                            height: Style.horizontal(45),
                            width: Style.horizontal(80),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ));
                break;
              default:
            }
          }
        });
      } else {
        print("response null");

        ShowSnackbar()
            .showSnackbarError(context, I18n.of(context).reserveErrorText);
      }
    } catch (e) {
      print(e.toString());
      ShowSnackbar()
          .showSnackbarError(context, I18n.of(context).reserveErrorText);

      // setState(() {
      //   _isLoading = 'error';
      // });
    }
  }
}
