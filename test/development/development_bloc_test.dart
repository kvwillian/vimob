// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:vimob/blocs/development/development_bloc.dart';
// import 'package:vimob/models/development/block.dart';
// import 'package:vimob/models/development/development.dart';
// import 'package:vimob/models/development/unit.dart';
// import 'package:vimob/models/filter/filter.dart';
// import 'package:vimob/models/company/company.dart';

// void main() {
//   group("Development bloc test |", () {
//     Map<String, CompanyStatusConfig> availableStatus = {
//       "sold": CompanyStatusConfig()
//         ..color = Color(0xFFAABBCC)
//         ..enUS = "Sold"
//         ..ptBR = "Vendida",
//       "inAttendance": CompanyStatusConfig()
//         ..color = Color(0xFFAABBCC)
//         ..enUS = "In Attendance"
//         ..ptBR = "Em estudo",
//       "available": CompanyStatusConfig()
//         ..color = Color(0xFFAABBCC)
//         ..enUS = "Available"
//         ..ptBR = "Disponivel",
//     };

//     List<Block> blocks = [
//       Block()
//         ..id = "1"
//         ..name = "a"
//         ..externalId = 1
//         ..active = true
//         ..units = <Unit>[
//           Unit()
//             ..area = (UnitArea()
//               ..commonSquareMeters = 0
//               ..privateSquareMeters = 100)
//             ..room = 1
//             ..price = 200000.00
//             ..status = "sold",
//           Unit()
//             ..area = (UnitArea()
//               ..commonSquareMeters = 0
//               ..privateSquareMeters = 100)
//             ..room = 1
//             ..price = 200000.00
//             ..status = "sold",
//           Unit()
//             ..area = (UnitArea()
//               ..commonSquareMeters = 0
//               ..privateSquareMeters = 100)
//             ..room = 1
//             ..price = 200000.00
//             ..status = "sold",
//         ],
//       Block()
//         ..id = "2"
//         ..name = "b"
//         ..externalId = 2
//         ..active = true
//         ..units = <Unit>[
//           Unit()
//             ..area = (UnitArea()
//               ..commonSquareMeters = 0
//               ..privateSquareMeters = 100)
//             ..room = 1
//             ..price = 200000.00
//             ..status = "sold",
//           Unit()
//             ..area = (UnitArea()
//               ..commonSquareMeters = 0
//               ..privateSquareMeters = 100)
//             ..room = 2
//             ..price = 200000.00
//             ..status = "available",
//         ],
//       Block()
//         ..id = "3"
//         ..name = "c"
//         ..externalId = 3
//         ..active = true
//         ..units = <Unit>[
//           Unit()
//             ..area = (UnitArea()
//               ..commonSquareMeters = 0
//               ..privateSquareMeters = 120)
//             ..room = 3
//             ..price = 600000.00
//             ..status = "available"
//         ],
//     ];

//     Map<String, String> statusAvailable = {
//       "sold": "vendida",
//       "available": "disponivel",
//       "inAttendence": "em estudo",
//     };

//     test("Initialize the unit status filter", () {
//       Map<String, StatusFilter> expected = {
//         "sold": StatusFilter()
//           ..amount = 4
//           ..selected = true
//           ..status = "vendida",
//         "available": StatusFilter()
//           ..amount = 2
//           ..selected = true
//           ..status = "disponivel",
//         "inattendence": StatusFilter()
//           ..amount = 0
//           ..selected = false
//           ..status = "em estudo",
//       };

//       var unitFilter = DevelopmentBloc()
//           .initUnitFilters(blocks: blocks, statusAvailable: statusAvailable);

//       expect(unitFilter, expected);
//     });
//     test("Get area range", () {
//       Map<FilterRange, double> expected = {
//         FilterRange.currentMax: 120,
//         FilterRange.max: 120,
//         FilterRange.currentMin: 100,
//         FilterRange.min: 100
//       };

//       var areaRange = DevelopmentBloc().getAreaRange(blocks);

//       expect(areaRange, expected);
//     });
//     test("Get price range", () {
//       Map<FilterRange, double> expected = {
//         FilterRange.currentMax: 600000.0,
//         FilterRange.max: 600000.0,
//         FilterRange.currentMin: 200000.0,
//         FilterRange.min: 200000.0
//       };

//       var priceRange = DevelopmentBloc().getPriceRange(blocks);

//       expect(priceRange, expected);
//     });
//     test("Get room range", () {
//       Map<int, bool> expected = {
//         1: true,
//         2: true,
//         3: true,
//       };

//       var roomsRange = DevelopmentBloc().getRoomsRange(blocks);

//       expect(roomsRange, expected);
//     });
//     test("Initialize available status", () {
//       Map<String, String> expected = {
//         "sold": "Sold",
//         "inAttendance": "In Attendance",
//         "available": "Available",
//       };

//       var availableStatusResult =
//           DevelopmentBloc().initAvailableStatusList(availableStatus, "en_US");

//       expect(availableStatusResult, expected);
//     });

//     test("Filter units", () {
//       DevelopmentUnit expected = DevelopmentUnit()
//         ..blocks = [
//           Block()
//             ..id = "1"
//             ..name = "a"
//             ..externalId = 1
//             ..active = true
//             ..units = <Unit>[
//               Unit()
//                 ..area = (UnitArea()
//                   ..commonSquareMeters = 0
//                   ..privateSquareMeters = 100)
//                 ..room = 1
//                 ..price = 200000.00
//                 ..status = "sold",
//               Unit()
//                 ..area = (UnitArea()
//                   ..commonSquareMeters = 0
//                   ..privateSquareMeters = 100)
//                 ..room = 1
//                 ..price = 200000.00
//                 ..status = "sold",
//               Unit()
//                 ..area = (UnitArea()
//                   ..commonSquareMeters = 0
//                   ..privateSquareMeters = 100)
//                 ..room = 1
//                 ..price = 200000.00
//                 ..status = "sold",
//             ],
//           Block()
//             ..id = "2"
//             ..name = "b"
//             ..externalId = 2
//             ..active = true
//             ..units = <Unit>[
//               Unit()
//                 ..area = (UnitArea()
//                   ..commonSquareMeters = 0
//                   ..privateSquareMeters = 100)
//                 ..room = 1
//                 ..price = 200000.00
//                 ..status = "sold",
//             ],
//           Block()
//             ..id = "3"
//             ..name = "c"
//             ..externalId = 3
//             ..active = true
//             ..units = <Unit>[],
//         ];

//       var filterResult = DevelopmentBloc().applyFilter(
//           developmentUnit: DevelopmentUnit()..blocks = blocks,
//           filterAreaRange: {
//             FilterRange.currentMax: 120,
//             FilterRange.currentMin: 100
//           },
//           filterPriceRange: {
//             FilterRange.currentMax: 250000.0,
//             FilterRange.currentMin: 200000.0
//           },
//           filterRoomsRange: {
//             1: true,
//             2: false,
//             3: false
//           },
//           filterStatus: {
//             "sold": StatusFilter()
//               ..amount = 4
//               ..selected = true
//               ..status = "vendida",
//             "available": StatusFilter()
//               ..amount = 2
//               ..selected = true
//               ..status = "disponivel",
//             "inattendence": StatusFilter()
//               ..amount = 0
//               ..selected = false
//               ..status = "em estudo",
//           });

//       expect(filterResult, expected);
//     });
//   });
// }
