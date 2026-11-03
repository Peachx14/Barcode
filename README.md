# Barcode & Carton Management System — Cloudflare Shared Edition

ระบบจัดการลังสินค้าและบาร์โค้ดแบบ Shared Database สำหรับใช้งานผ่าน Cloudflare Pages + Pages Functions + D1

## คุณสมบัติ
- ไม่ต้อง Login และไม่ต้องสร้างบัญชีพนักงาน
- ทุกเครื่องเห็นข้อมูลลังและสินค้าเดียวกันผ่าน Cloudflare D1
- Dashboard, สร้างลัง, เพิ่มสินค้า, ปิดลัง, ค้นหา และ Export Excel
- สแกน Barcode ผ่านกล้องมือถือ/คอมพิวเตอร์ (ต้องเปิดผ่าน HTTPS และอนุญาตกล้อง)
- ป้องกันการเพิ่ม/แก้ไข/ลบรายการสินค้าในลังที่ปิดแล้วด้วย D1 triggers
- เชื่อม GitHub กับ Cloudflare Pages เพื่อ Deploy อัตโนมัติเมื่อ Push/อัปโหลดไฟล์ใหม่
- ไม่ต้องติดตั้ง Node.js, ไม่ต้องใช้ Terminal และไม่ต้องรันคำสั่งบนเครื่องผู้ใช้

## ติดตั้งครั้งแรก (ทำผ่านหน้าเว็บทั้งหมด)

### 1. อัปโหลดโปรเจกต์ขึ้น GitHub
1. ดาวน์โหลด ZIP และแตกไฟล์
2. สร้าง Repository ใหม่บน https://github.com/new
3. ตั้งชื่อ เช่น `barcode-carton-management`
4. เลือก Public หรือ Private ได้ตามต้องการ แล้วกด Create repository
5. ในหน้า Repository เลือก **Add file → Upload files**
6. ลากไฟล์และโฟลเดอร์ทั้งหมด *ภายใน ZIP* ขึ้นไป (ต้องเห็น `index.html`, `src`, `functions`, `package.json` และ `d1-schema.sql` อยู่ระดับบนสุด)
7. กด **Commit changes**

### 2. สร้างฐานข้อมูล Cloudflare D1
1. สมัคร/เข้าสู่ระบบ https://dash.cloudflare.com/
2. เปิดเมนู **Storage & databases → D1 SQL Database** (ชื่อเมนูอาจแสดงเป็น **D1**)
3. กด **Create database**
4. ตั้งชื่อ `cartonflow-db` แล้วกด Create
5. เปิดฐานข้อมูลที่สร้าง แล้วเลือกแท็บ **Console**
6. เปิดไฟล์ `d1-schema.sql` จาก Repository บน GitHub แล้วคัดลอกเนื้อหาทั้งหมด
7. วางใน D1 Console แล้วกด **Execute**
8. ตรวจสอบว่าเห็นตาราง `cartons` และ `carton_items`

### 3. เชื่อม GitHub กับ Cloudflare Pages
1. ใน Cloudflare Dashboard ไปที่ **Workers & Pages**
2. กด **Create application → Pages → Connect to Git** (หรือ Create project → Connect to Git)
3. เชื่อมบัญชี GitHub และอนุญาต Cloudflare เข้าถึง Repository นี้
4. เลือก Repository `barcode-carton-management`
5. ตั้งค่า Build:
   - Framework preset: **Vite** (ถ้ามีให้เลือก)
   - Production branch: `main` (หรือ branch หลักที่ใช้จริง)
   - Build command: `npm run build`
   - Build output directory: `dist`
6. กด **Save and Deploy** แล้วรอ Build สำเร็จ

### 4. ผูก D1 เข้ากับ Pages Functions
1. เปิด Pages project ที่เพิ่งสร้าง
2. ไปที่ **Settings → Bindings**
3. เลือก **Add → D1 database**
4. Variable name ใส่ `DB` (ต้องเป็นตัวพิมพ์ใหญ่ตามนี้)
5. เลือกฐานข้อมูล `cartonflow-db`
6. กด Save
7. กลับไปแท็บ **Deployments** แล้วกด **Retry deployment** หรือสร้าง Commit เปล่า/แก้ README แล้ว Commit เพื่อให้ Deploy ใหม่
8. เปิด URL ของ Pages project

### 5. ตรวจสอบระบบ
- หน้าเว็บควรแสดง Dashboard โดยไม่มีข้อความเชื่อมต่อไม่สำเร็จ
- ทดสอบสร้างลัง 1 ใบ
- เปิดเว็บเดียวกันบนมือถือ/คอมพิวเตอร์อีกเครื่อง ข้อมูลลังต้องปรากฏเหมือนกัน
- เพิ่มสินค้าและทดลองปิดลัง
- หลังปิดลังต้องไม่สามารถเพิ่มสินค้าเข้าไปได้
- ทดสอบค้นหาและ Export Excel
- ทดสอบกล้องผ่าน HTTPS

## การอัปเดตในอนาคต
แก้ไขไฟล์ใน GitHub แล้วกด **Commit changes** — Cloudflare Pages จะ Build และ Deploy ให้อัตโนมัติ ไม่ต้องใช้ Terminal หรือ Git CLI

## API และโครงสร้าง
- `GET /api/health` ตรวจการเชื่อมต่อ D1
- `GET /api/cartons` อ่านลังและรายการสินค้าทั้งหมด
- `POST /api/cartons` สร้างลัง
- `POST /api/items` เพิ่มสินค้าเข้าลัง
- `POST /api/cartons/:id/close` ปิดลัง
- `functions/api/[[path]].js` คือ Pages Functions API
- `d1-schema.sql` คือโครงสร้างฐานข้อมูลและ triggers

## ข้อควรทราบเรื่องความปลอดภัยและความเสถียร
- ระบบนี้ไม่มี Login ตามที่กำหนด ดังนั้นผู้ที่เข้าถึง URL สาธารณะสามารถเรียก API และอ่าน/เขียนข้อมูลได้ ไม่ควรเก็บข้อมูลลับหรือข้อมูลส่วนบุคคลสำคัญ
- D1 เป็นฐานข้อมูลออนไลน์ส่วนกลาง ไม่ใช่ LocalStorage; ทุกอุปกรณ์อ่าน/เขียนฐานเดียวกัน
- แผนฟรีมีโควตาการใช้งานและข้อจำกัดตาม Cloudflare Free plan หากใช้งานเกินโควตาอาจต้องรอรอบใหม่หรืออัปเกรด
- ไม่มีผู้ให้บริการใดรับประกัน uptime 100%; Cloudflare เป็นบริการที่มีความพร้อมใช้งานสูง แต่ยังอาจเกิดเหตุขัดข้องได้
- ควร Export Excel สำรองข้อมูลเป็นระยะ

## สำหรับผู้พัฒนา (ไม่จำเป็นสำหรับผู้ใช้)
ต้องการทดสอบในเครื่องสามารถใช้ `npm install` และ `npm run dev` ได้ แต่การติดตั้งและ Deploy ตามคู่มือนี้ไม่ต้องรันคำสั่งในเครื่องผู้ใช้
