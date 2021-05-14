import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_extend/share_extend.dart';
import 'package:vimob/blocs/utils/file_manager_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/style.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    Key key,
    @required this.file,
    @required this.type,
    this.customIcon,
    this.url,
    this.fileName,
  }) : super(key: key);

  ShareButton.url({
    Key key,
    @required this.url,
    @required this.fileName,
    @required this.type,
    this.customIcon,
    this.file,
  }) : super(key: key);

  final File file;
  final String url;
  final String fileName;
  final String type;
  final Icon customIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        print(fileName);
        String filePath;

        switch (type) {
          case 'youtube':
            await ShareExtend.share(url, 'text');
            return null;
            break;
          case 'video':
          case 'image':
            if (file == null) {
              File fileFromUrl = await FileManagerBloc()
                  .createFile(src: url, fileName: fileName);

              filePath = fileFromUrl.path;
            } else {
              filePath = file.path;
            }

            break;
          default:
        }

        if (filePath == null && type != 'youtube') {
          ShowSnackbar()
              .showSnackbarError(context, I18n.of(context).genericError);
        } else {
          await ShareExtend.share(filePath, type);
        }
      },
      child: customIcon ??
          Icon(
            Icons.share,
            color: Style.mainTheme.appBarTheme.actionsIconTheme.color,
            size: Style.mainTheme.appBarTheme.actionsIconTheme.size,
          ),
    );
  }
}
