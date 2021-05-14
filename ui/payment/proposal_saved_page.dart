import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/proposal_detail_page.dart';

class ProposalSavedPage extends StatefulWidget {
  ProposalSavedPage({
    Key key,
  }) : super(key: key);

  @override
  _ProposalSavedPageState createState() => _ProposalSavedPageState();
}

class _ProposalSavedPageState extends State<ProposalSavedPage> {
  @override
  void initState() {
    _startTimeout(Duration(seconds: 2));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(
                Icons.done,
                size: Style.savedProposalIconSize,
                color: Style.brandColor,
              ),
              Text(
                I18n.of(context).proposalSaved,
                style: Style.savedProposalText,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _handleTimeout() async {
    await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
      return ProposalDetailPage(
        proposal: ProposalState().selectedProposal,
        development: ProposalState().selectedDevelopment,
        initialIndex: 1,
      );
    }), (route) => route.isFirst);

    // pushReplacement(
    //   MaterialPageRoute(builder: (context) {
    //     return ProposalDetailPage(
    //       proposal: ProposalState().selectedProposal,
    //       development: ProposalState().selectedDevelopment,
    //       initialIndex: 1,
    //     );
    //   }),
    // );
  }

  _startTimeout(Duration timeout) {
    Timer(timeout, _handleTimeout);
  }
}
