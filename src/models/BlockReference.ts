export default class BlockReference {
  id: string;
  name: string;
  externalId: number;
  deliveryDate?: Date
  constructor(
    id: string,
    name: string,
    externalId: number,
    deliveryDate?: Date
  ) {
    this.id = id;
    this.name = name;
    this.externalId = externalId;
    this.deliveryDate = deliveryDate;
  }
}
