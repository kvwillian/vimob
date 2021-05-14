import 'package:flutter/material.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/ui/proposal/proposal_development_card.dart';
import 'package:vimob/utils/widgets/format_search.dart';

class ProposalDevelopmentListSearchDelegate extends SearchDelegate {
  ProposalDevelopmentListSearchDelegate(this.developmentList);
  final List<Development> developmentList;

  @override
  String get searchFieldLabel => '';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [Container()];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      key: Key("exit_search_development"),
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Development> searchResult = developmentList
        .where((development) => FormatSearch()
            .removeDiacritics(development.name.toLowerCase())
            .contains(FormatSearch().removeDiacritics(query.toLowerCase())))
        .toList();
    return ListView(
      children: searchResult
          .map((item) => ProposalDevelopmentCard(development: item))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Development> searchResult = developmentList
        .where((development) => FormatSearch()
            .removeDiacritics(development.name.toLowerCase())
            .contains(FormatSearch().removeDiacritics(query.toLowerCase())))
        .toList();
    return ListView(
      children: searchResult
          .map((item) => ProposalDevelopmentCard(development: item))
          .toList(),
    );
  }
}
