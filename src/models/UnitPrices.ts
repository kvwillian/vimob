import Price from "./Price";

export default class UnitPrices {
    externalId: number;
    effectiveDate: Price[];
    price;

    constructor(init?: Partial<UnitPrices>) {
        Object.assign(this, init);
    }
}