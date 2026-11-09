# Slow Day Store – แผนระบบฟรี 100% (Zero Budget Runbook)

ระบบนี้ออกแบบมาให้ไม่มีค่าใช้จ่ายรายเดือนแม้แต่บาทเดียว ($0/เดือน) ตลอดชีพ โดยต่อยอดจากประสบการณ์เดิมของโปรเจกต์ AUGUSTX

---

## 1. บริการฟรีที่ใช้
1. **โฮสติ้ง:** **GitHub Pages** (ฟรี ไม่จำกัดระยะเวลา แบนด์วิดท์กว้างขวาง)
2. **ฐานข้อมูล + ล็อกอิน + เก็บรูป:** **Firebase Free (Spark Plan)**
   - Firestore: 50,000 อ่าน / 20,000 เขียน ต่อวัน (สำหรับร้านเปิดใหม่ เหลือเฟือ)
   - Authentication: 50,000 ผู้ใช้ต่อเดือน
   - Storage (เก็บรูปสินค้า/สลิป): 5 GB
3. **โดเมน:** ใช้ Subdomain ฟรีของ GitHub Pages เช่น `username.github.io/slowday-store`
4. **AI:** ปิดไว้ทั้งหมด ทำงานด้วยมือ 100%

---

## 2. ขั้นตอนการตั้งค่า Firebase (ฟรี 100%)
1. เข้าไปที่ [Firebase Console](https://console.firebase.google.com/)
2. สร้างโปรเจกต์ใหม่ชื่อ `slowday-store` (เลือก Spark Plan ฟรี)
3. เปิดใช้งาน **Authentication**: เลือก Email/Password (สำหรับเจ้าของร้านล็อกอินหลังบ้าน)
4. เปิดใช้งาน **Cloud Firestore**: สร้าง Database ในโหมด Production
   - Collection หลัก: `products`, `orders`, `settings`
5. เปิดใช้งาน **Storage**: สร้าง Bucket เพื่อเก็บสลิปโอนเงินและรูปสินค้า
6. ไปที่ Project Settings -> คัดลอกค่า Firebase Config มาใส่ใน `.env.local`

---

## 3. ขั้นตอนการ Deploy บน GitHub Pages (ฟรี 100%)
1. Push โค้ดทั้งหมดขึ้น GitHub Repository `slowday-store`
2. ไปที่หน้า Repo บน GitHub -> **Settings** -> **Pages**
3. ที่หัวข้อ **Build and deployment** ให้เลือก Source เป็น **GitHub Actions**
4. เมื่อคุณ Push โค้ดเข้าสู่ Branch `main` ไฟล์ `.github/workflows/deploy-pages.yml` จะทำการ Build และ Deploy ให้โดยอัตโนมัติ
5. เว็บของคุณจะออนไลน์ที่ URL: `https://<your-username>.github.io/slowday-store`
