/**
 * Pricing and Landed Cost calculation for Slow Day Store
 *
 * Landed Cost Formula:
 * total_cost_kip = (price_cny + china_ship_cny) * rate_cny_lak + intl_ship_kip + insurance_kip + packaging_kip
 *
 * Chargeable Weight Formula:
 * chargeable_weight_kg = max(actual_weight_kg, (length_cm * width_cm * height_cm) / 5000)
 */

export interface CostCalculationInput {
  priceCny: number;
  chinaShipCny: number;
  exchangeRateCnyLak: number; // e.g., 3450 LAK per 1 CNY
  intlShipKip: bigint | number;
  insuranceKip?: bigint | number;
  packagingKip?: bigint | number;
}

export interface BoxDimensions {
  lengthCm: number;
  widthCm: number;
  heightCm: number;
  actualWeightKg: number;
}

export function calculateChargeableWeight(dimensions: BoxDimensions): number {
  const { lengthCm, widthCm, heightCm, actualWeightKg } = dimensions;
  const volumetricWeight = (lengthCm * widthCm * heightCm) / 5000;
  return Math.max(actualWeightKg, volumetricWeight);
}

export function calculateLandedCostKip(input: CostCalculationInput): bigint {
  const itemAndChinaShipCny = input.priceCny + input.chinaShipCny;
  const productKip = BigInt(Math.round(itemAndChinaShipCny * input.exchangeRateCnyLak));
  const intlShip = BigInt(input.intlShipKip);
  const insurance = BigInt(input.insuranceKip || 0);
  const packaging = BigInt(input.packagingKip || 0);

  return productKip + intlShip + insurance + packaging;
}

export function calculateProfitAndMargin(sellingPriceKip: bigint | number, landedCostKip: bigint | number): {
  profitKip: bigint;
  marginPercent: number;
} {
  const sell = BigInt(sellingPriceKip);
  const cost = BigInt(landedCostKip);
  const profitKip = sell - cost;
  
  if (sell <= BigInt(0)) {
    return { profitKip, marginPercent: 0 };
  }

  // Margin % = (Profit / Selling Price) * 100
  const marginPercent = Number((profitKip * BigInt(10000)) / sell) / 100;
  return { profitKip, marginPercent };
}
