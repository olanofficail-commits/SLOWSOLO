import {
  calculateChargeableWeight,
  calculateLandedCostKip,
  calculateProfitAndMargin,
  type CostCalculationInput,
  type BoxDimensions,
} from '@/lib/pricing';

export const PricingService = {
  getChargeableWeight: (dim: BoxDimensions) => calculateChargeableWeight(dim),
  getLandedCost: (input: CostCalculationInput) => calculateLandedCostKip(input),
  getMargin: (sellingPriceKip: bigint | number, landedCostKip: bigint | number) =>
    calculateProfitAndMargin(sellingPriceKip, landedCostKip),
};
