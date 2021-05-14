import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:jiffy/jiffy.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/models/development/block.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/development/unit.dart';
import 'package:vimob/models/filter/filter.dart';
import 'package:vimob/models/proposal/attachment.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/style.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DevelopmentBloc {
  Stream<List<Development>> fetchDevelopments({String uid, String companyId}) {
    var developmentsStream = BehaviorSubject<List<Development>>();

    FirebaseFirestore.instance
        .collection("developments")
        .where("company.id", isEqualTo: companyId)
        .where("users.$uid", isEqualTo: true)
        .where("active", isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        print("FIRESTORE: developments snapshot");
        var developments = List<Development>();
        snapshot.docs.forEach((doc) {
          var development = Development()
            ..id = doc.id
            ..externalId = doc.data()['externalId']
            ..name = doc.data()['name']
            ..reserveValidity = doc.data()['reserveValidity']
            ..description = doc.data()['description']
            ..type = doc.data()['type']
            ..tourLink = doc.data()['tourLink'] ?? null
            ..numberOfAvailableUnits =
                doc.data()['numberOfAvailableUnits'].toInt()
            ..address = (Address()
              ..city = doc.data()['address']['city']
              ..complement = doc.data()['address']['complement']
              ..neighborhood = doc.data()['address']['neighborhood']
              ..number = doc.data()['address']['number']
              ..state = doc.data()['address']['state']
              ..streetAddress = doc.data()['address']['streetAddress']
              ..zipCode = doc.data()['address']['zipCode'])
            ..company = doc.data()['company'] != null
                ? (Reference()
                  ..id = doc.data()['company']['id']
                  ..name = doc.data()['company']['name'])
                : null
            ..unitOverview = doc?.data()['unitOverview'] != null
                ? (UnitOverview()
                  ..maxArea =
                      doc?.data()['unitOverview']['maxArea']?.toDouble() ?? null
                  ..minArea =
                      doc?.data()['unitOverview']['minArea']?.toDouble() ?? null
                  ..maxRooms =
                      doc?.data()['unitOverview']['maxRooms']?.toInt() ?? null
                  ..minRooms =
                      doc?.data()['unitOverview']['minRooms']?.toInt() ?? null
                  ..maxPrice =
                      doc?.data()['unitOverview']['maxPrice']?.toDouble() ??
                          null
                  ..minPrice =
                      doc?.data()['unitOverview']['minPrice']?.toDouble() ??
                          null)
                : null
            ..image = doc.data()['image']
            ..attachments = doc.data()['attachments'] != null
                ? createAttachmentList(doc)
                : null
            ..gallery =
                doc.data()['gallery'] != null ? createCarouselList(doc) : null;

          developments.add(development);
          developmentsStream.add(developments);
        });
      } else {
        developmentsStream.add(null);
      }
    });
    return developmentsStream;
  }

  List<Attachment> createAttachmentList(DocumentSnapshot doc) {
    List<Attachment> list = List<Attachment>();

    Future.forEach((doc.data()['attachments'] as List), (attachment) async {
      var attachmentItem = Attachment()
        ..date = Jiffy(attachment['date'].toDate())
        ..description = attachment['description'] ?? ""
        ..name = attachment['name']
        ..type = attachment['type']
        ..src = (attachment['type'] as String).contains("image")
            ? await getOptmizedAttachmentImageSize(
                developmentId: doc.id,
                deviceWidth: Style.devicePixelRatio * Style.horizontal(100),
                folder: "attachments",
                name: attachment['name'])
            : attachment['src'];

      list.add(attachmentItem);
    });

    return list;
  }

  List<CarouselItem> createCarouselList(DocumentSnapshot doc) {
    List<CarouselItem> list = List<CarouselItem>();

    Future.forEach((doc.data()['gallery'] as List), (item) async {
      var carouselItem = CarouselItem()
        ..src = item['type'] == "image"
            ? await getOptmizedAttachmentImageSize(
                developmentId: doc.id,
                deviceWidth: Style.devicePixelRatio * Style.horizontal(100),
                folder: "carousel",
                name: item['name'])
            : item['src']
        ..type = item['type']
        ..name = item['name']
        ..youtubeController = item['type'] == "youtube"
            ? YoutubePlayerController(
                initialVideoId: YoutubePlayer.convertUrlToId(item['src']),
                flags: YoutubePlayerFlags(
                    autoPlay: false, mute: false, disableDragSeek: true),
              )
            : null;

      list.add(carouselItem);
    });

    return list;
  }

  Stream<DevelopmentUnit> fetchDevelopmentUnits(
      {String developmentId, String companyId}) {
    var developmentUnitStream = BehaviorSubject<DevelopmentUnit>();

    FirebaseFirestore.instance
        .collection("development-units")
        .where("development.id", isEqualTo: developmentId)
        .where("company.id", isEqualTo: companyId)
        .snapshots()
        .listen((snapshot) {
      print("FIRESTORE: development-unit snapshot");

      if (snapshot.docs.isNotEmpty) {
        var developmentUnit = DevelopmentUnit();

        var doc = snapshot.docs.first;

        developmentUnit = DevelopmentUnit()
          ..development = doc.data()['development'] != null
              ? (DevelopmentReference()
                ..externalId = doc.data()['development']['externalId'].toInt()
                ..id = doc.data()['development']['id']
                ..name = doc.data()['development']['name']
                ..type = doc.data()['development']['type'])
              : null
          ..company = doc.data()['company'] != null
              ? (Reference()
                ..id = doc.data()['company']['id']
                ..name = doc.data()['company']['name'])
              : null
          ..blocks = (doc.data()['blocks'] as List)
              .map((block) => Block()
                ..active = block['active']
                ..id = block['id']
                ..name = block['name']
                ..externalId = block['externalId'].toInt()
                ..units = mountUnits(doc.data()['development']['type'],
                    block['name'], block['id'], (block['units'] as Iterable)))
              .toList();

        developmentUnitStream.add(developmentUnit);
      }
    });

    return developmentUnitStream;
  }

  Future<Block> fetchBlock({String blockId}) async {
    var blockDoc = await FirebaseFirestore.instance
        .collection("blocks")
        .doc(blockId)
        .get();

    Block block = Block();

    if (blockDoc.exists) {
      print("FIRESTORE: fetchBlock");

      block = Block()
        ..active = blockDoc.data()['active']
        ..id = blockId
        ..name = blockDoc.data()['name']
        ..externalId = blockDoc.data()['externalId'].toInt()
        ..deliveryDate = Jiffy(blockDoc.data()['deliveryDate']?.toDate());
    }

    return block;
  }

  Future<Iterable<Unit>> mountUnits(
      String type, String blockName, String blockId, Iterable unitList) {
    return Future<Iterable<Unit>>(() {
      return unitList.map((unit) => Unit()
        ..reservedBy = unit['reservedBy'] ?? null
        ..type = type
        ..externalId = unit['externalId'].toInt()
        ..area = (UnitArea()
          ..commonSquareMeters = unit['area']['commonSquareMeters'].toDouble()
          ..privateSquareMeters =
              unit['area']['privateSquareMeters'].toDouble())
        ..companyStatus = CompanyStatus()
        ..floor = unit['floor'].toInt()
        ..id = unit['id']
        ..name = unit['name']
        ..price = getUnitCurrentPrice(unit['price'].toDouble(), unit['prices'])
        ..room = unit['room'].toInt()
        ..status = unit['status']
        ..typology = unit['typology']
        ..block = (Reference()
          ..name = blockName
          ..id = blockId));
    });
  }

  getUnitCurrentPrice(double price, prices) {
    double currentPrice = 0.0;

    if (prices != null) {
      var currentPrices = prices // gets the most recent effectiveDate
          .where((p) => Jiffy() // everything before today
              .isAfter(Jiffy(p['effectiveDate'])))
          .reduce((p, n) => Jiffy(p['effectiveDate']) // the latest among them
                  .isAfter(Jiffy(n['effectiveDate']))
              ? p
              : n);

      if (Jiffy().isAfter(currentPrices['effectiveDate'])) {
        currentPrice = currentPrices['value'].toDouble();
      } else {
        currentPrice = price;
      }
    } else {
      currentPrice = price;
    }

    return currentPrice;
  }

