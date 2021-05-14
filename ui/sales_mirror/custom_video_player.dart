import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/style.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({
    Key key,
    @required this.item,
    this.onTapFullscreen,
    @required this.file,
  }) : super(key: key);

  final CarouselItem item;
  final File file;
  final VoidCallback onTapFullscreen;

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  @override
  void initState() {
    widget.item.videoController = VideoPlayerController.file(widget.file)
      ..initialize().then((value) => setState(() {}));

    widget.item.videoController.addListener(() {
      if (mounted) {
        setState(() {
          widget.item.currentTime = widget.item.videoController.value.position;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          widget.item.videoController.value.initialized
              ? AspectRatio(
                  aspectRatio: 16.0 / 9.0,
                  child: VideoPlayer(widget.item.videoController))
              : Center(
                  child: CircularProgressIndicator(),
                ),
          widget.item.videoController.value.initialized
              ? Positioned(
                  bottom: 0,
                  child: Container(
                    color: Colors.black38,
                    width: Style.horizontal(100),
                    height: Style.horizontal(8),
                    padding:
                        EdgeInsets.symmetric(horizontal: Style.horizontal(2)),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                            child: Icon(
                              !widget.item.videoController.value.isPlaying ||
                                      (widget.item.videoController.value
                                              .duration ==
                                          widget.item.currentTime)
                                  ? Icons.play_arrow
                                  : Icons.pause,
                              color: Colors.white,
                              size: Style.mainTheme.appBarTheme.iconTheme.size,
                            ),
                            onTap: () async {
                              if (widget.item.videoController.value.isPlaying) {
                                await widget.item.videoController.pause();
                              } else {
                                if (widget
                                        .item.videoController.value.duration ==
                                    widget.item.currentTime) {
                                  await widget.item.videoController
                                      .seekTo(Duration(seconds: 0));
                                }
                                await widget.item.videoController.play();
                              }

                              setState(() {});
                            }),
                        Expanded(
                          child: Slider(
                            value: widget.item.currentTime.inSeconds /
                                widget.item.videoController.value.duration
                                    .inSeconds,
                            onChanged: (newValue) {
                              setState(() {
                                widget.item.currentTime = Duration(
                                    seconds: (newValue *
                                            widget.item.videoController.value
                                                .duration.inSeconds)
                                        .toInt());
                              });
                            },
                            onChangeEnd: (value) async {
                              await widget.item.videoController
                                  .seekTo(widget.item.currentTime);
                              if (!widget
                                  .item.videoController.value.isPlaying) {
                                await widget.item.videoController.pause();
                              }
                              setState(() {});
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: Style.horizontal(4)),
                          child: Text(
                              ((widget.item.videoController.value.position
                                                  .inSeconds /
                                              100.0)
                                          .toStringAsFixed(2) +
                                      " / " +
                                      (widget.item.videoController.value
                                                  .duration.inSeconds /
                                              100.0)
                                          .toStringAsFixed(2))
                                  .replaceAll(".", ":"),
                              style: Style.mainTheme.textTheme.bodyText1),
                        ),
                        widget.onTapFullscreen != null
                            ? Padding(
                                padding:
                                    EdgeInsets.only(left: Style.horizontal(2)),
                                child: InkWell(
                                  child: Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                    size: Style
                                        .mainTheme.appBarTheme.iconTheme.size,
                                  ),
                                  onTap: widget.onTapFullscreen,
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
