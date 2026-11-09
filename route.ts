import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({
    status: 'ok',
    store: 'Slow Day Store',
    phase: 'Phase 0 - Foundation',
    timestamp: new Date().toISOString(),
  });
}
