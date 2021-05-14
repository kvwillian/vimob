import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/common/filter_status_list.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';

class ProposalFilterPage extends StatelessWidget {
  ProposalFilterPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var proposalState = Provider.of<ProposalState>(context);

    return Scaffold(
      appBar: AppBarResponsive().show(
          context: context,
          leading: IconButton(
            key: Key("exit_filter_button"),
            icon: Icon(
              Icons.close,
              color: Style.mainTheme.appBarTheme.iconTheme.color,
            ),
            onPressed: () {
              ProposalState()
                  .filterProposals(filterStatus: proposalState.filterStatus);
              Navigator.pop(context);
              ShowSnackbar().showSnackbarSuccess(context, "Filtro aplicado");
            },
            padding: EdgeInsets.only(right: Style.horizontal(5)),
            iconSize: Style.horizontal(7),
          ),
          title: I18n.of(context).searchFilter,
          actions: <Widget>[
            RaisedButton(
              key: Key("clean_filter_button"),
              textColor: Colors.white,
              padding: EdgeInsets.all(Style.horizontal(1)),
              color: Style.buttonCleanFilterColor,
              onPressed: () => ProposalState().cleanFilter(),
              child: Text(
                I18n.of(context).cleanFilter,
                style: Style.mainTheme.textTheme.button,
              ),
            )
          ]),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: Style.horizontal(10)),
                child: FilterStatusList(
                  filterStatus: proposalState.filterStatus,
                  updateFilterStatus: (selected, key) => proposalState
                      .updateFilterStatus(key: key, selected: selected),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: -1,
            child: SizedBox(
              width: Style.horizontal(102),
              height: Style.horizontal(15),
              child: RaisedButton(
                key: Key("apply_filter_button"),
                padding: EdgeInsets.all(0),
                textColor: Style.textButtonColorPrimary,
                onPressed: () {
                  ProposalState().filterProposals(
                      filterStatus: proposalState.filterStatus);
                  Navigator.pop(context);
                  ShowSnackbar()
                      .showSnackbarSuccess(context, "Filtro aplicado");
                },
                child: Text(I18n.of(context).applyFilter.toUpperCase()),
              ),
            ),
          )
        ],
      ),
    );
  }
}
