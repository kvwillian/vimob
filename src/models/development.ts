import { Address } from './Address';

export default class Development {
  active: boolean;
  description: string;
  externalId: number;
  name: string;
  numberOfAvailableUnits: number;
  type: DevelopmentType;
  users: String;
  address?: Address;
  image?: string;
  constructor(
    active: boolean,
    description: string,
    externalId: number,
    name: string,
    numberOfAvailableUnits: number,
    type: DevelopmentType,
    users: String,
    address?: Address,
    image?: string,
  ) {
    this.active = active;
    this.description = description;
    this.externalId = externalId;
    this.name = name;
    this.numberOfAvailableUnits = numberOfAvailableUnits;
    this.type = type;
    this.address = address;
    this.users = users;
    this.image = image;
  }
}

type DevelopmentType = 'unit' | 'land';