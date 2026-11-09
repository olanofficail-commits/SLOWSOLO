import React from 'react';

export default function StoreHomePage({ params }: { params: { locale: string } }) {
  return (
    <div className="space-y-8">
      <section className="bg-brand-50 border border-brand-100 rounded-2xl p-8 text-center space-y-4">
        <h1 className="text-3xl font-extrabold text-brand-900">SLOWSOLO</h1>
        <p className="text-gray-700 max-w-xl mx-auto">
          สินค้านำเข้าจากจีน พรีออเดอร์ 10–15 วัน จ่ายเต็ม 100% แจ้งสถานะทุกขั้นตอน เคลมได้ภายใน 24 ชม.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-bold text-gray-900">สินค้าแนะนำ</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
          <div className="border border-sand-200 bg-white rounded-xl p-4 shadow-sm hover:shadow-md transition">
            <div className="aspect-square bg-sand-100 rounded-lg mb-3 flex items-center justify-center text-gray-400">
              รูปภาพสินค้า
            </div>
            <h3 className="font-semibold text-gray-800">ชุดชงมัทฉะครบเซ็ต Handcrafted</h3>
            <p className="text-sm text-brand-700 font-bold mt-1">290,000 ₭</p>
            <span className="inline-block mt-2 text-xs bg-sand-200 text-gray-700 px-2 py-0.5 rounded">
              พรีออเดอร์ 10–15 วัน
            </span>
          </div>
        </div>
      </section>
    </div>
  );
}
