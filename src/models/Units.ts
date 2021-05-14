import DevelopmentReference from "./DevelopmentReference";
import BlockReference from "./BlockReference";
import Unit from "./Unit";

export default class Units {
  development: DevelopmentReference;
  block: BlockReference;
  units: [Unit];
  constructor(
    development: DevelopmentReference,
    block: BlockReference,
    units: [Unit],
  ) {
    this.development = development;
    this.block = block;
    this.units = units;
  }
}
