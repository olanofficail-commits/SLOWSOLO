-- Slow Day Store: Complete Database Schema (26 Tables)
-- Architecture Planning Phase (Nov 9, 2026)

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. ENUMS
CREATE TYPE product_status AS ENUM ('draft', 'active', 'archived');
CREATE TYPE supplier_platform AS ENUM ('taobao', 'pdd', '1688', 'other');
CREATE TYPE currency_pair_enum AS ENUM ('CNY_LAK', 'THB_LAK');
CREATE TYPE exchange_source AS ENUM ('manual', 'app');
CREATE TYPE preferred_lang_enum AS ENUM ('lo', 'th', 'en');
CREATE TYPE order_status AS ENUM (
  'pending_payment',
  'paid',
  'ordered_cn',
  'at_cn_warehouse',
  'in_transit',
  'arrived_la',
  'delivered',
  'completed',
  'cancelled',
  'refunded',
  'issue'
);
CREATE TYPE order_channel AS ENUM ('web', 'fb', 'wa', 'tiktok');
CREATE TYPE payment_method AS ENUM ('bank_qr', 'cash');
CREATE TYPE payment_status AS ENUM ('pending', 'verified', 'rejected');
CREATE TYPE approval_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE approval_action_type AS ENUM (
  'purchase',
  'transfer',
  'refund',
  'cancel',
  'publish_ad',
  'price_change'
);
CREATE TYPE shipment_leg AS ENUM ('cn_domestic', 'intl_cls', 'la_local');
CREATE TYPE shipment_status AS ENUM ('created', 'in_transit', 'customs', 'arrived', 'delivered', 'exception');
CREATE TYPE expense_category AS ENUM ('ads', 'packaging', 'fees', 'other');
CREATE TYPE fin_tx_type AS ENUM ('income', 'expense', 'refund', 'purchase');
CREATE TYPE ai_task_status AS ENUM ('queued', 'running', 'needs_approval', 'done', 'failed');
CREATE TYPE notification_audience AS ENUM ('owner', 'customer');
CREATE TYPE notification_channel AS ENUM ('in_app', 'wa_link');

-- 3. TABLES (GROUP 1: Catalog & Pricing)

-- 3.1 categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT NOT NULL UNIQUE,
  name_lo TEXT NOT NULL,
  name_th TEXT NOT NULL,
  name_en TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.2 products
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  slug TEXT NOT NULL UNIQUE,
  name_lo TEXT NOT NULL,
  name_th TEXT NOT NULL,
  name_en TEXT,
  desc_lo TEXT,
  desc_th TEXT,
  desc_en TEXT,
  status product_status NOT NULL DEFAULT 'draft',
  images TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.3 product_variants
CREATE TABLE product_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  sku TEXT NOT NULL UNIQUE,
  option_label_lo TEXT,
  option_label_th TEXT,
  option_label_en TEXT,
  price_kip BIGINT NOT NULL CHECK (price_kip >= 0),
  weight_kg NUMERIC(8,3) NOT NULL DEFAULT 0.1,
  box_l_cm NUMERIC(8,2) NOT NULL DEFAULT 10,
  box_w_cm NUMERIC(8,2) NOT NULL DEFAULT 10,
  box_h_cm NUMERIC(8,2) NOT NULL DEFAULT 10,
  needs_insurance BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.4 suppliers (Secret - Admin Only)
CREATE TABLE suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  platform supplier_platform NOT NULL DEFAULT 'taobao',
  shop_url TEXT,
  rating_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.5 supplier_products
CREATE TABLE supplier_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
  variant_id UUID NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
  source_url TEXT,
  source_sku_text TEXT,
  is_primary BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_supplier_variant UNIQUE(supplier_id, variant_id)
);

-- 3.6 exchange_rates
CREATE TABLE exchange_rates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  currency_pair currency_pair_enum NOT NULL,
  rate NUMERIC(14,4) NOT NULL,
  source exchange_source NOT NULL DEFAULT 'manual',
  effective_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_exchange_rates_pair_effective ON exchange_rates(currency_pair, effective_at DESC);

-- 3.7 product_costs (Historical cost tracking)
CREATE TABLE product_costs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  variant_id UUID NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
  price_cny NUMERIC(12,2) NOT NULL,
  china_ship_cny NUMERIC(12,2) NOT NULL DEFAULT 0,
  exchange_rate_id UUID REFERENCES exchange_rates(id),
  intl_ship_kip BIGINT NOT NULL DEFAULT 0,
  insurance_kip BIGINT NOT NULL DEFAULT 0,
  packaging_kip BIGINT NOT NULL DEFAULT 0,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_product_costs_variant_valid ON product_costs(variant_id, valid_from DESC);

-- GROUP 2: Customers, Orders & Payments

-- 3.8 customers
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name TEXT NOT NULL,
  phone TEXT UNIQUE,
  whatsapp TEXT,
  facebook_name TEXT,
  address_text TEXT,
  preferred_lang preferred_lang_enum NOT NULL DEFAULT 'lo',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.9 approvals