//TODO: Filter bloc?
  Map<String, StatusFilter> initUnitFilters(
      {List<Block> blocks, Map<String, String> statusAvailable}) {
    Map<String, StatusFilter> filterStatus = Map<String, StatusFilter>();

    // fill with all available values
    statusAvailable.forEach((status, statusTranslated) {
      if (!filterStatus.containsKey(status)) {
        filterStatus[status.toLowerCase()] = StatusFilter()
          ..amount = 0
          ..selected = false
          ..status = statusTranslated;
      }
    });

    //count how much each proposal status has
    blocks.forEach((block) {
      block.units.then((value) {
        value.forEach((unit) {
          var statusLowerCase = unit.status.toLowerCase();
          if (filterStatus.containsKey(statusLowerCase)) {
            filterStatus[statusLowerCase].amount++;
            filterStatus[statusLowerCase].selected = true;
          } else {
            filterStatus[statusLowerCase] = StatusFilter()
              ..amount = 1
              ..selected = true;
          }
        });
      });
    });

    return filterStatus;
  }

  Map<String, String> initAvailableStatusList(
      Map<String, CompanyStatusConfig> unit, String deviceLocale) {
    var avaialableStatusList = Map<String, String>();

    unit.forEach((status, statusTranslated) {
      if (deviceLocale.toString() == "pt_BR") {
        avaialableStatusList[status] = statusTranslated.ptBR;
      } else {
        avaialableStatusList[status] = statusTranslated.enUS;
      }
    });

    return avaialableStatusList;
  }

  Map<FilterRange, double> getPriceRange(Iterable<Unit> units) {
    Map<FilterRange, double> _priceRange = {
      FilterRange.max: 0,
      FilterRange.min: double.maxFinite
    };

    units.forEach((unit) {
      if (unit.price > _priceRange[FilterRange.max]) {
        _priceRange[FilterRange.max] = unit.price;
        _priceRange[FilterRange.currentMax] = unit.price;
      }
      if (unit.price < _priceRange[FilterRange.min]) {
        _priceRange[FilterRange.min] = unit.price;
        _priceRange[FilterRange.currentMin] = unit.price;
      }
    });

    return _priceRange;
  }

  Map<FilterRange, double> getAreaRange(Iterable<Unit> units) {
    Map<FilterRange, double> _areaRange = {
      FilterRange.max: 0,
      FilterRange.min: 9999999999
    };

    units.forEach((unit) {
      if (unit.area.privateSquareMeters > _areaRange[FilterRange.max]) {
        _areaRange[FilterRange.max] = unit.area.privateSquareMeters;
        _areaRange[FilterRange.currentMax] = unit.area.privateSquareMeters;
      }
      if (unit.area.privateSquareMeters < _areaRange[FilterRange.min]) {
        _areaRange[FilterRange.min] = unit.area.privateSquareMeters;
        _areaRange[FilterRange.currentMin] = unit.area.privateSquareMeters;
      }
    });

    return _areaRange;
  }

  Map<int, bool> getRoomsRange(Iterable<Unit> units) {
    var _roomsRange = Map<int, bool>();

    units.forEach((unit) {
      if (!_roomsRange.keys.contains(unit.room)) {
        _roomsRange[unit.room] = true;
      }
    });

    Map<int, bool> _sortedList =
        new SplayTreeMap.from(_roomsRange, (a, b) => a.compareTo(b));

    return _sortedList;
  }

  DevelopmentUnit applyFilter(
      {DevelopmentUnit developmentUnit,
      Map<String, StatusFilter> filterStatus,
      Map<int, bool> filterRoomsRange,
      Map<FilterRange, double> filterAreaRange,
      Map<FilterRange, double> filterPriceRange}) {
    var filtredBlocks = List<Block>();

    developmentUnit.blocks.forEach((block) {
      filtredBlocks.add(Block()
        ..active = block.active
        ..externalId = block.externalId
        ..id = block.id
        ..name = block.name
        ..units = block.units.then((value) => value
            .where((unit) =>
                //by area
                (unit.area.privateSquareMeters >=
                        filterAreaRange[FilterRange.currentMin] &&
                    unit.area.privateSquareMeters <=
                        filterAreaRange[FilterRange.currentMax]) &&
                //by price
                (unit.price >= filterPriceRange[FilterRange.currentMin] &&
                    unit.price <= filterPriceRange[FilterRange.currentMax]) &&
                //by status
                (filterStatus[unit.status.toLowerCase()].selected) &&
                // //by rooms
                (filterRoomsRange[unit.room]))
            .toList()));
    });

    return DevelopmentUnit()
      ..blocks = filtredBlocks
      ..company = developmentUnit.company
      ..development = developmentUnit.development;
  }

  Future<String> getOptmizedAttachmentImageSize(
      {String name,
      double deviceWidth,
      String developmentId,
      String folder}) async {
    String fullName = name;
    String resizedImage;

    if (fullName != null && ConnectivityState().hasInternet) {
      if (deviceWidth <= 320) {
        var ref = storage.FirebaseStorage.instance.ref().child(
                'developmentsAttachments/$developmentId/$folder/${fullName.replaceAll(".", "_320x480.")}') ??
            null;

        resizedImage = await ref.getDownloadURL() ?? null;
      } else if (deviceWidth > 320 && deviceWidth <= 600) {
        var ref = storage.FirebaseStorage.instance.ref().child(
                'developmentsAttachments/$developmentId/$folder/${fullName.replaceAll(".", "_768x1280.")}') ??
            null;

        resizedImage = await ref.getDownloadURL() ?? null;
      } else if (deviceWidth > 600) {
        var ref = storage.FirebaseStorage.instance.ref().child(
                'developmentsAttachments/$developmentId/$folder/${fullName.replaceAll(".", "_1440x2560.")}') ??
            null;

        resizedImage = await ref?.getDownloadURL() ?? null;
      }
    }

    return resizedImage;
  }

  Future<Stream<DocumentSnapshot>> bookingRequest(
      User user,
      Unit unit,
      Block block,
      DevelopmentReference development,
      Company company,
      String description,
      Buyer buyer) async {
    var bookingRequest = await FirebaseFirestore.instance
        .collection("booking-requests")
        .doc(unit.id)
        .get();
    Stream<DocumentSnapshot> stream;

    if (!bookingRequest.exists) {
      Map<String, Object> request = mountReserveRequest(
          "reserve", company, user, unit, block, development,
          description: description, buyer: buyer);

      await FirebaseFirestore.instance
          .collection("booking-requests")
          .doc(unit.id)
          .set(request);
      stream = FirebaseFirestore.instance
          .collection("booking-requests")
          .doc(unit.id)
          .snapshots();
    } else {
      print("ERROR: Booking already exist");
      throw ("Booking already exist");
    }
    return stream;
  }

  Map<String, Object> mountReserveRequest(String reserveType, Company company,
      User user, Unit unit, Block block, DevelopmentReference development,
      {String description, Buyer buyer}) {
    var request = {
      "reserveType": reserveType,
      "buyer": buyer != null
          ? {
              "externalId": buyer.externalId,
              "id": buyer.id,
              "name": buyer.name,
            }
          : null,
      "user": {
        "externalId": company.externalId,
        "id": user.uid,
        "name": user.name,
      },
      "unit": {
        "externalId": unit.externalId,
        "id": unit.id,
        "name": unit.name,
      },
      "block": {
        "externalId": block.externalId,
        "id": block.id,
        "name": block.name,
      },
      "development": {
        "externalId": development.externalId,
        "id": development.id,
        "name": development.name,
        "type": development.type
      },
      "company": {
        "id": company.id,
        "name": company.name,
      },
      "description": description ?? null,
      "synchronized": "pending",
    };
    return request;
  }

  Future<Stream<DocumentSnapshot>> releaseReserveRequest(User user, Unit unit,
      Block block, DevelopmentReference development, Company company) async {
    var bookingRequest = await FirebaseFirestore.instance
        .collection("booking-requests")
        .doc(unit.id)
        .get();
    Stream<DocumentSnapshot> stream;

    if (!bookingRequest.exists) {
      Map<String, Object> request = mountReserveRequest(
          "release", company, user, unit, block, development);

      await FirebaseFirestore.instance
          .collection("booking-requests")
          .doc(unit.id)
          .set(request);
      stream = FirebaseFirestore.instance
          .collection("booking-requests")
          .doc(unit.id)
          .snapshots();
    } else {
      print("ERROR: Booking already exist");
      throw ("Booking already exist");
    }
    return stream;
  }

  deleteBookingRequest(String unitId) async {
    try {
      await FirebaseFirestore.instance
          .collection("booking-requests")
          .doc(unitId)
          .delete();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<bool> isUnitAvailable(String id) async {
    var doc =
        await FirebaseFirestore.instance.collection("units").doc(id).get();

    if (doc.exists) {
      return doc.data()["status"] == "available";
    } else {
      return false;
    }
  }
}
