import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:webview_media/webview_flutter.dart';

import '../../style.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    Key key,
    @required this.url,
    this.javascriptMode,
    this.title,
    @required this.fullscreen,
    this.onPageStarted,
    this.onWebViewCreated,
    this.action,
  }) : super(key: key);

  final String url;
  final String title;
  final bool fullscreen;
  final JavascriptMode javascriptMode;
  final Function(String) onPageStarted;
  final Function(WebViewController) onWebViewCreated;
  final List<Widget> action;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController _webViewController;
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarResponsive()
          .show(title: widget.title ?? "", context: context, actions: <Widget>[
        ...widget.action ?? [Container()],
        InkWell(
          child: Icon(
            Icons.refresh,
            color: Style.mainTheme.appBarTheme.actionsIconTheme.color,
            size: Style.mainTheme.appBarTheme.actionsIconTheme.size,
          ),
          onTap: () async {
            await _webViewController.reload();
          },
        ),
      ]),
      body: SafeArea(
        child: WebView(
          onWebViewCreated: (controller) {
            widget.onWebViewCreated(controller);
            _webViewController = controller;
          },
          initialUrl: widget.url ?? "www.mega.com.br",
          javascriptMode:
              JavascriptMode.unrestricted ?? JavascriptMode.disabled,
          javascriptChannels: Set.from([
            JavascriptChannel(
                name: 'Print',
                onMessageReceived: (JavascriptMessage message) =>
                    widget.onPageStarted(message.message))
          ]),
        ),
      ),
    );
  }
}
