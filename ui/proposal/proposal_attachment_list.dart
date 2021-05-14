import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/utils/file_manager_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/proposal/attachment.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/image_fullscreen.dart';
import 'package:vimob/ui/proposal/pdf_screen.dart';
import 'package:vimob/ui/proposal/remove_attachment_dialog.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';

class ProposalAttachmentList extends StatefulWidget {
  const ProposalAttachmentList({
    Key key,
    this.proposal,
  }) : super(key: key);

  final Proposal proposal;

  @override
  _ProposalAttachmentListState createState() => _ProposalAttachmentListState();
}

class _ProposalAttachmentListState extends State<ProposalAttachmentList> {
  bool _isOpeningFile = false;

  @override
  void initState() {
    super.initState();
    ProposalState().bindBackgroundIsolate();

    FlutterDownloader.registerCallback(ProposalState.downloadCallback);
  }

  Widget build(BuildContext context) {
    var proposalState = Provider.of<ProposalState>(context);

    return Scaffold(
      floatingActionButton: SizedBox(
        height: Style.horizontal(12),
        width: Style.horizontal(12),
        child: widget.proposal.status == "inAttendance"
            ? FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Container(
                          height: Style.horizontal(30),
                          child: proposalState.attachmentUploadTask !=
                                  storage.TaskState.running
                              ? _buildUploadOptions(context)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    CircularProgressIndicator(),
                                    Text(I18n.of(context).uploading),
                                  ],
                                ),
                        );
                      });
                },
                child: Center(
                  child: Icon(
                    Icons.add,
                  ),
                ),
                backgroundColor: Colors.green,
              )
            : Container(),
      ),
      body: Container(
        // color: Colors.black12,
        child: StreamBuilder<List<Attachment>>(
            stream: proposalState.proposalAttachments,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (proposalState.attachmentUploadTask ==
                    storage.TaskState.running) {
                  return Container(
                    width: Style.maxWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Text(I18n.of(context).uploading),
                      ],
                    ),
                  );
                } else {
                  return Stack(
                    children: <Widget>[
                      ListView(
                        padding: snapshot.data.length > 1
                            ? EdgeInsets.only(bottom: Style.horizontal(20))
                            : null,
                        children: snapshot.data.map((attachment) {
                          return Column(
                            children: <Widget>[
                              InkWell(
                                key: Key("attachment_${attachment.name}"),
                                onTap: () async {
                                  await _openAttachmentPreview(
                                      attachment, context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: Style.horizontal(2),
                                      horizontal: Style.horizontal(4)),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              attachment.name,
                                              style: Style.textHighlightBold,
                                            ),
                                            Text(
                                                "${(attachment.totalBytes ~/ 1024)} KB | ${I18n.of(context).formatDate(date: attachment.date, abbreviated: true)}"),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: Style.horizontal(4)),
                                        child: InkWell(
                                          onTap: () async {
                                            await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    RemoveAttachmentDialog(
                                                        proposalId:
                                                            widget.proposal.id,
                                                        attachment:
                                                            attachment));
                                          },
                                          child: Icon(Icons.delete),
                                        ),
                                      ),
                                      _buildDownloadIcon(attachment),
                                    ],
                                  ),
                                ),
                              ),
                              Divider()
                            ],
                          );
                        }).toList(),
                      ),
                      _isOpeningFile
                          ? Expanded(
                              child: Container(
                              color: Colors.black12,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  CircularProgressIndicator(),
                                  Text("Abrindo anexo...")
                                ],
                              ),
                            ))
                          : Container(),
                    ],
                  );
                }
              } else {
                if (proposalState.attachmentUploadTask ==
                    storage.TaskState.running) {
                  return Container(
                    width: Style.maxWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Text(I18n.of(context).uploading),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              }
            }),
      ),
    );
  }

  _openAttachmentPreview(Attachment attachment, BuildContext context) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    bool fileExist = await File('$dir/${attachment.name}').exists();
    bool hasInternet =
        Provider.of<ConnectivityState>(context, listen: false).hasInternet;

    if (!_isOpeningFile) {
      switch (attachment.type) {
        case "application/pdf":
          if (!hasInternet && !fileExist) {
            if (hasInternet) {
              ShowSnackbar()
                  .showSnackbarError(context, I18n.of(context).genericError);
            } else {
              ShowSnackbar()
                  .showSnackbarError(context, I18n.of(context).checkConnection);
            }
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return PDFScreen(
                attachment: attachment,
              );
            }));
          }
          break;
        case "image/jpeg":
        case "image/png":
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ImageFullscreen(
                    src: attachment.src, imageName: attachment.fullName)),
          );
          break;
        default:
          if (!hasInternet && !fileExist) {
            if (hasInternet) {
              ShowSnackbar()
                  .showSnackbarError(context, I18n.of(context).genericError);
            } else {
              ShowSnackbar()
                  .showSnackbarError(context, I18n.of(context).checkConnection);
            }
          } else {
            setState(() => _isOpeningFile = true);
            var file = await FileManagerBloc()
                .createFile(src: attachment.src, fileName: attachment.name);
            await OpenFile.open(file.path);
            setState(() => _isOpeningFile = false);
          }
      }
    }
  }

  Widget _buildDownloadIcon(Attachment attachment) {
    switch (attachment.downloadInfo?.downloadStatus?.value) {
      case 0:
        return _buildDownloadButton(attachment);
        break;
      case 1:
        return SizedBox(
            height: Style.horizontal(5),
            width: Style.horizontal(5),
            child: CircularProgressIndicator());
        break;
      case 2:
        return SizedBox(
          height: Style.horizontal(5),
          width: Style.horizontal(5),
          child: CircularProgressIndicator(
            key: Key("attachment_download_progress_${attachment.name}"),
            value: attachment.downloadInfo.progress / 100,
            backgroundColor: Colors.black12,
          ),
        );
        break;
      default:
        return _buildDownloadButton(attachment);
    }
  }

  InkWell _buildDownloadButton(Attachment attachment) {
    bool hasInternet =
        Provider.of<ConnectivityState>(context, listen: false).hasInternet;

    return InkWell(
      onTap: () async {
        if (await _checkPermission() && hasInternet) {
          //========================Diretory========================
          Directory directory;
          if (Platform.isAndroid) {
            directory = Directory('/sdcard/Downloads/');
          } else {
            directory = await getApplicationDocumentsDirectory();
          }
          directory = Directory(directory.path +
              Platform.pathSeparator +
              (Platform.isAndroid ? "Vimob" : "Downloads"));
          if (!directory.existsSync()) {
            directory.createSync(recursive: true);
          }

          //========================Download========================
          String taskId = await FlutterDownloader.enqueue(
            url: attachment.src,
            savedDir: directory.path,
            fileName: attachment.name,
          );

          ProposalState().addTaskId(attachment, taskId);
        } else {
          if (hasInternet) {
            ShowSnackbar()
                .showSnackbarError(context, I18n.of(context).genericError);
          } else {
            ShowSnackbar()
                .showSnackbarError(context, I18n.of(context).checkConnection);
          }
        }
      },
      child: Icon(Icons.file_download),
    );
  }

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      Permission permission = Permission.storage;
      if (!await permission.isGranted) {
        PermissionStatus storagePermission = await Permission.storage.request();
        if (storagePermission.isGranted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Row _buildUploadOptions(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: FlatButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.camera_alt,
                color: Style.mainTheme.iconTheme.color,
              ),
              Text(
                I18n.of(context).camera,
                style: Style.mainTheme.textTheme.bodyText2,
              ),
            ],
          ),
          onPressed: () async {
            try {
              PickedFile pickedFile =
                  await ImagePicker().getImage(source: ImageSource.camera);

              File file = File(pickedFile.path);

              await ProposalState().uploadAttachment(
                  doc: file, proposalId: widget.proposal.id, abbreviate: true);

              Navigator.pop(context);
            } catch (e) {
              print(e);
            }
          },
        )),
        VerticalDivider(),
        Expanded(
            child: FlatButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add_box,
                color: Style.mainTheme.iconTheme.color,
              ),
              Text(
                I18n.of(context).documents,
                style: Style.mainTheme.textTheme.bodyText2,
              ),
            ],
          ),
          onPressed: () async {
            try {
              File file = await FilePicker.getFile();

              await ProposalState().uploadAttachment(
                  doc: file, proposalId: widget.proposal.id, abbreviate: false);

              Navigator.pop(context);
            } catch (e) {
              print(e);
            }
          },
        )),
      ],
    );
  }
}
