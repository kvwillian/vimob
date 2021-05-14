import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:vimob/blocs/utils/file_manager_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/web_view_page.dart';
import 'package:vimob/ui/sales_mirror/carousel_fullscreen.dart';
import 'package:vimob/ui/sales_mirror/custom_video_player.dart';
import 'package:webview_media/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CarouselImages extends StatefulWidget {
  CarouselImages({
    Key key,
    this.carouselItems,
    this.developmentId,
    this.tourLink,
  }) : super(key: key);

  final List<CarouselItem> carouselItems;
  final String developmentId;
  final String tourLink;

  @override
  _CarouselImagesState createState() => _CarouselImagesState();
}

class _CarouselImagesState extends State<CarouselImages> {
  int _currentIndex = 1;
  List<Widget> _carousel;
  @override
  void initState() {
    if (_carousel == null) {
      _buildCarouselItens(widget.carouselItems, widget.developmentId)
          .then((value) => setState(() {
                _carousel = value;
              }));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key("carousel"),
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          Container(
            foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: <Color>[
                Colors.black54,
                Colors.transparent,
                Colors.transparent
              ],
            )),
            child: CarouselSlider(
              items: _carousel ?? [Container()],
              options: CarouselOptions(
                initialPage: 0,
                autoPlay: false,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) async {
                  _carousel = await _buildCarouselItens(
                      widget.carouselItems, widget.developmentId);
                  setState(() {
                    _currentIndex = index + 1;
                  });
                },
              ),
            ),
          ),
          (widget.tourLink != null &&
                  widget.tourLink.isNotEmpty &&
                  widget.carouselItems[_currentIndex - 1].type
                      .contains("image"))
              ? Positioned(
                  bottom: Style.horizontal(2),
                  left: Style.horizontal(33),
                  child: TourButton(tourLink: widget.tourLink),
                )
              : Container(),
          Positioned(
            bottom: Style.horizontal(3.5),
            right: Style.horizontal(4),
            child: Container(
              child: Text("$_currentIndex/${widget.carouselItems.length}",
                  style: Style.mainTheme.textTheme.bodyText1),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Widget>> _buildCarouselItens(
      List<CarouselItem> items, String developmentId) async {
    List<Widget> list = List<Widget>();

    items.sort((a, b) => a.type.compareTo(b.type));

    await Future.forEach(widget.carouselItems, (CarouselItem item) async {
      Widget widget;
      switch (item.type) {
        case "youtube":
          widget = YoutubePlayer(
            controller: item.youtubeController,
            showVideoProgressIndicator: true,
            progressColors: ProgressBarColors(
              playedColor: Colors.amber,
              handleColor: Colors.amberAccent,
            ),
          );

          break;
        case "image/jpeg":
        case "image/png":
        case "image":
          widget = InkWell(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CarouselFullscreen(
                            index: items.indexOf(item),
                            itemList: items,
                            developmentId: developmentId,
                          )));
            },
            child: item.src != null
                ? CachedNetworkImage(
                    imageUrl: item.src,
                    useOldImageOnUrlChange: true,
                    errorWidget: (context, url, error) => Center(
                      child: Text(I18n.of(context).checkConnection),
                    ),
                  )
                : Center(
                    child: Text(I18n.of(context).checkConnection),
                  ),
          );
          break;
        case "video":
          widget = CustomVideoPlayer(
            item: item,
            onTapFullscreen: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CarouselFullscreen(
                  index: items.indexOf(item),
                  itemList: items,
                  developmentId: developmentId,
                ),
              ),
            ),
            file: await FileManagerBloc()
                .createFile(src: item.src, fileName: item.name),
          );

          break;
        default:
          widget = Container();
      }
      list.add(widget);
    });

    return list;
  }
}

class TourButton extends StatelessWidget {
  const TourButton({
    Key key,
    @required this.tourLink,
    this.darkMode = false,
  }) : super(key: key);

  final String tourLink;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WebViewPage(
              title: "Tour",
              javascriptMode: JavascriptMode.unrestricted,
              fullscreen: true,
              url: tourLink,
              onWebViewCreated: (controller) {},
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: Style.horizontal(4), vertical: Style.horizontal(1)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(200)),
            border: Border.all(
                color: darkMode ? Style.textDefaultColor : Colors.white,
                width: 1.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: Style.horizontal(2)),
              child: Icon(
                Icons.remove_red_eye,
                color: darkMode ? Style.textDefaultColor : Colors.white,
              ),
            ),
            Text(
              "Tour virtual",
              style: darkMode
                  ? Style.mainTheme.textTheme.bodyText2
                  : Style.mainTheme.textTheme.bodyText1,
            )
          ],
        ),
      ),
    );
  }
}
