# SLOWSOLO

ระบบบริหารจัดการร้านค้าพรีออเดอร์สินค้านำเข้าจากจีนสำหรับตลาดประเทศลาว (Vientiane, Laos)
พัฒนาด้วย **Next.js 14 (App Router)**, **TypeScript**, **Tailwind CSS**, และ **Supabase (PostgreSQL + RLS)**

## สถาปัตยกรรมระบบ
- **Storefront:** 3 ภาษา (Lao / Thai / English) รองรับการเลือกสินค้า ตะกร้า สั่งซื้อ ส่งสลิป และติดตามสถานะ
- **Admin:** แดชบอร์ดสำหรับเจ้าของร้าน 10 เมนู จัดการสินค้า ตรวจสลิป อนุมัติธุรกรรม คำนวณต้นทุน/กำไร
- **Security:** RLS ครบ 26 ตาราง, Private storage สำหรับสลิป, Triggers บังคับการอนุมัติ
- **Cost Engine:** คำนวณต้นทุนถึงมือตามเรทเงินจริง พร้อมคำนวณน้ำหนักปริมาตร (ก×ย×ส ÷ 5000)

## เริ่มต้นใช้งาน (Local Development)
```bash
# ติดตั้ง dependencies
npm install

# รันโหมดพัฒนา
npm run dev

# ตรวจสอบ Type
npm run typecheck

# รัน Unit Tests
npm run test
```

ดูรายละเอียดการตั้งค่าและ Deploy ได้ที่ `docs/runbook.md`
