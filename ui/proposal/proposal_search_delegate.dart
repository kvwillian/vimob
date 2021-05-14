import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/ui/proposal/proposal_card.dart';
import 'package:vimob/utils/widgets/format_search.dart';

class ProposalSearchDelegate extends SearchDelegate {
  ProposalSearchDelegate(this.proposalList);
  final List<Proposal> proposalList;

  @override
  String get searchFieldLabel => '';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [Container()];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      key: Key("exit_search_proposal"),
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Proposal> searchResult = proposalList
        .where((proposal) =>
            proposal.idProposalMega
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            FormatSearch()
                .removeDiacritics(proposal?.buyer?.name?.toLowerCase() ?? "")
                .contains(
                    FormatSearch().removeDiacritics(query.toLowerCase())) ||
            FormatSearch()
                .removeDiacritics(
                    proposal?.development?.name?.toLowerCase() ?? "")
                .contains(
                    FormatSearch().removeDiacritics(query.toLowerCase())) ||
            FormatSearch()
                .removeDiacritics(proposal?.block?.name?.toLowerCase() ?? "")
                .contains(
                    FormatSearch().removeDiacritics(query.toLowerCase())) ||
            proposal.status.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView(
      children: searchResult
          .map((item) => ProposalCard(
                proposal: item,
                companyStatuses:
                    Provider.of<CompanyState>(context).companyStatuses,
              ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Proposal> searchResult = proposalList
        .where((proposal) =>
            proposal.idProposalMega
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            FormatSearch()
                .removeDiacritics(proposal?.buyer?.name?.toLowerCase() ?? "")
                .contains(
                    FormatSearch().removeDiacritics(query.toLowerCase())) ||
            FormatSearch()
                .removeDiacritics(
                    proposal?.development?.name?.toLowerCase() ?? "")
                .contains(
                    FormatSearch().removeDiacritics(query.toLowerCase())) ||
            FormatSearch()
                .removeDiacritics(proposal?.block?.name?.toLowerCase() ?? "")
                .contains(
                    FormatSearch().removeDiacritics(query.toLowerCase())) ||
            proposal.status.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView(
      children: searchResult
          .map((item) => ProposalCard(
                proposal: item,
                companyStatuses:
                    Provider.of<CompanyState>(context).companyStatuses,
              ))
          .toList(),
    );
  }
}
