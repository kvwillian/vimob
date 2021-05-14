export class Address {
  city: string;
  state: string;
  streetAddress: string;
  zipCode: string;
  neighborhood?: string;
  number?: string;
  complement?: string;
  constructor(
    city: string,
    state: string,
    streetAddress: string,
    zipCode: string,
    neighborhood?: string,
    number?: string,
    complement?: string
  ) {
    this.city = city;
    this.state = state;
    this.streetAddress = streetAddress;
    this.zipCode = zipCode;
    this.neighborhood = neighborhood;
    this.number = number;
    this.complement = complement;
  }
}
