import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/proposal_card.dart';
import 'package:vimob/utils/animation/widget_animation.dart';

class ProposalListTab extends StatelessWidget {
  const ProposalListTab({Key key, this.proposalState, this.user})
      : super(key: key);

  final ProposalState proposalState;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        width: Style.horizontal(15),
        height: Style.horizontal(15),
        child: FloatingActionButton(
          key: Key("create_proposal_button"),
          onPressed: () {
            DevelopmentState()
                .fetchDevelopments(companyId: user.company, uid: user.uid);
            Navigator.of(context).pushNamed('developmentList');
          },
          child: Center(
            child: Icon(Icons.add),
          ),
        ),
      ),
      body: StreamBuilder<List<Proposal>>(
          stream: proposalState.currentProposals,
          builder: (context, proposals) {
            if (proposals.hasData && proposals.data.isNotEmpty) {
              return WidgetAnimation(
                child: ListView(
                  children: proposals.data
                      .map((item) => ProposalCard(
                            key: Key(
                                "proposal_card_${proposals.data.indexOf(item)}"),
                            proposal: item,
                            companyStatuses: Provider.of<CompanyState>(context)
                                .companyStatuses,
                          ))
                      .toList(),
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      "assets/proposals/proposals.svg",
                      key: Key("proposal_list_empty_icon"),
                      height: Style.horizontal(30),
                      color: Style.mainTheme.iconTheme.color,
                    ),
                    Padding(
                      padding: EdgeInsets.all(Style.horizontal(4)),
                      child: Text(I18n.of(context).makeYourFirstProposal),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
