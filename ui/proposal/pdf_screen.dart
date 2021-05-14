import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:share_extend/share_extend.dart';
import 'package:vimob/blocs/utils/file_manager_bloc.dart';
import 'package:vimob/models/proposal/attachment.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';

class PDFScreen extends StatefulWidget {
  PDFScreen({
    this.attachment,
  });
  final Attachment attachment;

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  File _pdf;

  @override
  void initState() {
    FileManagerBloc()
        .createFile(
            src: widget.attachment.src, fileName: widget.attachment.name)
        .then((value) => setState(() => _pdf = value));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_pdf?.path != null) {
      return PDFViewerScaffold(
          appBar: AppBarResponsive().show(
              context: context,
              title: widget.attachment.name,
              preferredSize: Style.vertical(11),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    ShareExtend.share(_pdf.path, "file");
                  },
                  child: Icon(
                    Icons.share,
                    color: Style.mainTheme.appBarTheme.actionsIconTheme.color,
                    size: Style.mainTheme.appBarTheme.actionsIconTheme.size,
                  ),
                )
              ]),
          path: _pdf.path);
    } else {
      return Scaffold(
          appBar: AppBarResponsive().show(
            context: context,
            title: widget.attachment.name,
            preferredSize: Style.vertical(7),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ));
    }
  }
}
