import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/sales_mirror/development_details.dart';

class DevelopmentCard extends StatelessWidget {
  const DevelopmentCard({
    Key key,
    @required this.development,
  }) : super(key: key);

  final Development development;

  @override
  Widget build(BuildContext context) {
    var developmentState = Provider.of<DevelopmentState>(context);
    var authenticationState = Provider.of<AuthenticationState>(context);

    return Container(
      height: Style.horizontal(29),
      child: Card(
        margin: EdgeInsets.all(Style.horizontal(0.1)),
        elevation: 1,
        child: FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: () async {
            await developmentState.fetchDevelopmentUnits(
                developmentId: development.id,
                companyId: authenticationState.user.company);

            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DevelopmentDetails(
                      development: development,
                    )));
          },
          child: Row(
            children: <Widget>[
              Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: Container(
                  color: Colors.white,
                  child: CachedNetworkImage(
                    imageUrl: development.image,
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) =>
                        Image.asset("assets/common/sem_imagem.png"),
                  ),
                ),
              ),
              Flexible(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: Style.horizontal(4), top: Style.horizontal(2)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: AutoSizeText(
                          "${development.address.neighborhood} - ${development.address.city} / ${development.address.state}"
                              .toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Style.developmentCardInfoText,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AutoSizeText(
                              "${development.name}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Style.mainTheme.textTheme.bodyText2,
                            ),
                            Text(
                              development.unitOverview != null
                                  ? "R\$ ${I18n.of(context).formatCurrencyCompact(development.unitOverview.minPrice)} ~ ${I18n.of(context).formatCurrencyCompact(development.unitOverview.maxPrice)}"
                                  : "-",
                              style: Style.developmentCardInfoText
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        endIndent: 16,
                        indent: 16,
                        height: 2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: Style.horizontal(2)),
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                development.unitOverview?.maxArea != null &&
                                        development.unitOverview?.minArea !=
                                            null
                                    ? "${I18n.of(context).area}: ${development.unitOverview.minArea.floor()}-${development.unitOverview.maxArea.floor()} m²"
                                    : "${I18n.of(context).area}: -",
                                style: Style.developmentCardInfoText,
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                development.type == 'unit' &&
                                        development.unitOverview?.maxRooms !=
                                            null &&
                                        development.unitOverview?.minRooms !=
                                            null
                                    ? "${I18n.of(context).rooms}: ${development.unitOverview.minRooms} - ${development.unitOverview.maxRooms}"
                                    : "",
                                style: Style.developmentCardInfoText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
