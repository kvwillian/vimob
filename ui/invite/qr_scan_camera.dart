import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/states/invite_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/invite/company_welcome_page.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';
import 'package:vimob/utils/messages/translate_error_messages.dart';

const flash_on = "FLASH ON";
const flash_off = "FLASH OFF";
const front_camera = "FRONT CAMERA";

class QRScanCamera extends StatefulWidget {
  const QRScanCamera({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScanCameraState();
}

class _QRScanCameraState extends State<QRScanCamera> {
  var flashState = flash_on;
  IconData iconFlash = Icons.flash_on;
  var cameraState = front_camera;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    var authenticationState = Provider.of<AuthenticationState>(context);
    var inviteState = Provider.of<InviteState>(context);
    var connectivityState = Provider.of<ConnectivityState>(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: (QRViewController controller) =>
                        _onQRViewCreated(controller, authenticationState,
                            inviteState, connectivityState),
                    overlay: QrScannerOverlayShape(
                      borderColor: Colors.blue,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 300,
                    ),
                  ),
                  flex: 4,
                ),
              ],
            ),
            Positioned(
              top: Style.horizontal(3),
              left: Style.horizontal(3),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: Style.scanCodeIconTheme.size,
                  color: Style.scanCodeIconTheme.color,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: Style.horizontal(3),
              right: Style.horizontal(3),
              child: IconButton(
                icon: Icon(
                  iconFlash,
                  size: Style.scanCodeIconTheme.size,
                  color: Style.scanCodeIconTheme.color,
                ),
                onPressed: () {
                  if (controller != null) {
                    controller.toggleFlash();
                    if (_isFlashOn(flashState)) {
                      setState(() {
                        flashState = flash_off;
                        iconFlash = Icons.flash_off;
                      });
                    } else {
                      setState(() {
                        flashState = flash_on;
                        iconFlash = Icons.flash_on;
                      });
                    }
                  }
                },
              ),
            ),
            inviteState.inProgress
                ? Container(
                    height: Style.vertical(100),
                    color: Colors.black12,
                    child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          height: Style.horizontal(25),
                          width: Style.horizontal(30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: Style.horizontal(2)),
                                child: CircularProgressIndicator(),
                              ),
                              Text(I18n.of(context).processing)
                            ],
                          )),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  _isFlashOn(String current) {
    return flash_on == current;
  }

  _onQRViewCreated(
      QRViewController controller,
      AuthenticationState authenticationState,
      InviteState inviteState,
      ConnectivityState connectivityState) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      try {
        if (connectivityState.hasInternet) {
          if (!inviteState.inProgress) {
            await inviteState.useInvite(
                user: authenticationState.user, qrcode: scanData);

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
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
