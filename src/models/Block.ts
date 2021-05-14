import DevelopmentReference from './DevelopmentReference';

export default class Block {
  development: DevelopmentReference;
  externalId: number;
  name: string;
  deliveryDate?: Date
  constructor(
    development: DevelopmentReference,
    externalId: number,
    name: string,
    deliveryDate?: Date
  ) {
    this.development = development;
    this.externalId = externalId;
    this.name = name;
    this.deliveryDate = deliveryDate;
  }
}
