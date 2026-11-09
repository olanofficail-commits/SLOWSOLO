function calculateChargeableWeight(dimensions) {
  const { lengthCm, widthCm, heightCm, actualWeightKg } = dimensions;
  const volumetricWeight = (lengthCm * widthCm * heightCm) / 5000;
  return Math.max(actualWeightKg, volumetricWeight);
}

function calculateLandedCostKip(input) {
  const itemAndChinaShipCny = input.priceCny + input.chinaShipCny;
  const productKip = BigInt(Math.round(itemAndChinaShipCny * input.exchangeRateCnyLak));
  const intlShip = BigInt(input.intlShipKip);
  const insurance = BigInt(input.insuranceKip || 0);
  const packaging = BigInt(input.packagingKip || 0);

  return productKip + intlShip + insurance + packaging;
}

function calculateProfitAndMargin(sellingPriceKip, landedCostKip) {
  const sell = BigInt(sellingPriceKip);
  const cost = BigInt(landedCostKip);
  const profitKip = sell - cost;
  
  if (sell <= BigInt(0)) {
    return { profitKip, marginPercent: 0 };
  }

  const marginPercent = Number((profitKip * BigInt(10000)) / sell) / 100;
  return { profitKip, marginPercent };
}

module.exports = { calculateChargeableWeight, calculateLandedCostKip, calculateProfitAndMargin };
