import { z } from 'zod';

export const CustomerSchema = z.object({
  displayName: z.string().min(2, 'Name is required'),
  phone: z.string().min(6, 'Valid phone number is required'),
  whatsapp: z.string().optional(),
  facebookName: z.string().optional(),
  addressText: z.string().min(5, 'Delivery address is required'),
  preferredLang: z.enum(['lo', 'th', 'en']).default('lo'),
});

export const OrderItemSchema = z.object({
  variantId: z.string().uuid(),
  qty: z.number().int().positive(),
  unitPriceKip: z.number().int().nonnegative(),
});

export const CreateOrderSchema = z.object({
  customer: CustomerSchema,
  items: z.array(OrderItemSchema).min(1, 'Cart cannot be empty'),
  channel: z.enum(['web', 'fb', 'wa', 'tiktok']).default('web'),
});

export const PaymentSlipSchema = z.object({
  orderId: z.string().uuid(),
  amountKip: z.number().int().positive(),
  method: z.enum(['bank_qr', 'cash']).default('bank_qr'),
});

export const ProductVariantSchema = z.object({
  sku: z.string().min(3),
  optionLabel: z.object({
    lo: z.string().optional(),
    th: z.string().optional(),
    en: z.string().optional(),
  }),
  priceKip: z.number().int().nonnegative(),
  weightKg: z.number().positive(),
  boxL: z.number().positive(),
  boxW: z.number().positive(),
  boxH: z.number().positive(),
  needsInsurance: z.boolean().default(false),
  isActive: z.boolean().default(true),
});
