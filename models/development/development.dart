import 'package:video_player/video_player.dart';
import 'package:vimob/models/development/block.dart';
import 'package:vimob/models/proposal/attachment.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Development {
  int externalId;
  String id;
  String name;
  String description;
  String type;
  String tourLink;
  int numberOfAvailableUnits;
  Address address;
  Reference company;
  String image;
  int reserveValidity;
  UnitOverview unitOverview;
  List<CarouselItem> gallery;
  List<Attachment> attachments;
}

class CarouselItem {
  String src;
  String type;
  String name;
  Duration currentTime;
  YoutubePlayerController youtubeController;
  VideoPlayerController videoController;
}

class UnitOverview {
  double maxPrice;
  double minPrice;
  int maxRooms;
  int minRooms;
  double maxArea;
  double minArea;
}

class Address {
  String city;
  String complement;
  String neighborhood;
  String number;
  String state;
  String streetAddress;
  String zipCode;
}

class DevelopmentReference {
  int externalId;
  String id;
  String name;
  String type;

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'type': this.type,
      'externalId': this.externalId,
    };
  }
}

class DevelopmentUnit {
  List<Block> blocks;
  Reference company;
  DevelopmentReference development;

  bool operator ==(other) =>
      other is DevelopmentUnit && toString() == other.toString();

  int get hashCode => company.hashCode;

  @override
  String toString() {
    return "blocks: $blocks," +
        (company != null
            ? "companyId: ${company.id}) , companyName: ${company.name})"
            : "") +
        (development != null
            ? "developmentId: ${development.id}, developmentName: ${development.name},developmentType: ${development.type},"
            : "");
  }
}
