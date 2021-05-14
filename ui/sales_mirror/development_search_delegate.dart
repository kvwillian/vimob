import 'package:flutter/material.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/ui/sales_mirror/development_card.dart';
import 'package:vimob/utils/widgets/format_search.dart';

class DevelopmentSearchDelegate extends SearchDelegate {
  DevelopmentSearchDelegate(this.developmentList);
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
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Development> searchResult = developmentList
        .where((development) =>
                FormatSearch()
                    .removeDiacritics(development.name.toLowerCase())
                    .contains(
                        FormatSearch().removeDiacritics(query.toLowerCase())) ||
                // development.company.name.contains(query.toLowerCase()) ||
                FormatSearch()
                    .removeDiacritics(development.address.city.toLowerCase())
                    .contains(
                        FormatSearch().removeDiacritics(query.toLowerCase())) ||
                FormatSearch()
                    .removeDiacritics(
                        development.address.neighborhood.toLowerCase())
                    .contains(
                        FormatSearch().removeDiacritics(query.toLowerCase())) ||
                FormatSearch()
                    .removeDiacritics(development.address.state.toLowerCase())
                    .contains(
                        FormatSearch().removeDiacritics(query.toLowerCase()))
            // development.address.streetAddress.contains(query.toLowerCase()) ||
            // development.address.number.contains(query.toLowerCase())
            )
        .toList();
    return ListView(
        children: searchResult
            .map((development) => DevelopmentCard(
                key: Key(
                    "development_card_${searchResult.indexOf(development)}"),
                development: development))
            .toList());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Development> searchResult = developmentList
        .where((development) =>
                FormatSearch()
                    .removeDiacritics(development.name.toLowerCase())
                    .contains(
                        FormatSearch().removeDiacritics(query.toLowerCase())) ||
                // development.company.name.contains(query.toLowerCase()) ||
                FormatSearch()
                    .removeDiacritics(development.address.city.toLowerCase())
                    .contains(
                        FormatSearch().removeDiacritics(query.toLowerCase())) ||
                FormatSearch()
                    .removeDiacritics(
                        development.address.neighborhood.toLowerCase())
                    .contains(
                        FormatSearch().removeDiacritics(query.toLowerCase())) ||
                FormatSearch()
                    .removeDiacritics(development.address.state.toLowerCase())
                    .contains(
                        FormatSearch().removeDiacritics(query.toLowerCase()))
            // development.address.streetAddress.contains(query.toLowerCase()) ||
            // development.address.number.contains(query.toLowerCase())
            )
        .toList();
    return ListView(
        children: searchResult
            .map((development) => DevelopmentCard(
                key: Key(
                    "development_card_${searchResult.indexOf(development)}"),
                development: development))
            .toList());
  }
}
