export default class DevelopmentReference {
  id: string;
  name: string;
  externalId: number;
  type: DevelopmentType;
  constructor(
    id: string,
    name: string,
    externalId: number,
    type: DevelopmentType
  ) {
    this.id = id;
    this.name = name;
    this.externalId = externalId;
    this.type = type;
  }
}

type DevelopmentType = 'unit' | 'land';