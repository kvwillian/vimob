import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/models/development/block.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/development/unit.dart';
import 'package:vimob/models/user/user.dart';

class BookingRequest {
  User user;
  Unit unit;
  Block block;
  Development development;
  Company company;
  Buyer buyer;
  String description;
  String synchronized;

  Map<String, dynamic> toMap(BookingRequest bookingRequest) {
    return {
      "buyer": {
        "externalId": bookingRequest.buyer.externalId,
        "id": bookingRequest.buyer.id,
        "name": bookingRequest.buyer.name,
      },
      "user": {
        "externalId": bookingRequest.company.externalId,
        "id": bookingRequest.user.uid,
        "name": bookingRequest.user.name,
      },
      "unit": {
        "externalId": bookingRequest.unit.externalId,
        "id": bookingRequest.unit.id,
        "name": bookingRequest.unit.name,
      },
      "block": {
        "externalId": bookingRequest.block.externalId,
        "id": bookingRequest.block.id,
        "name": bookingRequest.block.name,
      },
      "development": {
        "externalId": bookingRequest.development.externalId,
        "id": bookingRequest.development.id,
        "name": bookingRequest.development.name,
        "type": bookingRequest.development.type
      },
      "company": {
        "id": bookingRequest.company.id,
        "name": bookingRequest.company.name,
      },
      "synchronized": bookingRequest.synchronized,
      "description": bookingRequest.description,
    };
  }
}
