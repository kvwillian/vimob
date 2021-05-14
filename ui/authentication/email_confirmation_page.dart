import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/authentication/authentication_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/sign_up_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/check_user.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';

class EmailConfirmationPage extends StatefulWidget {
  const EmailConfirmationPage({
    Key key,
    this.formStatus,
    this.email,
    this.isUnconfirmed = false,
  }) : super(key: key);

  final FormStatus formStatus;
  final String email;
  final bool isUnconfirmed;

  @override
  _EmailConfirmationPageState createState() => _EmailConfirmationPageState();
}

class _EmailConfirmationPageState extends State<EmailConfirmationPage> {
  int _count = 59;
  Timer _timerCountDown;

  countDown() {
    _timerCountDown = new Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (_count > 0) {
        setState(() {
          _count--;
        });
      } else {
        t.cancel();
      }
    });
  }

  restartCountDown() {
    _count = 60;
    countDown();
  }

  @override
  void initState() {
    super.initState();
    countDown();
  }

  @override
  void dispose() {
    _timerCountDown.cancel();
    AuthenticationBloc().stopWaitEmailConfirmation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var authenticationState = Provider.of<AuthenticationState>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: StreamBuilder<bool>(
          stream: authenticationState.isLogged,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data) {
                return CheckUser(
                    authenticationState: authenticationState, context: context);
              } else {
                return Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBarResponsive().show(
                      context: context,
                      leading: Container(),
                      preferredSize: Style.vertical(7),
                      title: I18n.of(context).validateYourEmail),
                  body: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Style.horizontal(8)),
                        height: Style.vertical(88),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              flex: 2,
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/login/send_email.svg",
                                  width: Style.horizontal(75),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: _buildTextInfo(
                                  context, widget.formStatus.emailChanged),
                            ),
                            Spacer(),
                            Flexible(
                              child: Center(
                                child: widget.formStatus.inProgress
                                    ? _loadingButtonOutline()
                                    : _buildButton(widget.formStatus),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            } else {
              return Container();
            }
          }),
    );
  }

  Column _buildTextInfo(BuildContext context, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: Style.vertical(4)),
          child: Text(
            I18n.of(context).waitingForValidation,
            style: Style.titleSecondaryText,
          ),
        ),
        Text(
          I18n.of(context).waitingForValidation2,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              .copyWith(fontWeight: FontWeight.bold),
        ),
        widget.isUnconfirmed
            ? RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                    text: I18n.of(context).replaceSentencesVariables(
                        I18n.of(context).waitingForReValidation, email),
                    style: Theme.of(context).textTheme.bodyText2,
                    children: <TextSpan>[
                      TextSpan(
                          text: I18n.of(context).clickingHere,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              AuthenticationBloc().stopWaitEmailConfirmation();
                              await Navigator.of(context)
                                  .pushNamed('resendEmail');
                            },
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: Style.textButtonColorSecondary)),
                    ]),
              )
            : RichText(
                text: TextSpan(
                    text: I18n.of(context).replaceSentencesVariables(
                        I18n.of(context).waitingForValidation3, email),
                    style: Theme.of(context).textTheme.bodyText2,
                    children: <TextSpan>[
                      TextSpan(
                          text: I18n.of(context).waitingForValidation4,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              AuthenticationBloc().stopWaitEmailConfirmation();
                              await Navigator.of(context)
                                  .pushNamed('resendEmail');
                            },
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: Style.textButtonColorSecondary)),
                      TextSpan(
                        text: I18n.of(context).waitingForValidation5,
                      )
                    ]),
              ),
      ],
    );
  }

  Widget _buildButton(FormStatus signUpState) {
    if (_count > 0) {
      return _countDownButton();
    } else {
      return _resendButton(signUpState);
    }
  }

  Widget _countDownButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlineButton(
        textColor: Style.textButtonColorSecondary,
        onPressed: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(flex: 2, child: Text("0:$_count")),
            Expanded(flex: 3, child: Text(I18n.of(context).send)),
          ],
        ),
      ),
    );
  }

  Widget _resendButton(FormStatus signUpState) {
    return SizedBox(
      width: double.infinity,
      child: OutlineButton(
          textColor: Style.textButtonColorSecondary,
          onPressed: () {
            SignUpState().resendEmailConfirmation();
            restartCountDown();
          },
          child: Text(I18n.of(context).resendEmail)),
    );
  }

  Widget _loadingButtonOutline() {
    return SizedBox(
      width: double.infinity,
      child: OutlineButton(
        textColor: Style.textButtonColorSecondary,
        onPressed: () {},
        child: SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(
              valueColor: Style.loadingColorSecondary,
            )),
      ),
    );
  }
}
