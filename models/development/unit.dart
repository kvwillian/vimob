import 'package:vimob/models/proposal/proposal.dart';

class Unit {
  String id;
  int externalId;
  String name;
  String reservedBy;
  double price;
  Reference block;
  String type;
  String typology;
  int floor;
  int room;
  UnitArea area;
  String status;
  CompanyStatus companyStatus;
  Reference blueprint;

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'externalId': this.externalId,
      'reservedBy': this.reservedBy,
      'name': this.name,
      'price': this.price,
      'block': this.block.toMap(),
      'type': this.type,
      'typology': this.typology,
      'floor': this.floor,
      'room': this.room,
      'area': this.area.toMap(),
      // 'status': this.status,
      // 'companyStatus': this.companyStatus?.toMap(), //TODO: set companyStatus
      'status': this.companyStatus?.toMap(), //TODO: set companyStatus
      'blueprint': this.blueprint?.toMap()
    };
  }

  Map<String, dynamic> toMapDevelopmentUnit(Unit unit) {
    return {
      'id': unit.id,
      'externalId': unit.externalId,
      'name': unit.name,
      'price': unit.price,
      'block': unit.block.toMap(),
      'type': unit.type,
      'typology': unit.typology,
      'floor': unit.floor,
      'room': unit.room,
      'area': unit.area.toMap(),
      'status': unit.status,
      'blueprint': unit.blueprint?.toMap(),
      'reservedBy': unit.reservedBy
    };
  }
}

class UnitArea {
  double commonSquareMeters;
  double privateSquareMeters;

  Map<String, dynamic> toMap() {
    return {
      'commonSquareMeters': this.commonSquareMeters,
      'privateSquareMeters': this.privateSquareMeters,
    };
  }
}
