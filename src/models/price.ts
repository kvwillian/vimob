export default class UnitPrices {
    EFFECTIVEDATE: Date;
    VALUE: number;

    constructor(init?: Partial<UnitPrices>) {
        Object.assign(this, init);
    }
}