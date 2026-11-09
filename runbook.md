# Slow Day Store – Runbook การตั้งค่าระบบ (Owner Runbook)

คู่มือนี้สรุปขั้นตอนที่เจ้าของร้านต้องดำเนินการด้วยตนเองสำหรับบริการภายนอก (GitHub, Supabase, Vercel) เพื่อความปลอดภัยสูงสุด โดยไม่ต้องส่งรหัสผ่านหรือ API Key ในแชต

---

## 1. การตั้งค่า GitHub Repository
1. เข้าไปที่ [GitHub](https://github.com) แล้วสร้าง New Repository ชื่อ `slowday-store` (แนะนำให้ตั้งเป็น **Private**)
2. ทำการ Push โค้ดขึ้น Repository:
   ```bash
   git remote add origin git@github.com:<your-username>/slowday-store.git
   git branch -M main
   git push -u origin main
   ```
3. ตั้งค่า Branch Protection สำหรับ `main` (ให้เปิด PR และผ่าน CI ก่อน merge)

---

## 2. การตั้งค่า Supabase (Database & Storage)
สร้าง 2 โปรเจกต์บน [Supabase](https://supabase.com):
- `slowday-store-dev` (สำหรับพัฒนาและทดสอบ)
- `slowday-store-prod` (สำหรับเปิดขายจริง)

### ขั้นตอนการรัน Migration:
1. เข้าไปที่ Supabase Console -> **SQL Editor**
2. คัดลอกเนื้อหาจากไฟล์ `supabase/migrations/20261109000001_initial_schema.sql` แล้วกด **Run**
3. คัดลอกเนื้อหาจากไฟล์ `supabase/migrations/20261109000002_rls_and_security.sql` แล้วกด **Run**
4. คัดลอกเนื้อหาจากไฟล์ `supabase/seed/001_initial_seed.sql` แล้วกด **Run**
5. ตรวจสอบที่ **Table Editor** ว่ามีตารางครบ 26 ตารางและเปิด RLS ครบทุกตาราง

### การตั้งค่า Storage:
- สร้าง Bucket ชื่อ `slips` (ตั้งค่าเป็น **Private**) สำหรับเก็บรูปสลิปโอนเงิน
- สร้าง Bucket ชื่อ `products` (ตั้งค่าเป็น **Public**) สำหรับเก็บรูปภาพสินค้า

---

## 3. การเชื่อมต่อกับ Vercel
1. เข้าไปที่ [Vercel](https://vercel.com) แล้วเลือก **Add New Project** -> Import repository `slowday-store`
2. ในส่วน **Environment Variables** ให้ใส่ค่าดังนี้:
   - `NEXT_PUBLIC_SUPABASE_URL`: URL ของโปรเจกต์ Supabase
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Anon Key ของ Supabase
   - `SUPABASE_SERVICE_ROLE_KEY`: Service Role Key (ห้ามเผยแพร่)
   - `OWNER_USER_ID`: User UUID ของเจ้าของใน Supabase Auth
   - `NEXT_PUBLIC_SITE_URL`: URL โดเมนร้านค้า
3. กด **Deploy**

---

## 4. กฎเหล็กด้านความปลอดภัย
- ไม่คอมมิตไฟล์ `.env` หรือ `.env.local` ลง Git
- สลิปโอนเงินของลูกค้าและใบเสร็จค่าใช้จ่ายจัดเก็บใน Private Storage เปิดดูผ่าน Signed URL เท่านั้น
- คำสั่งซื้อจีน (PO) และการคืนเงิน (Refund) จะต้องมีบันทึกการอนุมัติในตาราง `approvals` เสมอ
