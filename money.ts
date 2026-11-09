/**
 * Money utilities for Slow Day Store
 * - LAK (Lao Kip) is stored as BigInt (integers only, no decimals)
 * - CNY (Chinese Yuan) is stored as decimal number with 2 decimal places
 * - THB (Thai Baht) is handled as decimal/integer
 */

export function formatKip(amount: bigint | number): string {
  const n = typeof amount === 'bigint' ? amount : BigInt(Math.round(amount));
  return new Intl.NumberFormat('en-US').format(n) + ' ₭';
}

export function formatCNY(amount: number): string {
  return '¥ ' + amount.toFixed(2);
}

export function formatTHB(amount: number): string {
  return '฿ ' + new Intl.NumberFormat('en-US', { maximumFractionDigits: 2 }).format(amount);
}

export function parseKip(str: string): bigint {
  const cleaned = str.replace(/[^0-9]/g, '');
  if (!cleaned) return BigInt(0);
  return BigInt(cleaned);
}
