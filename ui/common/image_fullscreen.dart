import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/common/share_button.dart';

class ImageFullscreen extends StatefulWidget {
  const ImageFullscreen({
    Key key,
    @required this.src,
    @required this.imageName,
  }) : super(key: key);

  final String src;
  final String imageName;

  @override
  _ImageFullscreenState createState() => _ImageFullscreenState();
}

class _ImageFullscreenState extends State<ImageFullscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarResponsive()
          .show(context: context, title: widget.imageName, actions: <Widget>[
        ShareButton.url(
          url: widget.src,
          fileName: widget.imageName,
          type: "image",
        )
      ]),
      body: Stack(children: <Widget>[
        PhotoView(
          key: Key("attachment_preview"),
          loadingBuilder: (context, event) => Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          enableRotation: true,
          customSize: Size(Style.horizontal(90), Style.vertical(80)),
          imageProvider: CachedNetworkImageProvider(widget.src),
        ),
      ]),
    );
  }
}
