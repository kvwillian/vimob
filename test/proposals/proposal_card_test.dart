// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:jiffy/jiffy.dart';
// import 'package:provider/provider.dart';
// import 'package:vimob/i18n/test_i18n_delegate.dart';
// import 'package:vimob/models/development/development.dart';
// import 'package:vimob/models/proposal/proposal.dart';
// import 'package:vimob/states/company_state.dart';
// import 'package:vimob/states/development_state.dart';
// import 'package:vimob/style.dart';
// import 'package:vimob/ui/proposal/proposal_card.dart';
// import 'package:vimob/ui/proposal/status_chip.dart';

void main() {
//   final TestWidgetsFlutterBinding binding =
//       TestWidgetsFlutterBinding.ensureInitialized();
//   group("Proposal card | ", () {
//     Widget _createProposalCard(
//         {CompanyStatuses companyStatuses, Proposal proposal}) {
//       return LayoutBuilder(builder: (context, constraints) {
//         Style().responsiveInit(constraints: constraints);
//         return MultiProvider(
//           providers: [
//             ChangeNotifierProvider<CompanyState>.value(
//                 value: CompanyState()..companyStatuses = companyStatuses),
//             ChangeNotifierProvider<DevelopmentState>.value(
//                 value: DevelopmentState()),
//           ],
//           child: MaterialApp(
//             localizationsDelegates: [
//               TestI18nDelegate(),
//               GlobalCupertinoLocalizations.delegate,
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//             ],
//             supportedLocales: [
//               const Locale('en', 'US'),
//               const Locale('pt', 'BR'),
//             ],
//             home: Material(
//               child: ListView(children: <Widget>[
//                 ProposalCard(
//                   companyStatuses: companyStatuses,
//                   proposal: proposal,
//                 ),
//               ]),
//             ),
//           ),
//         );
//       });
//     }

//     binding.window.physicalSizeTestValue = Size(1, 200);
//     binding.window.devicePixelRatioTestValue = 1.0;

//     testWidgets("Should render with idProposalCode",
//         (WidgetTester tester) async {
//       await tester.pumpWidget(
//         _createProposalCard(
//             companyStatuses: CompanyStatuses()
//               ..proposals = <String, CompanyStatusConfig>{
//                 'avaliation': (CompanyStatusConfig()
//                   ..color = Color(0xFFFFFFAF)
//                   ..enUS = "avaliation"
//                   ..ptBR = "avaliando"),
//               },
//             proposal: Proposal()
//               ..status = "avaliation"
//               ..development = (DevelopmentReference()..name = "Jardins")
//               ..block = (Reference()..name = "bloco a")
//               ..unit = (ProposalUnit()..name = "a10")
//               ..date = Jiffy([2019, 1, 1])
//               ..idProposalMega = 321654),
//       );

//       var color = tester
//           .widget<Container>(find.byKey(Key("card_container")))
//           .foregroundDecoration
//           .toString()
//           .contains("0xffffffaf");

//       expect(color, true);

//       var idDateText = tester
//           .widget<RichText>(find.byKey(Key("id_date_text")))
//           .toString()
//           .contains("321654 | Jan 1, 2019");

//       expect(idDateText, true);

//       var developmentIconType = tester
//           .widget<SvgPicture>(find.byKey(Key("unit_type_icon")))
//           .pictureProvider
//           .toString()
//           .contains("assets/proposals/office_building.svg");

//       expect(developmentIconType, true);

//       expect(find.byType(StatusChip), findsOneWidget);
//       expect(tester.widget<Text>(find.byKey(Key("development_name_text"))).data,
//           "Jardins");
//       expect(tester.widget<Text>(find.byKey(Key("block_name_text"))).data,
//           "block: bloco a");
//       expect(tester.widget<Text>(find.byKey(Key("unit_name_text"))).data,
//           "unit: a10");
//       expect(tester.widget<Text>(find.byKey(Key("buyer_name_text"))).data,
//           "clientNotBound");
//     });

//     testWidgets("Should render without idProposalCode and w/ client",
//         (WidgetTester tester) async {
//       await tester.pumpWidget(
//         _createProposalCard(
//             companyStatuses: CompanyStatuses()
//               ..proposals = <String, CompanyStatusConfig>{
//                 'locked': (CompanyStatusConfig()
//                   ..color = Color(0xFFAAAAAA)
//                   ..enUS = "locked"
//                   ..ptBR = "fechado"),
//               },
//             proposal: Proposal()
//               ..status = "locked"
//               ..development = (DevelopmentReference()
//                 ..name = "Jardins"
//                 ..type = "unit")
//               ..block = (Reference()..name = "bloco a")
//               ..unit = (ProposalUnit()..name = "a10")
//               ..date = Jiffy([2019, 2, 1])
//               ..idProposalMega = null
//               ..buyer = (Reference()..name = "Giu")),
//       );

//       var color = tester
//           .widget<Container>(find.byKey(Key("card_container")))
//           .foregroundDecoration
//           .toString()
//           .contains("0xffaaaaaa");

//       expect(color, true);

//       var idDateText = tester
//           .widget<RichText>(find.byKey(Key("id_date_text")))
//           .toString()
//           .contains("Feb 1, 2019");

//       expect(idDateText, true);

//       var developmentIconType = tester
//           .widget<SvgPicture>(find.byKey(Key("unit_type_icon")))
//           .pictureProvider
//           .toString()
//           .contains("assets/proposals/office_building.svg");

//       expect(developmentIconType, true);

//       expect(find.byType(StatusChip), findsOneWidget);

//       expect(tester.widget<Text>(find.byKey(Key("development_name_text"))).data,
//           "Jardins");
//       expect(tester.widget<Text>(find.byKey(Key("block_name_text"))).data,
//           "block: bloco a");
//       expect(tester.widget<Text>(find.byKey(Key("unit_name_text"))).data,
//           "unit: a10");
//       expect(
//           tester.widget<Text>(find.byKey(Key("buyer_name_text"))).data, "Giu");
//     });

//     testWidgets("Should render land icon", (WidgetTester tester) async {
//       await tester.pumpWidget(
//         _createProposalCard(
//             companyStatuses: CompanyStatuses()
//               ..proposals = <String, CompanyStatusConfig>{
//                 'locked': (CompanyStatusConfig()
//                   ..color = Color(0xFFAAAAAA)
//                   ..enUS = "locked"
//                   ..ptBR = "fechado"),
//               },
//             proposal: Proposal()
//               ..status = "locked"
//               ..development = (DevelopmentReference()
//                 ..name = "Jardins"
//                 ..type = "land")
//               ..block = (Reference()..name = "bloco a")
//               ..unit = (ProposalUnit()..name = "a10")
//               ..date = Jiffy([2019, 2, 1])
//               ..idProposalMega = null
//               ..buyer = (Reference()..name = "Giu")),
//       );

//       var color = tester
//           .widget<Container>(find.byKey(Key("card_container")))
//           .foregroundDecoration
//           .toString()
//           .contains("0xffaaaaaa");

//       expect(color, true);

//       var idDateText = tester
//           .widget<RichText>(find.byKey(Key("id_date_text")))
//           .toString()
//           .contains("Feb 1, 2019");

//       expect(idDateText, true);

//       var developmentIconType = tester
//           .widget<SvgPicture>(find.byKey(Key("unit_type_icon")))
//           .pictureProvider
//           .toString()
//           .contains("assets/proposals/land.svg");

//       expect(developmentIconType, true);

//       expect(find.byType(StatusChip), findsOneWidget);

//       expect(tester.widget<Text>(find.byKey(Key("development_name_text"))).data,
//           "Jardins");
//       expect(tester.widget<Text>(find.byKey(Key("block_name_text"))).data,
//           "block: bloco a");
//       expect(tester.widget<Text>(find.byKey(Key("unit_name_text"))).data,
//           "unit: a10");
//       expect(
//           tester.widget<Text>(find.byKey(Key("buyer_name_text"))).data, "Giu");
//     });
//   });
}
