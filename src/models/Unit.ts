export default class Unit {
  externalId: number;
  name: string;
  price: number;
  type: string;
  typology: string;
  area: Object;
  status: Object;
  floor: number;
  room: number;
  constructor(
    externalId: number,
    name: string,
    price: number,
    type: string,
    typology: string,
    area: Object,
    status: Object,
    floor: number,
    room: number,
  ) {
    this.externalId = externalId;
    this.name = name;
    this.price = price;
    this.type = type;
    this.typology = typology;
    this.area = area;
    this.status = status;
    this.floor = floor;
    this.room = room;
  }
}
