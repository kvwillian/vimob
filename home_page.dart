import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/buyer_state.dart';
import 'package:vimob/states/development_state.dart';

import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/clients/buyer_search_delegate.dart';
import 'package:vimob/ui/clients/client_list_tab.dart';

import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/drawer/menu_drawer.dart';
import 'package:vimob/ui/proposal/proposal_list_tab.dart';
import 'package:vimob/ui/proposal/proposal_search_delegate.dart';
import 'package:vimob/ui/sales_mirror/development_search_delegate.dart';
import 'package:vimob/ui/sales_mirror/sales_mirror_tab.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  Color _salesMirrorIconColor = Style.selectedOptions;
  Color _proposalsIconColor = Style.unselectedOptions;
  Color _clientsIconColor = Style.unselectedOptions;

  @override
  void initState() {
    super.initState();
    DevelopmentState().fetchDevelopments(
        companyId: AuthenticationState().user.company,
        uid: AuthenticationState().user.uid);
  }

  @override
  Widget build(BuildContext context) {
    var authenticationState = Provider.of<AuthenticationState>(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: Style.vertical(8),
          child: BottomNavigationBar(
            iconSize: Style.horizontal(7),
            onTap: (_index) {
              setState(() {
                _currentIndex = _index;

                _bottomNavigationIconColor(_index);
              });
            },
            currentIndex: _currentIndex,
            selectedItemColor: Style.selectedOptions,
            unselectedItemColor: Style.unselectedOptions,
            backgroundColor: Style.brandColor,
            items: [
              BottomNavigationBarItem(
                title: Container(),
                icon: SvgPicture.asset(
                  "assets/sales_mirror/sales_mirror.svg",
                  height: Style.horizontal(6),
                  color: _salesMirrorIconColor,
                ),
              ),
              BottomNavigationBarItem(
                  title: Container(),
                  icon: SvgPicture.asset(
                    "assets/proposals/proposals.svg",
                    color: _proposalsIconColor,
                    height: Style.horizontal(6),
                    key: Key("proposal_tab"),
                  )),
              BottomNavigationBarItem(
                title: Container(),
                icon: SvgPicture.asset(
                  "assets/clients/clients.svg",
                  color: _clientsIconColor,
                  height: Style.horizontal(6),
                  key: Key("client_tab"),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: MenuDrawer(),
      appBar: _buildAppBar(),
      body: StreamBuilder<bool>(
          stream: authenticationState.isLogged,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data &&
                authenticationState.user.uid != null) {
              return Container(
                key: Key("home_page"),
                child: [
                  SalesMirrorTab(
                    developmentState: Provider.of<DevelopmentState>(context),
                    user: authenticationState.user,
                  ),
                  ProposalListTab(
                    proposalState: Provider.of<ProposalState>(context),
                    user: authenticationState.user,
                  ),
                  ClientListTab(
                    isListLinkBuyer: false,
                  ),
                ][_currentIndex],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  void _bottomNavigationIconColor(int _index) {
    switch (_index) {
      case 0:
        _salesMirrorIconColor = Style.selectedOptions;
        _proposalsIconColor = Style.unselectedOptions;
        _clientsIconColor = Style.unselectedOptions;

        break;
      case 1:
        _salesMirrorIconColor = Style.unselectedOptions;
        _proposalsIconColor = Style.selectedOptions;
        _clientsIconColor = Style.unselectedOptions;
        break;
      case 2:
        _salesMirrorIconColor = Style.unselectedOptions;
        _proposalsIconColor = Style.unselectedOptions;
        _clientsIconColor = Style.selectedOptions;
        break;
      default:
        _salesMirrorIconColor = Style.unselectedOptions;
        _proposalsIconColor = Style.unselectedOptions;
        _clientsIconColor = Style.unselectedOptions;
    }
  }

  Widget _buildAppBar() {
    switch (_currentIndex) {
      case 0:
        return AppBarResponsive().showWithDrawer(
            scaffoldsKey: _scaffoldKey,
            context: context,
            headline6: "Espelho de vendas",
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Style.horizontal(2)),
                child: InkWell(
                    child: Icon(
                      Icons.search,
                      color: Style.mainTheme.appBarTheme.iconTheme.color,
                      size: Style.mainTheme.appBarTheme.iconTheme.size,
                    ),
                    onTap: () async {
                      await showSearch(
                          context: context,
                          delegate: DevelopmentSearchDelegate(
                              DevelopmentState().developments.value));
                    }),
              )
            ]);

        break;
      case 1:
        return AppBarResponsive().showWithDrawer(
            scaffoldsKey: _scaffoldKey,
            context: context,
            headline6: I18n.of(context).proposals,
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Style.horizontal(2)),
                child: InkWell(
                  key: Key("filter_proposals_button"),
                  onTap: () {
                    Navigator.pushNamed(context, "proposalFilterPage");
                  },
                  child: SvgPicture.asset(
                    "assets/common/filter_outline.svg",
                    width: Style.horizontal(4),
                    color: Style.mainTheme.appBarTheme.iconTheme.color,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Style.horizontal(2)),
                child: InkWell(
                    key: Key("search_proposal"),
                    child: Icon(
                      Icons.search,
                      color: Style.mainTheme.appBarTheme.iconTheme.color,
                      size: Style.mainTheme.appBarTheme.iconTheme.size,
                    ),
                    onTap: () async {
                      await showSearch(
                          context: context,
                          delegate: ProposalSearchDelegate(
                              ProposalState().currentProposals.value));
                    }),
              )
            ]);
        break;
      case 2:
        return AppBarResponsive().showWithDrawer(
            scaffoldsKey: _scaffoldKey,
            context: context,
            headline6: I18n.of(context).clients,
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Style.horizontal(2)),
                child: InkWell(
                    key: Key("search_client"),
                    child: Icon(
                      Icons.search,
                      color: Style.mainTheme.appBarTheme.iconTheme.color,
                      size: Style.mainTheme.appBarTheme.iconTheme.size,
                    ),
                    onTap: () async {
                      await showSearch(
                          context: context,
                          delegate: BuyerSearchDelegate(
                              BuyerState().buyersList.value));
                    }),
              )
            ]);

        break;
      default:
        return AppBar(
          title: Text("Error"),
        );
    }
  }
}
