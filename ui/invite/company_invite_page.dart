import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/states/invite_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/invite/company_welcome_page.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';
import 'package:vimob/utils/messages/translate_error_messages.dart';
import 'package:vimob/utils/widgets/loading_raised_button.dart';

class CompanyInvitePage extends StatelessWidget {
  const CompanyInvitePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authenticationState = Provider.of<AuthenticationState>(context);
    var inviteState = Provider.of<InviteState>(context);
    var connectivityState = Provider.of<ConnectivityState>(context);
    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBarResponsive().show(
          context: context,
          title: I18n.of(context).company,
          leading:
              authenticationState.user.company != null ? null : Container(),
          preferredSize: Style.vertical(8),
          onBack: () async {
            Navigator.pop(context);
          },
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: Style.horizontal(6)),
              child: Column(
                children: <Widget>[
                  Container(
                    height: Style.horizontal(50),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/invite/qr_code.svg',
                        fit: BoxFit.fill,
                        width: Style.horizontal(35),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  Text(
                    I18n.of(context).inviteText,
                    style: Style.titleSecondaryText,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: Style.horizontal(10), top: Style.horizontal(5)),
                    child: RichText(
                      text: TextSpan(
                        style: Style.mainTheme.textTheme.bodyText2,
                        text: I18n.of(context).inviteText2,
                        children: [
                          TextSpan(
                              text: "QR-CODE ",
                              style: Style.mainTheme.textTheme.bodyText2
                                  .copyWith(fontWeight: FontWeight.bold)),
                          TextSpan(text: I18n.of(context).inviteText3),
                          TextSpan(
                              text: I18n.of(context).code,
                              style: Style.mainTheme.textTheme.bodyText2
                                  .copyWith(fontWeight: FontWeight.bold)),
                          TextSpan(text: I18n.of(context).inviteText4),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: inviteState.inProgress
                        ? LoadingRaisedButton()
                        : _buildButton(inviteState, authenticationState,
                            connectivityState, context),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: Style.horizontal(5)),
                      child: Text(I18n.of(context).inviteText5)),
                  TextField(
                    key: Key("text_field_invite_code"),
                    maxLength: 6,
                    style: Style.inputInviteCodeText,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    onChanged: (String newValue) {
                      inviteState.handleInviteCode(code: newValue);
                    },
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                        counterText: "",
                        hintText: "OAK54G",
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.grey[250],
                        contentPadding: EdgeInsets.all(Style.horizontal(3))),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      InviteState inviteState,
      AuthenticationState authenticationState,
      ConnectivityState connectivityState,
      BuildContext context) {
    if (inviteState.codeValue.isNotEmpty) {
      return RaisedButton(
        key: Key("btn_send_invite_code"),
        onPressed: () async {
          try {
            if (connectivityState.hasInternet) {
              if (!inviteState.inProgress) {
                await inviteState.useInvite(
                    code: inviteState.codeValue,
                    user: authenticationState.user);

                await Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => CompanyWelcomePage()),
                    (route) => route.isFirst);
              }
            } else {
              ShowSnackbar()
                  .showSnackbarError(context, I18n.of(context).checkConnection);
            }
          } catch (e) {
            ShowSnackbar().showSnackbarError(
                context,
                TranslateErrorMessages()
                    .translateError(error: e.toString(), context: context));
          }
        },
        textColor: Style.textButtonColorPrimary,
        child: Text(I18n.of(context).send.toUpperCase()),
      );
    } else {
      return RaisedButton(
        onPressed: () {
          Navigator.pushNamed(context, 'QRScanCamera');
        },
        textColor: Style.textButtonColorPrimary,
        child: Text("${I18n.of(context).scan.toUpperCase()} QR-CODE"),
      );
    }
  }
}
