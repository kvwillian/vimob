import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:vimob/blocs/development/development_bloc.dart';
import 'package:vimob/blocs/proposal/proposal_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/models/development/block.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/development/unit.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/buyer_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/text_field_custom.dart';
import 'package:vimob/ui/clients/buyer_card.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';
import 'package:vimob/utils/widgets/success_feedback_page.dart';

class BookingPage extends StatefulWidget {
  BookingPage({Key key, @required this.unit}) : super(key: key);

  final Unit unit;

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  FieldStatus _descriptionController;
  FieldStatus _buyerController;
  Buyer _selectedBuyer;
  Timer _timer;
  String _isLoading = "success";
  DateTime _reserveValidityDate;

  @override
  void initState() {
    _descriptionController = FieldStatus()
      ..controller = TextEditingController();
    _buyerController = FieldStatus()..controller = TextEditingController();

    if (ProposalState().selectedDevelopment.reserveValidity != null) {
      _reserveValidityDate = DateTime.now().add(
          Duration(hours: ProposalState().selectedDevelopment.reserveValidity));
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBarResponsive().show(
        context: context,
        title: I18n.of(context).reserve,
        actions: [
          _isLoading == 'pending'
              ? CircularProgressIndicator(
                  valueColor: Style.loadingColor,
                )
              : InkWell(
                  child: Icon(
                    Icons.check,
                    color: Style.mainTheme.appBarTheme.actionsIconTheme.color,
                    size: Style.mainTheme.appBarTheme.actionsIconTheme.size,
                  ),
                  onTap: () async {
                    await _request(context);
                  },
                )
        ],
        leading: InkWell(
          key: Key("exit_select_payment_plan_page_button"),
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.close,
            color: Style.mainTheme.appBarTheme.iconTheme.color,
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Style.horizontal(4)),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: Style.vertical(8), bottom: Style.vertical(4)),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/common/grey_calendar.svg",
                      width: Style.horizontal(50),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: Style.horizontal(8)),
                  child: _reserveValidityDate != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              I18n.of(context).validUntil,
                              style: Style.mainTheme.textTheme.bodyText2
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              I18n.of(context).formatDate(
                                  date: Jiffy(_reserveValidityDate),
                                  customFormat: "dd/MM/yyyy"),
                              style: Style.textHighlightBold,
                            ),
                          ],
                        )
                      : Container(),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFieldCustom(
                        controller: _buyerController.controller,
                        label:
                            "${I18n.of(context).client} (${I18n.of(context).optional})",
                        textInputType: TextInputType.multiline,
                        readOnly: true,
                        icon: Icon(
                          Icons.person,
                          size: Style.iconSize,
                        ),
                        onTap: () async => await showDialog(
                            context: context,
                            builder: (context) => buildUsersDialog()),
                      ),
                    ),
                    _selectedBuyer != null
                        ? IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedBuyer = null;
                                _buyerController = FieldStatus()
                                  ..controller = TextEditingController();
                              });
                            })
                        : Container()
                  ],
                ),
                TextFieldCustom(
                  controller: _descriptionController.controller,
                  label:
                      "${I18n.of(context).description} (${I18n.of(context).optional})",
                  textInputType: TextInputType.multiline,
                  maxLines: 5,
                  verticalSize: 15,
                  icon: Icon(
                    Icons.edit,
                    size: Style.iconSize,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _descriptionController.controller.value
                          .copyWith(text: value);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _request(BuildContext context) async {
    setState(() {
      _isLoading = 'pending';
    });

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
      if (!await DevelopmentBloc().isUnitAvailable(widget.unit.id) ||
          !AuthenticationState().user.userPermissions.reserveEnabled) {
        throw Error();
      }

      Stream<DocumentSnapshot> response = await DevelopmentBloc()
          .bookingRequest(user, widget.unit, block, development, company,
              _descriptionController.controller.text, _selectedBuyer);

      StreamSubscription<DocumentSnapshot> streamResponse;

      _timer = Timer.periodic(Duration(seconds: 10), (timer) {
        setState(() {
          _isLoading = "error";
        });
        ShowSnackbar()
            .showSnackbarError(context, I18n.of(context).reserveErrorText);

        DevelopmentBloc().deleteBookingRequest(widget.unit.id);

        print("timeout");
        _timer.cancel();
      });

      if (response != null) {
        streamResponse = response.listen((snapshotDoc) {
          if (snapshotDoc.exists) {
            switch (snapshotDoc.data()['synchronized']) {
              case 'success':
                ProposalBloc().updateUnit(widget.unit.id, "reserved", user.uid);
                ProposalBloc().updateUnitDevelopmentUnits(
                    company.id,
                    development.id,
                    widget.unit,
                    "reserved",
                    DevelopmentState().currentDevelopmentUnit.value.blocks,
                    reservedBy: user.uid);

                streamResponse.cancel();

                _timer.cancel();
                setState(() {
                  _isLoading = "success";
                });

                DevelopmentBloc().deleteBookingRequest(widget.unit.id);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SuccessFeedbackPage(
                              message: I18n.of(context).reserveSuccessText,
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

                setState(() {
                  _isLoading = "error";
                });

                DevelopmentBloc().deleteBookingRequest(widget.unit.id);
                break;
              case 'pending':
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

      setState(() {
        _isLoading = 'error';
      });
    }
  }

  Dialog buildUsersDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        height: double.maxFinite,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: Style.vertical(4.0)),
              child: Text(I18n.of(context).clientList),
            ),
            Expanded(
              child: ListView(
                children: BuyerState().buyersList.value != null
                    ? BuyerState()
                        .buyersList
                        .value
                        .where((b) => b.externalId != null)
                        .map((buyer) => BuyerCard(
                              buyer: buyer,
                              onTap: () {
                                getBuyer(buyer);
                              },
                            ))
                        .toList()
                    : [
                        Container(
                          child: Center(
                            child: Text(I18n.of(context).noClientSynchronized),
                          ),
                        )
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getBuyer(Buyer buyer) {
    setState(() {
      _selectedBuyer = buyer;
      _buyerController.controller.value =
          _buyerController.controller.value.copyWith(text: buyer.name);
    });
    Navigator.pop(context);
  }
}
