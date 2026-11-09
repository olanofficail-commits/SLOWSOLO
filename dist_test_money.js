function formatKip(amount) {
  const n = typeof amount === 'bigint' ? amount : BigInt(Math.round(amount));
  return new Intl.NumberFormat('en-US').format(n) + ' ₭';
}

function formatCNY(amount) {
  return '¥ ' + amount.toFixed(2);
}

function formatTHB(amount) {
  return '฿ ' + new Intl.NumberFormat('en-US', { maximumFractionDigits: 2 }).format(amount);
}

function parseKip(str) {
  const cleaned = str.replace(/[^0-9]/g, '');
  if (!cleaned) return BigInt(0);
  return BigInt(cleaned);
}

module.exports = { formatKip, formatCNY, formatTHB, parseKip };
