import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/proposal/history.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/utils/status_progress.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/link_buyer_dialog.dart';
import 'package:vimob/ui/proposal/send_proposal_dialog.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';

class ProposalHistoryList extends StatefulWidget {
  const ProposalHistoryList({
    Key key,
    this.proposal,
  }) : super(key: key);

  final Proposal proposal;

  @override
  _ProposalHistoryListState createState() => _ProposalHistoryListState();
}

class _ProposalHistoryListState extends State<ProposalHistoryList> {
  bool _isSending = false;
  StatusProgress _sendProgress = StatusProgress.init;

  @override
  Widget build(BuildContext context) {
    var proposalState = Provider.of<ProposalState>(context);

    return Scaffold(
      floatingActionButton: SizedBox(
        height: Style.horizontal(12),
        width: Style.horizontal(12),
        child: widget.proposal.status == "inAttendance"
            ? FloatingActionButton(
                onPressed: () async {
                  if (!_isSending) {
                    Proposal selectedProposal = proposalState
                        .currentProposals.value
                        .firstWhere((i) => i.id == widget.proposal.id);

                    if (selectedProposal.buyer != null) {
                      setState(() {
                        _isSending = true;
                        _sendProgress = StatusProgress.init;
                      });
                      await showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => SendProposalDialog(
                                proposal: selectedProposal,
                                onFinish: (StatusProgress sendProgress) {
                                  setState(() {
                                    _sendProgress = sendProgress;
                                  });
                                },
                              ));
                      switch (_sendProgress) {
                        case StatusProgress.done:
                          ShowSnackbar().showSnackbarSuccess(
                              context, I18n.of(context).success);
                          break;
                        case StatusProgress.error:
                          ShowSnackbar().showSnackbarError(
                              context, I18n.of(context).genericError);
                          break;
                        default:
                          break;
                      }

                      setState(() {
                        _isSending = false;
                      });
                    } else {
                      await showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) =>
                              LinkBuyerDialog(proposal: selectedProposal));
                    }
                  }
                },
                child: Center(
                  child: _isSending
                      ? CircularProgressIndicator(
                          valueColor: Style.loadingColor,
                        )
                      : Icon(Icons.send),
                ),
              )
            : Container(),
      ),
      body: Container(
        child: StreamBuilder<List<History>>(
            stream: proposalState.proposalLogs,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: snapshot.data
                      .map(
                        (history) => Padding(
                          padding: EdgeInsets.only(
                              top: Style.horizontal(2),
                              right: Style.horizontal(4),
                              left: Style.horizontal(4),
                              bottom: Style.horizontal(2)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding:
                                    EdgeInsets.only(right: Style.horizontal(4)),
                                child: Container(
                                    height: Style.horizontal(10),
                                    width: Style.horizontal(10),
                                    decoration: BoxDecoration(
                                        color: history.color,
                                        borderRadius: BorderRadius.circular(
                                            Style.horizontal(50))),
                                    child: Icon(
                                      _chooseIcon(history.status),
                                      textDirection: TextDirection.rtl,
                                      size: Style.mainTheme.iconTheme.size,
                                      color: Colors.white,
                                    )),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(child: Text(history.title)),
                                        Wrap(
                                          spacing: Style.horizontal(2),
                                          children: <Widget>[
                                            Text(I18n.of(context).formatDate(
                                                date: history.date,
                                                customFormat: "yMd")),
                                            Text(
                                              I18n.of(context).formatTime(
                                                date: history.date,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    //TODO: translate
                                    Text(
                                      history.descriptionPtBr,
                                      style: Style.titleSecondaryText,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
              } else {
                return Container();
              }
            }),
      ),
    );
  }

  IconData _chooseIcon(String status) {
    switch (status) {
      case "sent":
        return Icons.send;
      case "created":
        return Icons.chat_bubble;
      case "a_flow":
        return Icons.chat_bubble;
      case "legal_analysis":
        return Icons.chat_bubble;
      case "approved":
        return FontAwesomeIcons.trophy;
      case "released":
        return Icons.attach_money;
      default:
        return Icons.chat_bubble;
    }
  }
}
