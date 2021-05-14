export default class UnitReference {
  id: string;
  externalId: number;
  name: string;
  constructor(
    id: string,
    externalId: number,
    name: string
  ) {
    this.id = id;
    this.externalId = externalId;
    this.name = name;
  }
}
