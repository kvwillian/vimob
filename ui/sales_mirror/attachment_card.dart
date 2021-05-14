import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/utils/file_manager_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/proposal/attachment.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/image_fullscreen.dart';
import 'package:vimob/ui/proposal/pdf_screen.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';

class AttachmentCard extends StatefulWidget {
  AttachmentCard({
    Key key,
    this.attachment,
    this.developmentId,
  }) : super(key: key);

  final Attachment attachment;
  final String developmentId;

  @override
  _AttachmentCardState createState() => _AttachmentCardState();
}

class _AttachmentCardState extends State<AttachmentCard> {
  bool _isOpeningFile = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Stack(
        children: <Widget>[
          SizedBox(
            width: Style.horizontal(92),
            child: InkWell(
              onTap: () async {
                _openAttachmentPreview(widget.attachment, context);
              },
              child: Padding(
                padding: EdgeInsets.all(Style.horizontal(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // direction: Axis.vertical,
                  // spacing: 8.0,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _resolveTypeName(type: widget.attachment?.type) ?? "",
                        style: Style.textHighlight,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        widget.attachment?.name ?? "",
                        style: Style.titleSecondaryText,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(widget.attachment?.description ?? ""),
                    ),
                    widget.attachment.type == "image/png" ||
                            widget.attachment.type == "image/jpeg"
                        ? SizedBox(
                            width: Style.horizontal(20),
                            child: CachedNetworkImage(
                                imageUrl: widget.attachment.src))
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
          _isOpeningFile
              ? Container(
                  color: Colors.black12,
                  //TODO: translate
                  child: Center(child: Text("Abrindo o anexo...")),
                )
              : Container(),
        ],
      ),
    );
  }

  String _resolveTypeName({String type}) {
    switch (type) {
      case "application/pdf":
        return "PDF";
        break;
      case "image/jpeg":
        return "JPG";
      case "image/png":
        return "PNG";
        break;
      default:
        return "";
    }
  }

  _openAttachmentPreview(Attachment attachment, BuildContext context) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    bool fileExist = await File('$dir/${attachment.name}').exists();
    bool hasInternet =
        Provider.of<ConnectivityState>(context, listen: false).hasInternet;

    if (!hasInternet && !fileExist) {
      if (hasInternet) {
        ShowSnackbar()
            .showSnackbarError(context, I18n.of(context).genericError);
      } else {
        ShowSnackbar()
            .showSnackbarError(context, I18n.of(context).checkConnection);
      }
    } else {
      switch (attachment.type) {
        case "application/pdf":
          await Navigator.push(context, MaterialPageRoute(builder: (_) {
            return PDFScreen(
              attachment: attachment,
            );
          }));

          break;
        case "image/jpeg":
        case "image/png":
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageFullscreen(
                src: attachment.src,
                imageName: attachment.name,
              ),
            ),
          );
          break;
        default:
          setState(() => _isOpeningFile = true);
          var file = await FileManagerBloc()
              .createFile(src: attachment.src, fileName: attachment.name);
          await OpenFile.open(file.path);
          setState(() => _isOpeningFile = false);
      }
    }
  }
}
