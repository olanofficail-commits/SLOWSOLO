import React from 'react';

export default function TrackOrderPage({ params }: { params: { code: string } }) {
  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">ติดตามสถานะออเดอร์</h1>
      <div className="bg-white border border-sand-200 rounded-xl p-6 shadow-sm space-y-3">
        <p className="text-sm text-gray-500">รหัสคำสั่งซื้อ: <strong className="text-gray-900">{params.code}</strong></p>
        <p className="text-sm text-gray-600">สถานะ: <span className="bg-amber-100 text-amber-800 px-2 py-0.5 rounded text-xs">รอตรวจสอบการชำระเงิน</span></p>
      </div>
    </div>
  );
}
