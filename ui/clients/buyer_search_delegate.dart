import 'package:flutter/material.dart';
import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/ui/clients/buyer_card.dart';
import 'package:vimob/utils/widgets/format_search.dart';
import 'package:vimob/ui/clients/buyer_page.dart';

class BuyerSearchDelegate extends SearchDelegate {
  BuyerSearchDelegate(this.buyerList);
  final List<Buyer> buyerList;

  @override
  String get searchFieldLabel => '';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [Container()];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      key: Key("exit_search_client"),
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Buyer> searchResult = buyerList
        .where((buyer) =>
            FormatSearch()
                .removeDiacritics(buyer?.name?.toLowerCase() ?? "")
                .contains(
                    FormatSearch().removeDiacritics(query.toLowerCase())) ||
            buyer.cpf.contains(query))
        .toList();
    return ListView(
      children: searchResult
          .map((item) => BuyerCard(
              key: Key("buyer_card_${searchResult.indexOf(item)}"),
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BuyerPage(
                              buyer: item,
                              mode: BuyerAppBarMode.edit,
                            )));
              },
              buyer: item))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Buyer> searchResult = buyerList
        .where((buyer) =>
            FormatSearch()
                .removeDiacritics(buyer?.name?.toLowerCase() ?? "")
                .contains(
                    FormatSearch().removeDiacritics(query.toLowerCase())) ||
            buyer.cpf.contains(query))
        .toList();
    return ListView(
      children: searchResult
          .map((item) => BuyerCard(
              key: Key("buyer_card_${searchResult.indexOf(item)}"),
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BuyerPage(
                              buyer: item,
                              mode: BuyerAppBarMode.edit,
                            )));
              },
              buyer: item))
          .toList(),
    );
  }
}
