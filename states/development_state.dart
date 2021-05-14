import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:vimob/blocs/development/development_bloc.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/filter/filter.dart';
import 'package:vimob/states/company_state.dart';
import 'package:webview_media/webview_flutter.dart';

class DevelopmentState with ChangeNotifier {
  factory DevelopmentState() => instance;
  DevelopmentState._internal();
  static var instance = DevelopmentState._internal();

  WebViewController developmentMapWebViewController;

  var developments = BehaviorSubject<List<Development>>();

  StreamSubscription _listenerDevelopments;
  StreamSubscription _listenerDevelopmentUnits;

  var filterStatus = Map<String, StatusFilter>();
  var filterAreaRange = Map<FilterRange, double>();
  var filterPriceRange = Map<FilterRange, double>();
  var filterRoomsRange = Map<int, bool>();

  var _deviceLocale;

  String get deviceLocale => _deviceLocale;

  set deviceLocale(String deviceLocale) {
    _deviceLocale = deviceLocale;
  }

  void fetchDevelopments({String companyId, String uid}) async {
    if (_listenerDevelopments != null) {
      await _listenerDevelopments.cancel();
    }
    _listenerDevelopments = DevelopmentBloc()
        .fetchDevelopments(companyId: companyId, uid: uid)
        .listen((developmentsStream) {
      developments.add(developmentsStream);
      notifyListeners();
    });
  }

  var currentDevelopmentUnit = BehaviorSubject<DevelopmentUnit>();
  DevelopmentUnit _developmentUnit;

  Future<void> fetchDevelopmentUnits(
      {String developmentId, String companyId}) async {
    if (_listenerDevelopmentUnits != null) {
      currentDevelopmentUnit.add(DevelopmentUnit());
      await _listenerDevelopmentUnits.cancel();
    }
    _listenerDevelopmentUnits = DevelopmentBloc()
        .fetchDevelopmentUnits(
            companyId: companyId, developmentId: developmentId)
        .listen((developmentUnit) {
      currentDevelopmentUnit.add(developmentUnit);

      _developmentUnit = currentDevelopmentUnit.value;

      initFilterStatus();

      // applyFilter(
      //     filterAreaRange: filterAreaRange,
      //     filterPriceRange: filterPriceRange,
      //     filterRoomsRange: filterRoomsRange,
      //     filterStatus: filterStatus);

      notifyListeners();
    });
  }

  Future<void> cleanStream() async {
    currentDevelopmentUnit.add(DevelopmentUnit());
    developments.add([]);
    await _listenerDevelopmentUnits?.cancel();
    await _listenerDevelopments?.cancel();
    notifyListeners();
  }

  initFilterStatus() async {
    var avaialableStatusList = DevelopmentBloc().initAvailableStatusList(
        CompanyState().companyStatuses.units, deviceLocale);

    filterStatus = DevelopmentBloc().initUnitFilters(
        blocks: _developmentUnit.blocks, statusAvailable: avaialableStatusList);

    var activeBlocks =
        _developmentUnit.blocks.where((block) => block.active).toList();

    var futureList = activeBlocks.map((b) {
      return b.units;
    });

    var allUnitsList = await Future.wait(futureList);
    var allUnits = allUnitsList.expand((unit) => unit);

    filterAreaRange = DevelopmentBloc().getAreaRange(allUnits);
    filterPriceRange = DevelopmentBloc().getPriceRange(allUnits);
    filterRoomsRange = DevelopmentBloc().getRoomsRange(allUnits);

    notifyListeners();
  }

  updateFilterStatus({String key, bool selected}) {
    filterStatus[key].selected = selected;
    notifyListeners();
  }

  updateFilterArea({Map<FilterRange, double> newfilterAreaRange}) {
    // filterAreaRange.clear();
    // filterAreaRange.addAll(newfilterAreaRange);
    filterAreaRange = newfilterAreaRange;
    notifyListeners();
  }

  updateFilterPrice({Map<FilterRange, double> newfilterPriceRange}) {
    filterPriceRange = newfilterPriceRange;
    notifyListeners();
  }

  updateFilterRooms({Map<int, bool> newfilterRoomsRange}) {
    filterRoomsRange = newfilterRoomsRange;
    notifyListeners();
  }

  applyFilter(
      {Map<FilterRange, double> filterAreaRange,
      Map<FilterRange, double> filterPriceRange,
      Map<int, bool> filterRoomsRange,
      Map<String, StatusFilter> filterStatus}) {
    currentDevelopmentUnit.add(DevelopmentBloc().applyFilter(
        developmentUnit: _developmentUnit,
        filterAreaRange: filterAreaRange,
        filterPriceRange: filterPriceRange,
        filterRoomsRange: filterRoomsRange,
        filterStatus: filterStatus));

    notifyListeners();
  }

  cleanFilter() {
    initFilterStatus();

    currentDevelopmentUnit.add(_developmentUnit);
    notifyListeners();
  }

  @override
  Future dispose() async {
    await _listenerDevelopments.cancel();
    await _listenerDevelopmentUnits.cancel();
    super.dispose();
  }

  Future<void> mapRefresh() async {
    if (developmentMapWebViewController != null) {
      await developmentMapWebViewController.reload();
    }
  }
}
