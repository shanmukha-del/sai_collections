-- 1. Create PRODUCTS table
CREATE TABLE IF NOT EXISTS products (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  category text,
  actual_price numeric,
  discount_price numeric,
  discount_perc numeric,
  quantity integer DEFAULT 0,
  description text,
  images text[], -- Array of URLs from Supabase Storage
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

-- 2. Create CATEGORIES table
CREATE TABLE IF NOT EXISTS categories (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

-- 3. Create ORDERS table
CREATE TABLE IF NOT EXISTS orders (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_name text NOT NULL,
  customer_phone text NOT NULL,
  customer_email text,
  user_id uuid,
  customer_address text NOT NULL,
  items jsonb NOT NULL,
  total_amount numeric NOT NULL,
  status text DEFAULT 'pending',
  invoice_url text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

-- 4. Enable RLS on tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 5. Create Policies with existence checks
DO $$ 
BEGIN
    -- Products Policies
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow Public Read' AND tablename = 'products') THEN
        CREATE POLICY "Allow Public Read" ON products FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow Admin Insert' AND tablename = 'products') THEN
        CREATE POLICY "Allow Admin Insert" ON products FOR INSERT WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow Admin Update' AND tablename = 'products') THEN
        CREATE POLICY "Allow Admin Update" ON products FOR UPDATE USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow Admin Delete' AND tablename = 'products') THEN
        CREATE POLICY "Allow Admin Delete" ON products FOR DELETE USING (true);
    END IF;

    -- Categories Policies
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow Public Read' AND tablename = 'categories') THEN
        CREATE POLICY "Allow Public Read" ON categories FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow Admin Insert' AND tablename = 'categories') THEN
        CREATE POLICY "Allow Admin Insert" ON categories FOR INSERT WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow Admin Update' AND tablename = 'categories') THEN
        CREATE POLICY "Allow Admin Update" ON categories FOR UPDATE USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow Admin Delete' AND tablename = 'categories') THEN
        CREATE POLICY "Allow Admin Delete" ON categories FOR DELETE USING (true);
    END IF;

    -- Orders Policies
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow Public Insert' AND tablename = 'orders') THEN
        CREATE POLICY "Allow Public Insert" ON orders FOR INSERT WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow Admin Read' AND tablename = 'orders') THEN
        CREATE POLICY "Allow Admin Read" ON orders FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow Admin Update' AND tablename = 'orders') THEN
        CREATE POLICY "Allow Admin Update" ON orders FOR UPDATE USING (true);
    END IF;

    -- Storage Policies (Simplified - assuming storage.objects schema exists)
    -- Note: These usually need to be run in the SQL editor specifically for storage.
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public Access' AND tablename = 'objects' AND schemaname = 'storage') THEN
        CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'product-images');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Admin Upload' AND tablename = 'objects' AND schemaname = 'storage') THEN
        CREATE POLICY "Admin Upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'product-images');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public Invoice Access' AND tablename = 'objects' AND schemaname = 'storage') THEN
        CREATE POLICY "Public Invoice Access" ON storage.objects FOR SELECT USING (bucket_id = 'order-invoices');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public Invoice Upload' AND tablename = 'objects' AND schemaname = 'storage') THEN
        CREATE POLICY "Public Invoice Upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'order-invoices');
    END IF;
END $$;
