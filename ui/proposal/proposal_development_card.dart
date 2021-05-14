import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/company/company_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/map/development_map.dart';
import 'package:vimob/ui/proposal/select_unit_page.dart';

class ProposalDevelopmentCard extends StatelessWidget {
  const ProposalDevelopmentCard({
    Key key,
    @required this.development,
  }) : super(key: key);
  final Development development;

  @override
  Widget build(BuildContext context) {
    var developmentState = Provider.of<DevelopmentState>(context);
    var authenticationState = Provider.of<AuthenticationState>(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: Style.horizontal(0.1)),
      color: Colors.white,
      child: FlatButton(
          onPressed: () async {
            DevelopmentState().developmentMapWebViewController = null;

            ProposalState().selectedDevelopment = development;

            await developmentState.fetchDevelopmentUnits(
                developmentId: development.id,
                companyId: authenticationState.user.company);

            if (ConnectivityState().hasInternet) {
              String userId = AuthenticationState()
                  .user
                  .companies[authenticationState.user.company]
                  .externalId
                  .toString();
              String devId = development.externalId.toString();

              bool mapEnabled = await CompanyBloc().checkUrlMap(
                  devId: devId, urlMap: CompanyState().urlMap, userId: userId);
              if (mapEnabled) {
                await openMap(context, userId, devId, developmentState);
              } else {
                await openSelectUnitPage(developmentState,
                    authenticationState.user.company, context);
              }
            } else {
              await openSelectUnitPage(
                  developmentState, authenticationState.user.company, context);
            }
          },
          child: Row(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Style.horizontal(4),
                      vertical: Style.horizontal(7)),
                  child: _buildDevelopmentIconType(type: development.type)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: Style.horizontal(2)),
                      child: Text(
                        development.name,
                        style: Style.mainTheme.textTheme.bodyText2
                            .copyWith(fontWeight: FontWeight.bold),
                        key: Key("proposal_development_name_text"),
                      ),
                    ),
                    Text(
                      "${development.numberOfAvailableUnits} ${I18n.of(context).developmentsAvailable(development.numberOfAvailableUnits)}",
                      style: Style.mainTheme.textTheme.bodyText2.copyWith(
                          fontSize: Style.horizontal(4),
                          fontFamily: GoogleFonts.roboto().fontFamily),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      key: Key("proposal_development_units_available_text"),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }

  SvgPicture _buildDevelopmentIconType({String type}) {
    String iconPath = "assets/proposals/office_building.svg";
    if (type == "land") {
      iconPath = "assets/proposals/land.svg";
    }

    return SvgPicture.asset(
      iconPath,
      height: Style.mainTheme.iconTheme.size,
      color: Style.mainTheme.iconTheme.color,
      key: Key("unit_type_icon"),
    );
  }

  Future openMap(BuildContext context, String userId, String devId,
      DevelopmentState developmentState) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return DevelopmentMap(
          development: development,
          devId: devId,
          userId: userId,
        );
      }),
    );
  }

  Future openSelectUnitPage(DevelopmentState developmentState, String companyId,
      BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return SelectUnitPage(
          development: development,
        );
      }),
    );
  }
}
