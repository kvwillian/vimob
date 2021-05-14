import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/proposal/attachment.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';

class RemoveAttachmentDialog extends StatelessWidget {
  const RemoveAttachmentDialog({
    Key key,
    @required this.proposalId,
    @required this.attachment,
  }) : super(key: key);

  final String proposalId;
  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        height: Style.horizontal(65),
        width: Style.horizontal(80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(Style.horizontal(4)),
                  child: Icon(
                    Icons.delete,
                    size: Style.horizontal(15),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                I18n.of(context).removeAttachment,
                style: Style.mainTheme.textTheme.headline6
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                I18n.of(context).removeAttachmentConfirm,
                style: Style.mainTheme.textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: Style.horizontal(2)),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Center(
                          child: Text(I18n.of(context).cancel,
                              style: Style.mainTheme.textTheme.button.copyWith(
                                  color: Style.textButtonColorLink,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context);

                          await ProposalState().removeAttachment(
                              attachment: attachment, proposalId: proposalId);
                        },
                        child: Center(
                          child: Text(
                            I18n.of(context).remove,
                            style: Style.mainTheme.textTheme.button.copyWith(
                                color: Style.textButtonColorLink,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
