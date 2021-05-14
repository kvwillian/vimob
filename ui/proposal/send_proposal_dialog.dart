import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/utils/status_progress.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';

class SendProposalDialog extends StatelessWidget {
  const SendProposalDialog({Key key, @required this.proposal, this.onFinish})
      : super(key: key);

  final Proposal proposal;
  final Function(StatusProgress) onFinish;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        height: Style.horizontal(45),
        width: Style.horizontal(80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(Style.horizontal(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: Style.horizontal(4)),
                    child: Text(
                      I18n.of(context).sendProposal,
                      style: Style.mainTheme.textTheme.headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(I18n.of(context).sendProposalDialogText),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: Style.horizontal(4)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: InkWell(
                        key: Key("cancel_proposal_send_button"),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(I18n.of(context).notYet,
                            style: Style.mainTheme.textTheme.button.copyWith(
                                color: Style.textButtonColorLink,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          try {
                            Provider.of<ProposalState>(context, listen: false)
                                .sendProposal(
                                    proposal: proposal,
                                    user: Provider.of<AuthenticationState>(
                                            context,
                                            listen: false)
                                        .user);
                            if (onFinish != null) {
                              onFinish(StatusProgress.done);
                              Navigator.pop(context);
                            } else {
                              int count = 0;
                              Navigator.of(context)
                                  .popUntil((_) => count++ >= 2);
                            }
                          } catch (e) {
                            if (onFinish != null) {
                              onFinish(StatusProgress.error);
                            }
                          }
                        },
                        child: Text(
                          I18n.of(context).send,
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
          ],
        ),
      ),
    );
  }
}