CREATE TABLE approvals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action_type approval_action_type NOT NULL,
  target_table TEXT NOT NULL,
  target_id UUID,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  requested_by TEXT NOT NULL DEFAULT 'owner',
  status approval_status NOT NULL DEFAULT 'pending',
  decided_at TIMESTAMPTZ,
  decision_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.10 orders
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  customer_id UUID NOT NULL REFERENCES customers(id),
  status order_status NOT NULL DEFAULT 'pending_payment',
  subtotal_kip BIGINT NOT NULL DEFAULT 0,
  shipping_kip BIGINT NOT NULL DEFAULT 0,
  discount_kip BIGINT NOT NULL DEFAULT 0,
  total_kip BIGINT NOT NULL DEFAULT 0,
  channel order_channel NOT NULL DEFAULT 'web',
  eta_from DATE,
  eta_to DATE,
  tracking_token UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_orders_status_created ON orders(status, created_at DESC);

-- 3.11 order_items
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  variant_id UUID NOT NULL REFERENCES product_variants(id),
  qty INT NOT NULL CHECK (qty > 0),
  unit_price_kip BIGINT NOT NULL,
  unit_cost_kip_snapshot BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.12 payments
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  amount_kip BIGINT NOT NULL,
  method payment_method NOT NULL DEFAULT 'bank_qr',
  slip_path TEXT,
  status payment_status NOT NULL DEFAULT 'pending',
  verified_by UUID,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.13 refunds
CREATE TABLE refunds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id),
  payment_id UUID REFERENCES payments(id),
  amount_kip BIGINT NOT NULL,
  reason TEXT,
  approval_id UUID NOT NULL REFERENCES approvals(id),
  status approval_status NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- GROUP 3: Procurement & China Orders

-- 3.14 purchase_orders
CREATE TABLE purchase_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id UUID REFERENCES suppliers(id),
  platform_order_no TEXT,
  total_cny NUMERIC(12,2) NOT NULL DEFAULT 0,
  rate_used NUMERIC(14,4) NOT NULL DEFAULT 0,
  paid_kip BIGINT NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft',
  approval_id UUID REFERENCES approvals(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.15 purchase_order_items
CREATE TABLE purchase_order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_order_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
  order_item_id UUID REFERENCES order_items(id),
  variant_id UUID NOT NULL REFERENCES product_variants(id),
  qty INT NOT NULL CHECK (qty > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- GROUP 4: Logistics & Inventory

-- 3.16 shipments
CREATE TABLE shipments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  leg shipment_leg NOT NULL,
  purchase_order_id UUID REFERENCES purchase_orders(id),
  order_id UUID REFERENCES orders(id),
  tracking_no TEXT,
  carrier TEXT,
  weight_kg NUMERIC(8,3),
  cost_kip BIGINT DEFAULT 0,
  status shipment_status NOT NULL DEFAULT 'created',
  events JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_shipments_tracking ON shipments(tracking_no);

-- 3.17 inventory
CREATE TABLE inventory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  variant_id UUID NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
  on_hand INT NOT NULL DEFAULT 0,
  reserved INT NOT NULL DEFAULT 0,
  location TEXT NOT NULL DEFAULT 'main',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_inventory_variant_loc UNIQUE(variant_id, location)
);

-- GROUP 5: Finance & Marketing

-- 3.18 expenses
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category expense_category NOT NULL DEFAULT 'other',
  amount_kip BIGINT NOT NULL,
  note TEXT,
  receipt_path TEXT,
  spent_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.19 financial_transactions (General Ledger)
CREATE TABLE financial_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type fin_tx_type NOT NULL,
  amount_kip BIGINT NOT NULL,
  ref_table TEXT NOT NULL,
  ref_id UUID,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.20 marketing_campaigns
CREATE TABLE marketing_campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  channel TEXT NOT NULL,
  budget_kip BIGINT NOT NULL DEFAULT 0,
  start_at TIMESTAMPTZ,
  end_at TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'draft',
  approval_id UUID REFERENCES approvals(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- GROUP 6: AI, Control & Governance

-- 3.21 ai_departments (16 Roles)
CREATE TABLE ai_departments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name_th TEXT NOT NULL,
  system_prompt TEXT NOT NULL,
  permissions JSONB NOT NULL DEFAULT '{}'::jsonb,
  input_schema JSONB,
  output_schema JSONB,
  handoff_to TEXT[] DEFAULT '{}',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.22 ai_tasks
CREATE TABLE ai_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  department_id UUID NOT NULL REFERENCES ai_departments(id),
  parent_task_id UUID REFERENCES ai_tasks(id),
  title TEXT NOT NULL,
  input JSONB NOT NULL DEFAULT '{}'::jsonb,
  output JSONB,
  status ai_task_status NOT NULL DEFAULT 'queued',
  requested_by TEXT NOT NULL DEFAULT 'system',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_ai_tasks_status_dept ON ai_tasks(status, department_id);

-- 3.23 ai_activity_logs
CREATE TABLE ai_activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES ai_tasks(id) ON DELETE CASCADE,
  department_id UUID REFERENCES ai_departments(id),
  action TEXT NOT NULL,
  tokens_in INT DEFAULT 0,
  tokens_out INT DEFAULT 0,
  cost_usd NUMERIC(10,5) DEFAULT 0,
  detail JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.24 notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  audience notification_audience NOT NULL DEFAULT 'owner',
  channel notification_channel NOT NULL DEFAULT 'in_app',
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.25 store_settings
CREATE TABLE store_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT NOT NULL UNIQUE,
  value JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.26 audit_log
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor TEXT NOT NULL,
  action TEXT NOT NULL,
  table_name TEXT NOT NULL,
  row_id UUID,
  before JSONB,
  after JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
