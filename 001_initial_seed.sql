-- Initial Seed Data: Store Rules, Exchange Rates, and AI Department Roles

-- 1. STORE SETTINGS (Store rules: lead time 10-15d, 100% upfront, 24h claim)
INSERT INTO store_settings (key, value) VALUES
('lead_time_days', '{"min": 10, "max": 15, "note": "Pre-order delivery takes approximately 10-15 days"}'::jsonb),
('payment_rule', '{"upfront_percent": 100, "note": "100% upfront payment via Bank QR / Transfer"}'::jsonb),
('claim_policy', '{"window_hours": 24, "note": "Report damage or claims within 24 hours of package delivery"}'::jsonb),
('shipping_rates', '{"flat_rate_vientiane_kip": 25000, "flat_rate_province_kip": 35000}'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- 2. EXCHANGE RATES
INSERT INTO exchange_rates (currency_pair, rate, source) VALUES
('CNY_LAK', 3450.0000, 'manual'),
('THB_LAK', 720.0000, 'manual');

-- 3. SAMPLE CATEGORIES
INSERT INTO categories (slug, name_lo, name_th, name_en, sort_order) VALUES
('matcha-tea', 'ອຸປະກອນຊາຂຽວ ມັດຊະ', 'อุปกรณ์ชงชาเขียว มัทฉะ', 'Matcha Tea Ware', 1),
('lifestyle-home', 'ຂອງຕົກແຕ່ງບ້ານ ແລະ ເຄື່ອງໃຊ້', 'ของแต่งบ้านและของใช้', 'Home & Lifestyle', 2)
ON CONFLICT (slug) DO NOTHING;

-- 4. 16 AI DEPARTMENTS
INSERT INTO ai_departments (code, name_th, system_prompt, permissions, handoff_to) VALUES
('01', 'ผู้ประสานงานหลัก (CEO)', 'ทำหน้าที่กระจายงานและติดตามผลของทุกแผนก', '{"can_create_tasks": true}'::jsonb, '{"02","03","04","05"}'),
('02', 'ฝ่ายสรรหาสินค้า (Sourcing)', 'วิเคราะห์ลิงก์สินค้า Taobao/1688 คำนวณราคาและประเมินคุณภาพ', '{"read_catalog": true}'::jsonb, '{"03"}'),
('03', 'ฝ่ายตั้งราคาและต้นทุน (Pricing)', 'คำนวณต้นทุนถึงมือและแนะนำราคาขายตามสูตร', '{"read_costs": true}'::jsonb, '{"04"}'),
('04', 'ฝ่ายจัดซื้อจีน (Procurement)', 'เตรียมรายการสั่งซื้อและคำขออนุมัติ PO', '{"draft_po": true}'::jsonb, '{"05"}'),
('05', 'ฝ่ายติดตามขนส่ง (Logistics)', 'ติดตามพัสดุ 3 ขา (จีน -> คลัง CLS -> ลาว)', '{"read_shipments": true}'::jsonb, '{"06"}'),
('06', 'ฝ่ายคลังและสต็อก (Inventory)', 'ตรวจสอบสินค้าคงเหลือและการจอง', '{"read_stock": true}'::jsonb, '{"07"}'),
('07', 'ฝ่ายบริการลูกค้า (CS & Support)', 'ร่างข้อความแจ้งสถานะและตอบข้อสงสัยลูกค้า', '{"draft_messages": true}'::jsonb, '{"08"}'),
('08', 'ฝ่ายตรวจสอบสลิป (Payment Audit)', 'ช่วยตรวจสอบข้อมูลสลิปเบื้องต้นเพื่อส่งต่อให้อนุมัติ', '{"read_slips": true}'::jsonb, '{"09"}'),
('09', 'ฝ่ายบัญชีและภาษี (Accounting)', 'บันทึกสมุดรายรับรายจ่ายและกำไรขาดทุน', '{"read_ledger": true}'::jsonb, '{"10"}'),
('10', 'ฝ่ายสร้างคอนเทนต์ (Content Creator)', 'ร่างแคปชัน ข้อความโปรโมตภาษาลาว/ไทย', '{"draft_content": true}'::jsonb, '{"11"}'),
('11', 'ฝ่ายยิงโฆษณา (Ad Manager)', 'วางแผนแคมเปญโฆษณาและเสนองบประมาณ', '{"draft_campaigns": true}'::jsonb, '{"12"}'),
('12', 'ฝ่ายวิเคราะห์ข้อมูล (BI & Analytics)', 'วิเคราะห์ยอดขาย สินค้าขายดี และพฤติกรรมลูกค้า', '{"read_analytics": true}'::jsonb, '{"13"}'),
('13', 'ฝ่ายบริหารสินค้า (Merchandising)', 'จัดการสถานะสินค้า การจัดหมวดหมู่ และโปรโมชัน', '{"draft_products": true}'::jsonb, '{"14"}'),
('14', 'ฝ่ายตรวจคุณภาพและความเสี่ยง (Risk & QA)', 'ประเมินความเสี่ยงเรื่องอัตราแลกเปลี่ยนและขนส่งช้า', '{"read_system": true}'::jsonb, '{"15"}'),
('15', 'ฝ่ายกฎหมายและนโยบาย (Compliance)', 'ดูแลนโยบายการคืนเงินและคุ้มครองข้อมูลส่วนบุคคล', '{"read_policies": true}'::jsonb, '{"16"}'),
('16', 'ฝ่ายพัฒนาระบบอัตโนมัติ (Automation)', 'ดูแล webhook คิวงาน และตรวจสอบ log ความผิดพลาด', '{"read_logs": true}'::jsonb, '{}')
ON CONFLICT (code) DO NOTHING;
