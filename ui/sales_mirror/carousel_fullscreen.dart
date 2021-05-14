import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vimob/blocs/utils/file_manager_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/common/share_button.dart';
import 'package:vimob/ui/sales_mirror/custom_video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CarouselFullscreen extends StatefulWidget {
  const CarouselFullscreen({this.index, this.itemList, this.developmentId});
  final int index;
  final List<CarouselItem> itemList;
  final String developmentId;

  @override
  _CarouselFullscreenState createState() => _CarouselFullscreenState();
}

class _CarouselFullscreenState extends State<CarouselFullscreen> {
  int currentIndex;
  List<Widget> carousel = <Widget>[
    Center(
      child: CircularProgressIndicator(),
    )
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    currentIndex = widget.index;
    _buildCarouselItens(widget.developmentId)
        .then((value) => setState(() => carousel = value));
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
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      key: Key('gallery'),
      body: Stack(
        children: <Widget>[
          Container(
            child: Center(
              child: CarouselSlider(
                items: carousel,
                options: CarouselOptions(
                  initialPage: widget.index,
                  height: Style.vertical(100),
                  autoPlay: false,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBarResponsive().show(
              context: context,
              title: "",
              appBarColor: Colors.black.withOpacity(0.5),
              actions: <Widget>[
                ShareButton.url(
                  url: widget.itemList[currentIndex].src,
                  type: widget.itemList[currentIndex].type,
                  fileName: widget.itemList[currentIndex].name,
                )
              ],
              leading: InkWell(
                key: Key("arrow_back"),
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back,
                    color: Style.mainTheme.appBarTheme.iconTheme.color,
                    size: isLandscape
                        ? Style.horizontal(4)
                        : Style.horizontal(7)),
              ),
              onBack: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Widget>> _buildCarouselItens(String developmentId) async {
    List<Widget> list = List<Widget>();

    await Future.forEach(widget.itemList, (CarouselItem item) async {
      Widget widget;
      switch (item.type) {
        case "youtube":
          widget = Center(
            child: YoutubePlayer(
              controller: item.youtubeController,
              showVideoProgressIndicator: true,
              progressColors: ProgressBarColors(
                playedColor: Colors.amber,
                handleColor: Colors.amberAccent,
              ),
            ),
          );

          break;
        case "image/jpeg":
        case "image/png":
        case "image":
          widget = item.src != null
              ? PhotoView(
                  loadingBuilder: (context, event) => Container(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  enableRotation: true,
                  customSize: Size(Style.horizontal(90), Style.vertical(80)),
                  imageProvider: CachedNetworkImageProvider(item.src),
                )
              : Center(
                  child: Text(I18n.of(context).checkConnection),
                );
          break;
        case "video":
          widget = CustomVideoPlayer(
            item: item,
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
