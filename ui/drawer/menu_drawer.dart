import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/states/global_settings_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/web_view_page.dart';
import 'package:vimob/ui/drawer/company_list_dropdown.dart';
import 'package:vimob/ui/drawer/drawer_option.dart';
import 'package:vimob/ui/invite/image_profile.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';

class MenuDrawer extends Drawer {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthenticationState>(context).user;
    var packageInfo =
        Provider.of<GlobalSettingsState>(context).globalSettings.packageInfo;
    String versionName;
    if (versionName == null) {
      versionName = "v.${packageInfo.version}-${packageInfo.buildNumber}";
    }
    return SizedBox(
      width: Style.horizontal(80),
      child: Drawer(
        key: Key("drawer"),
        child: Column(
          children: <Widget>[
            _buildDrawerHeader(context, user),
            Padding(
              padding: EdgeInsets.only(
                  left: Style.horizontal(2), top: Style.horizontal(5)),
              child: _buildCompanyDropdown(context, user.companies),
            ),
            Padding(
              padding: EdgeInsets.only(top: Style.horizontal(5)),
              child: Column(
                children: <Widget>[
                  DrawerOption(
                      btnKey: Key("invite_page"),
                      text: I18n.of(context).joiningNewCompany,
                      svgPath: "assets/drawer/qrcode_scan.svg",
                      iconSize: Style.horizontal(6.5),
                      onTap: () {
                        Navigator.pushNamed(context, 'companyInvite');
                      }),
                  Divider(
                    color: Style.mainTheme.iconTheme.color,
                  ),
                  DrawerOption(
                    text: I18n.of(context).help,
                    iconData: Icons.live_help,
                    btnKey: Key("help_page"),
                    onTap: () async {
                      if (ConnectivityState().hasInternet) {
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => WebViewPage(
                                  title: I18n.of(context).help,
                                  url:
                                      "https://taskcenter.mega.com.br/hc/pt-br/sections/360002527734",
                                  fullscreen: false,
                                  onWebViewCreated: (controller) {},
                                )));
                      } else {
                        ShowSnackbar().showSnackbarError(
                            context, I18n.of(context).checkConnection);
                      }
                    },
                  ),
                  Divider(
                    color: Style.mainTheme.iconTheme.color,
                  ),
                  DrawerOption(
                      btnKey: Key("sign_out_button"),
                      text: I18n.of(context).signOut,
                      iconData: Icons.exit_to_app,
                      onTap: () async {
                        await AuthenticationState().signOut();
                      }),
                ],
              ),
            ),
            Spacer(),
            GestureDetector(
              onDoubleTap: () =>
                  ShowSnackbar().showSnackbarCustom(context, versionName),
              child: Padding(
                padding: EdgeInsets.only(bottom: Style.horizontal(8.0)),
                child: SvgPicture.asset(
                  "assets/drawer/vimob_logo_grey.svg",
                  height: Style.mainTheme.iconTheme.size,
                  color: Style.mainTheme.iconTheme.color.withAlpha(100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CompanyListDropDown _buildCompanyDropdown(
      BuildContext context, Map<String, Company> companies) {
    var companyList = List<DropdownMenuItem>();

    companies.forEach((key, value) {
      companyList.add(DropdownMenuItem(
        key: Key("dropdown_company_${value.id}"),
        child: Text(
          value.name,
          style: Style.mainTheme.textTheme.bodyText2,
        ),
        value: value.id,
      ));
    });

    return CompanyListDropDown(
      // onChange: null,
      items: companyList,
      label: I18n.of(context).company,
    );
  }

  Container _buildDrawerHeader(BuildContext context, User user) {
    return Container(
      height: Style.horizontal(50),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/login/app_login_background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: Style.horizontal(8)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('profile');
                },
                child: ImageProfile(
                  size: Style.horizontal(25),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: Style.horizontal(2)),
                child: Text(
                  "${I18n.of(context).hi}, ${user.name}",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
