import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/proposal/proposal_development_card.dart';
import 'package:vimob/ui/proposal/proposal_development_list_search_delegate.dart';
import 'package:vimob/utils/animation/widget_animation.dart';

class DevelopmentListPage extends StatelessWidget {
  const DevelopmentListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var developmentState = Provider.of<DevelopmentState>(context);

    return Scaffold(
      appBar: AppBarResponsive().show(
          context: context,
          title: I18n.of(context).newProposal,
          leading: InkWell(
            key: Key("exit_development_list_page"),
            onTap: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: Icon(
              Icons.close,
              color: Style.mainTheme.appBarTheme.iconTheme.color,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Style.horizontal(2)),
              child: InkWell(
                  key: Key("search_development"),
                  child: Icon(
                    Icons.search,
                    color: Style.mainTheme.appBarTheme.iconTheme.color,
                    size: Style.mainTheme.appBarTheme.iconTheme.size,
                  ),
                  onTap: () async {
                    await showSearch(
                        context: context,
                        delegate: ProposalDevelopmentListSearchDelegate(
                            developmentState.developments.value));
                  }),
            )
          ]),
      body: Container(
        color: Colors.black12,
        child: Column(
          children: <Widget>[
            _buildSubtitle(context),
            StreamBuilder<List<Development>>(
                stream: developmentState.developments,
                builder: (context, developments) {
                  if (developments.hasData) {
                    return Flexible(
                      child: WidgetAnimation(
                        child: ListView(
                            children: developments.hasData
                                ? _buildDevelopmentList(developments.data)
                                : [
                                    Center(
                                      child: CircularProgressIndicator(
                                        key: Key("circular_progress"),
                                      ),
                                    ),
                                  ]),
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  Container _buildSubtitle(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Style.horizontal(3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text(I18n.of(context).developments)],
        ),
      ),
    );
  }

  List<Widget> _buildDevelopmentList(List<Development> developments) {
    return developments
        .map((development) => ProposalDevelopmentCard(
            key: Key(
                "proposal_development_card_${developments.indexOf(development)}"),
            development: development))
        .toList();
  }
}
