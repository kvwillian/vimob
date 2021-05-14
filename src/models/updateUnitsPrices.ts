import UnitPrices from "./UnitPrices";

export default class UpdateUnitsPrices {
    unitsPrices: UnitPrices[];
    developmentExternalId: number;
    
    constructor(init?: Partial<UpdateUnitsPrices>) {
        Object.assign(this, init);
    }
}