-- Row Level Security & Access Control Policies

-- 1. ENABLE RLS ON ALL TABLES
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplier_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE exchange_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE refunds ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE marketing_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- 2. PUBLIC VIEW FOR CATALOG (Hiding supplier, costs, margins)
CREATE OR REPLACE VIEW public_products AS
SELECT
  p.id,
  p.slug,
  p.category_id,
  p.name_lo,
  p.name_th,
  p.name_en,
  p.desc_lo,
  p.desc_th,
  p.desc_en,
  p.images,
  c.slug AS category_slug,
  c.name_lo AS category_name_lo,
  c.name_th AS category_name_th
FROM products p
LEFT JOIN categories c ON c.id = p.category_id
WHERE p.status = 'active';

CREATE OR REPLACE VIEW public_variants AS
SELECT
  pv.id,
  pv.product_id,
  pv.sku,
  pv.option_label_lo,
  pv.option_label_th,
  pv.option_label_en,
  pv.price_kip,
  pv.is_active
FROM product_variants pv
JOIN products p ON p.id = pv.product_id
WHERE pv.is_active = true AND p.status = 'active';

-- 3. PERMISSIONS: Public Anonymous Read
CREATE POLICY "Public can view active categories"
  ON categories FOR SELECT TO anon, authenticated
  USING (true);

CREATE POLICY "Public can view active products"
  ON products FOR SELECT TO anon, authenticated
  USING (status = 'active');

CREATE POLICY "Public can view active variants"
  ON product_variants FOR SELECT TO anon, authenticated
  USING (is_active = true);

CREATE POLICY "Public can view store settings"
  ON store_settings FOR SELECT TO anon, authenticated
  USING (true);

-- 4. ORDER TRACKING POLICY (Only with tracking token)
CREATE POLICY "Public track order with token"
  ON orders FOR SELECT TO anon, authenticated
  USING (tracking_token::text = current_setting('request.headers', true)::json->>'x-tracking-token');

-- 5. SERVICE ROLE & ADMIN FULL ACCESS
CREATE POLICY "Service role full access categories" ON categories FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access products" ON products FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access product_variants" ON product_variants FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access suppliers" ON suppliers FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access supplier_products" ON supplier_products FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access product_costs" ON product_costs FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access exchange_rates" ON exchange_rates FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access customers" ON customers FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access orders" ON orders FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access order_items" ON order_items FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access payments" ON payments FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access refunds" ON refunds FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access purchase_orders" ON purchase_orders FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access purchase_order_items" ON purchase_order_items FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access shipments" ON shipments FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access inventory" ON inventory FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access expenses" ON expenses FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access financial_transactions" ON financial_transactions FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access marketing_campaigns" ON marketing_campaigns FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access ai_departments" ON ai_departments FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access ai_tasks" ON ai_tasks FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access ai_activity_logs" ON ai_activity_logs FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access approvals" ON approvals FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access notifications" ON notifications FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access store_settings" ON store_settings FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access audit_log" ON audit_log FOR ALL TO service_role USING (true);

-- 6. APPROVAL ENFORCEMENT TRIGGER
CREATE OR REPLACE FUNCTION verify_approval_before_action()
RETURNS TRIGGER AS $$
DECLARE
  v_status approval_status;
BEGIN
  IF NEW.approval_id IS NULL THEN
    RAISE EXCEPTION 'Action requires an explicit approval_id before creation/execution';
  END IF;

  SELECT status INTO v_status FROM approvals WHERE id = NEW.approval_id;
  IF v_status IS NULL OR v_status != 'approved' THEN
    RAISE EXCEPTION 'Action approval_id % is not approved (current status: %)', NEW.approval_id, v_status;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verify_purchase_order_approval
  BEFORE INSERT OR UPDATE OF approval_id, status
  ON purchase_orders
  FOR EACH ROW
  WHEN (NEW.status = 'ordered')
  EXECUTE FUNCTION verify_approval_before_action();

CREATE TRIGGER trg_verify_refund_approval
  BEFORE INSERT OR UPDATE OF approval_id, status
  ON refunds
  FOR EACH ROW
  EXECUTE FUNCTION verify_approval_before_action();
