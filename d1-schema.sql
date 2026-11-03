-- CartonFlow / Barcode & Carton Management System
-- Run this entire file once in Cloudflare Dashboard > D1 > your database > Console.

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS cartons (
  id TEXT PRIMARY KEY,
  carton_number TEXT NOT NULL UNIQUE,
  carton_barcode TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL DEFAULT 'กำลังบันทึก' CHECK (status IN ('กำลังบันทึก', 'ปิดลัง')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  created_by TEXT NOT NULL DEFAULT 'ไม่ระบุ',
  closed_at TEXT
);

CREATE TABLE IF NOT EXISTS carton_items (
  id TEXT PRIMARY KEY,
  carton_id TEXT NOT NULL REFERENCES cartons(id) ON DELETE CASCADE,
  product_barcode TEXT NOT NULL,
  scanned_product_barcode TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  created_by TEXT NOT NULL DEFAULT 'ไม่ระบุ'
);

CREATE INDEX IF NOT EXISTS idx_cartons_created_at ON cartons(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_cartons_status ON cartons(status);
CREATE INDEX IF NOT EXISTS idx_cartons_barcode ON cartons(carton_barcode);
CREATE INDEX IF NOT EXISTS idx_carton_items_carton_id ON carton_items(carton_id);
CREATE INDEX IF NOT EXISTS idx_carton_items_product_barcode ON carton_items(product_barcode);
CREATE INDEX IF NOT EXISTS idx_carton_items_scanned_barcode ON carton_items(scanned_product_barcode);

-- Prevent adding, editing, or deleting items after a carton has been closed.
CREATE TRIGGER IF NOT EXISTS prevent_insert_item_into_closed_carton
BEFORE INSERT ON carton_items
WHEN (SELECT status FROM cartons WHERE id = NEW.carton_id) IS NOT 'กำลังบันทึก'
BEGIN
  SELECT RAISE(ABORT, 'ลังนี้ปิดแล้ว ไม่สามารถแก้ไขรายการสินค้าได้');
END;

CREATE TRIGGER IF NOT EXISTS prevent_update_item_in_closed_carton
BEFORE UPDATE ON carton_items
WHEN (SELECT status FROM cartons WHERE id = OLD.carton_id) IS NOT 'กำลังบันทึก'
  OR (SELECT status FROM cartons WHERE id = NEW.carton_id) IS NOT 'กำลังบันทึก'
BEGIN
  SELECT RAISE(ABORT, 'ลังนี้ปิดแล้ว ไม่สามารถแก้ไขรายการสินค้าได้');
END;

CREATE TRIGGER IF NOT EXISTS prevent_delete_item_from_closed_carton
BEFORE DELETE ON carton_items
WHEN (SELECT status FROM cartons WHERE id = OLD.carton_id) IS NOT 'กำลังบันทึก'
BEGIN
  SELECT RAISE(ABORT, 'ลังนี้ปิดแล้ว ไม่สามารถแก้ไขรายการสินค้าได้');
END;
