const assert = require('assert');

console.log('--- Running Slow Day Store Unit Tests ---');

// Test 1: Money Formatting
const { formatKip, formatCNY, formatTHB, parseKip } = require('../../dist_test_money.js');

assert.strictEqual(formatKip(150000n), '150,000 ₭', 'Kip bigint formatting mismatch');
assert.strictEqual(formatKip(2500000), '2,500,000 ₭', 'Kip number formatting mismatch');
assert.strictEqual(formatCNY(45.5), '¥ 45.50', 'CNY formatting mismatch');
assert.strictEqual(parseKip('150,000 ₭'), 150000n, 'Kip parsing mismatch');
console.log('✓ Money utilities tests passed');

// Test 2: Pricing & Volumetric Weight
const { calculateChargeableWeight, calculateLandedCostKip, calculateProfitAndMargin } = require('../../dist_test_pricing.js');

// Box: 20x15x10 cm, actual 0.5 kg -> volumetric = 3000 / 5000 = 0.6 kg -> chargeable = 0.6 kg
const dims = { lengthCm: 20, widthCm: 15, heightCm: 10, actualWeightKg: 0.5 };
const chargeableWeight = calculateChargeableWeight(dims);
assert.strictEqual(chargeableWeight, 0.6, 'Chargeable weight mismatch');

// Landed Cost:
// priceCny = 50, chinaShipCny = 5, rate = 3450
// productKip = (50 + 5) * 3450 = 189,750
// intlShipKip = 25,000
// insuranceKip = 5,000
// packagingKip = 3,000
// Total Landed Cost = 189,750 + 25,000 + 5,000 + 3,000 = 222,750 Kip
const landedCost = calculateLandedCostKip({
  priceCny: 50,
  chinaShipCny: 5,
  exchangeRateCnyLak: 3450,
  intlShipKip: 25000,
  insuranceKip: 5000,
  packagingKip: 3000,
});
assert.strictEqual(landedCost, 222750n, 'Landed cost calculation mismatch');

// Profit & Margin:
// Selling price = 320,000 Kip, Landed cost = 222,750 Kip
// Profit = 97,250 Kip
// Margin = (97250 / 320000) * 100 = 30.39%
const margin = calculateProfitAndMargin(320000n, landedCost);
assert.strictEqual(margin.profitKip, 97250n, 'Profit mismatch');
assert.ok(Math.abs(margin.marginPercent - 30.39) < 0.1, 'Margin percent mismatch');
console.log('✓ Pricing and margin calculation tests passed');

console.log('\nAll unit tests completed successfully!');
