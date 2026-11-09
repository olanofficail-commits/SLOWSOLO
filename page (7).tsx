import React from 'react';

export default function AdminDashboardPage() {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">ภาพรวมแดชบอร์ด (Overview)</h1>
        <span className="text-sm bg-green-100 text-green-800 font-medium px-3 py-1 rounded-full">Phase 0: Ready</span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded-xl border border-gray-200 shadow-sm">
          <div className="text-sm text-gray-500 font-medium">ยอดขายเดือนนี้</div>
          <div className="text-2xl font-bold text-gray-900 mt-1">— ₭</div>
        </div>
        <div className="bg-white p-5 rounded-xl border border-gray-200 shadow-sm">
          <div className="text-sm text-gray-500 font-medium">ออเดอร์ค้าง</div>
          <div className="text-2xl font-bold text-gray-900 mt-1">—</div>
        </div>
        <div className="bg-white p-5 rounded-xl border border-gray-200 shadow-sm">
          <div className="text-sm text-gray-500 font-medium">สลิปรอตรวจ</div>
          <div className="text-2xl font-bold text-gray-900 mt-1">—</div>
        </div>
        <div className="bg-white p-5 rounded-xl border border-gray-200 shadow-sm">
          <div className="text-sm text-gray-500 font-medium">กำไรประมาณการ</div>
          <div className="text-2xl font-bold text-gray-900 mt-1">— ₭</div>
        </div>
      </div>
    </div>
  );
}
