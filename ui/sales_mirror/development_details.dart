import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/company/company_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/common/web_view_page.dart';
import 'package:vimob/ui/map/development_map.dart';
import 'package:vimob/ui/proposal/select_unit_page.dart';
import 'package:vimob/ui/proposal/unit_detail_dialog.dart';
import 'package:vimob/ui/sales_mirror/attachment_card.dart';
import 'package:vimob/ui/sales_mirror/carousel_images.dart';

class DevelopmentDetails extends StatefulWidget {
  const DevelopmentDetails({
    Key key,
    @required this.development,
  }) : super(key: key);

  final Development development;

  @override
  _DevelopmentDetailsState createState() => _DevelopmentDetailsState();
}

class _DevelopmentDetailsState extends State<DevelopmentDetails> {
  bool _isLoading;
  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    var developmentState = Provider.of<DevelopmentState>(context);
    var authenticationState = Provider.of<AuthenticationState>(context);

    return Material(
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Scaffold(
            appBar: AppBarResponsive().show(
              context: context,
              title: I18n.of(context).developmentDetails,
            ),
            body: ListView(
              key: Key("development_details_list_view"),
              children: <Widget>[
                ((widget.development.gallery == null ||
                            widget.development.gallery.isEmpty) &&
                        (widget.development.attachments == null ||
                            widget.development.attachments.isEmpty))
                    ? Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        color: Color(0xFFD7E8FC),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                                text: I18n.of(context)
                                    .developmentWithoutInformationTitle,
                                style: Style.mainTheme.textTheme.bodyText2
                                    .copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: I18n.of(context)
                                    .developmentWithoutInformationText,
                                style: Style.mainTheme.textTheme.bodyText2)
                          ]),
                        ),
                      )
                    : Container(),
                ((widget.development.gallery == null ||
                            widget.development.gallery.isEmpty) &&
                        (widget.development.attachments == null ||
                            widget.development.attachments.isEmpty) &&
                        (widget.development.tourLink != null &&
                            widget.development.tourLink != ""))
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Style.horizontal(25),
                            vertical: Style.vertical(2)),
                        child: TourButton(
                          tourLink: widget.development.tourLink,
                          darkMode: true,
                        ),
                      )
                    : Container(),
                (widget.development.gallery?.isNotEmpty ?? false)
                    ? CarouselImages(
                        carouselItems: widget.development.gallery,
                        developmentId: widget.development.id,
                        tourLink: widget.development.tourLink,
                      )
                    : Container(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildMainInformation(
                        context: context,
                        priceMax:
                            widget.development.unitOverview?.maxPrice ?? 0,
                        priceMin:
                            widget.development.unitOverview?.minPrice ?? 0),
                    widget.development.type == 'land'
                        ? Padding(
                            padding:
                                EdgeInsets.only(bottom: Style.horizontal(4)),
                            child: _buildDetails(
                                title: I18n.of(context).area,
                                information: widget.development.unitOverview ==
                                        null
                                    ? null
                                    : widget.development.unitOverview
                                                ?.maxArea !=
                                            widget.development.unitOverview
                                                ?.minArea
                                        ? "${widget.development.unitOverview.minArea.floor()} ~ ${widget.development.unitOverview.maxArea.floor()}m²"
                                        : "${(widget.development.unitOverview?.maxArea ?? 0.00).floor()} m²"),
                          )
                        : Container(
                            margin: EdgeInsets.symmetric(
                                vertical: Style.horizontal(4)),
                            width: Style.horizontal(85),
                            color: Colors.grey[200],
                            child: Padding(
                              padding: EdgeInsets.all(Style.horizontal(4)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Expanded(
                                    child: _buildDetails(
                                        title: I18n.of(context).area,
                                        information: widget
                                                    .development.unitOverview ==
                                                null
                                            ? null
                                            : widget.development.unitOverview
                                                        ?.maxArea !=
                                                    widget.development
                                                        .unitOverview?.minArea
                                                ? "${widget.development.unitOverview.minArea.floor()} ~ ${widget.development.unitOverview.maxArea.floor()}m²"
                                                : "${(widget.development.unitOverview?.maxArea ?? 0.00).floor()} m²"),
                                  ),
                                  Expanded(
                                    child: _buildDetails(
                                        title: I18n.of(context).rooms,
                                        information: widget
                                                    .development.unitOverview ==
                                                null
                                            ? null
                                            : widget.development.unitOverview
                                                        .maxRooms !=
                                                    widget.development
                                                        .unitOverview.minRooms
                                                ? "${widget.development.unitOverview.minRooms} - ${widget.development.unitOverview.maxRooms}"
                                                : " ${widget.development.unitOverview.maxRooms}"),
                                  ),
                                  Expanded(
                                    child: _buildDetails(
                                        title: I18n.of(context).parkingSlots,
                                        information: null),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    Icon(
                      Icons.location_on,
                      size: Style.horizontal(8),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: Style.horizontal(8),
                          top: Style.horizontal(2),
                          left: Style.horizontal(8),
                          right: Style.horizontal(8)),
                      child: Text(
                        "${widget.development.address.streetAddress}, ${widget.development.address.number} - ${widget.development.address.neighborhood} - ${widget.development.address.city} - ${widget.development.address.state} - ${widget.development.address.zipCode}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    widget.development.description.isNotEmpty
                        ? Column(
                            children: <Widget>[
                              _buildTitleDivisor(
                                  context, I18n.of(context).description),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Style.horizontal(8),
                                      vertical: Style.horizontal(4)),
                                  child: Text(
                                    "${widget.development.description}",
                                    textAlign: TextAlign.justify,
                                  )),
                            ],
                          )
                        : Container(),
                    widget.development.gallery?.isNotEmpty ?? false
                        ? Wrap(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            children: <Widget>[
                              _buildTitleDivisor(
                                  context, I18n.of(context).documents),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: Style.horizontal(4),
                                  horizontal: Style.horizontal(4),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: widget.development.attachments
                                      .map((attachment) => AttachmentCard(
                                            key: Key(
                                                "attachment_card_${widget.development.attachments.indexOf(attachment)}"),
                                            developmentId:
                                                widget.development.id,
                                            attachment: attachment,
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.08,
                    )
                  ],
                ),
              ],
            ),
          ),
          _isLoading ?? false
              ? _buildLoadingButton()
              : _buildSelectUnitButton(
                  context, developmentState, authenticationState.user.company),
        ],
      ),
    );
  }

  SizedBox _buildLoadingButton() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.08,
      width: double.infinity,
      child: Container(
        color: Colors.orange,
        child: FlatButton(
          onPressed: () async {},
          child: Center(
              child: CircularProgressIndicator(
            valueColor: Style.loadingColor,
          )),
        ),
      ),
    );
  }

  SizedBox _buildSelectUnitButton(BuildContext context,
      DevelopmentState developmentState, String companyId) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.08,
      width: double.infinity,
      child: Container(
        color: Colors.orange,
        child: FlatButton(
          key: Key("see_units_button"),
          onPressed: () async {
            if (!_isLoading) {
              setState(() {
                _isLoading = true;
              });

              if (ConnectivityState().hasInternet) {
                String userId = AuthenticationState()
                    .user
                    .companies[companyId]
                    .externalId
                    .toString();
                String devId = widget.development.externalId.toString();

                bool mapEnabled = await CompanyBloc().checkUrlMap(
                    devId: devId,
                    urlMap: CompanyState().urlMap,
                    userId: userId);
                if (mapEnabled) {
                  await openMap(context, userId, devId, developmentState);
                } else {
                  await openSelectUnitPage(
                      developmentState, companyId, context);
                }
              } else {
                await openSelectUnitPage(developmentState, companyId, context);
              }
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: Center(
            child: Text(
              widget.development.type != "unit"
                  ? I18n.of(context).seeLots.toUpperCase()
                  : I18n.of(context).seeUnits.toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ),
      ),
    );
  }

  Future openMap(BuildContext context, String userId, String devId,
      DevelopmentState developmentState) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return DevelopmentMap(
          development: widget.development,
          devId: devId,
          userId: userId,
        );
      }),
    );
  }

  Future openSelectUnitPage(DevelopmentState developmentState, String companyId,
      BuildContext context) async {
    ProposalState().selectedDevelopment = widget.development;

    await developmentState.fetchDevelopmentUnits(
        developmentId: widget.development.id, companyId: companyId);

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return SelectUnitPage(
          development: widget.development,
        );
      }),
    );
  }

  Padding _buildMainInformation(
      {BuildContext context, double priceMax, double priceMin}) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: Style.horizontal(4), top: Style.horizontal(4)),
      child: Column(
        children: <Widget>[
          Text(
            "${widget.development.address.neighborhood} - ${widget.development.address.city} / ${widget.development.address.state}"
                .toUpperCase(),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: Style.horizontal(4)),
            child: Text("${widget.development.name}",
                textAlign: TextAlign.center,
                style: Style.textDevelopmentNameTitle),
          ),
          Text(
            "R\$ ${I18n.of(context).formatCurrencyCompact(priceMin ?? 0)} - ${I18n.of(context).formatCurrencyCompact(priceMax ?? 0)}",
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Container _buildTitleDivisor(BuildContext context, String title) {
    return Container(
        width: Style.horizontal(100),
        color: Colors.grey[200],
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: Style.horizontal(4), horizontal: Style.horizontal(8)),
          child: Text(title),
        ));
  }

  Widget _buildDetails({@required String title, String information}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(
          title ?? "",
          style: information != null
              ? Style.mainTheme.textTheme.bodyText2
              : Style.textDisable,
        ),
        information != null ? Text(information ?? "") : Container(),
      ],
    );
  }
}
