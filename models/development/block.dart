import 'package:jiffy/jiffy.dart';
import 'package:vimob/models/development/unit.dart';

class Block {
  String id;
  String name;
  int externalId;
  bool active;
  Future<Iterable<Unit>> units;
  Jiffy deliveryDate;

  Future<Map<String, dynamic>> toMap(Block block) async {
    var unitList = await block.units;

    return {
      'id': block.id,
      "name": block.name,
      'externalId': block.externalId,
      'active': block.active,
      'units': unitList.map((u) => u.toMapDevelopmentUnit(u)).toList()
    };
  }

  bool operator ==(other) => other is Block && toString() == other.toString();

  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "id: $id, name: $name, externalId: $externalId, active: $active, units: $units,";
  }
}
