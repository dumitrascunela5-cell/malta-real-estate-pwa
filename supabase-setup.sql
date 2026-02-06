-- Malta Real Estate PRO - Complete Database Setup v4
-- Run this in Supabase SQL Editor

-- Drop existing tables to recreate with correct schema
DROP TABLE IF EXISTS price_history CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS viewings CASCADE;
DROP TABLE IF EXISTS communications CASCADE;
DROP TABLE IF EXISTS reminders CASCADE;
DROP TABLE IF EXISTS deals CASCADE;
DROP TABLE IF EXISTS daily_notes CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS properties CASCADE;

-- 1. Properties Table - COMPLETE REDESIGN
CREATE TABLE properties (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    reference_number TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL CHECK (type IN ('Apartment', 'Penthouse', 'House', 'Duplex', 'Studio', 'Maisonette', 'Villa', 'Townhouse', 'Farmhouse', 'Office', 'Shop', 'Warehouse')),
    bedrooms INTEGER NOT NULL,
    available_from DATE NOT NULL,
    price_per_month DECIMAL(10, 2) NOT NULL,
    negotiable BOOLEAN DEFAULT false,
    location TEXT NOT NULL,
    notes TEXT,
    added_by TEXT NOT NULL CHECK (added_by IN ('Gabriel QL', 'Georgiana QL')),
    status TEXT DEFAULT 'available' CHECK (status IN ('available', 'rented', 'pending')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Clients Table - COMPLETE REDESIGN
CREATE TABLE clients (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    looking_for TEXT[] NOT NULL, -- Array of property types
    locations TEXT[] NOT NULL, -- Array of preferred locations
    moving_date DATE NOT NULL,
    nationality TEXT NOT NULL,
    occupation TEXT NOT NULL,
    how_many_people INTEGER NOT NULL,
    pets BOOLEAN DEFAULT false,
    let_type TEXT NOT NULL CHECK (let_type IN ('Long Let', 'Short Let')),
    budget DECIMAL(10, 2) NOT NULL,
    min_bedrooms INTEGER NOT NULL,
    max_bedrooms INTEGER,
    other_requirements TEXT,
    notes TEXT,
    added_by TEXT NOT NULL CHECK (added_by IN ('Gabriel QL', 'Georgiana QL')),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'closed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_properties_type ON properties(type);
CREATE INDEX idx_properties_location ON properties(location);
CREATE INDEX idx_properties_price ON properties(price_per_month);
CREATE INDEX idx_properties_bedrooms ON properties(bedrooms);
CREATE INDEX idx_properties_available_from ON properties(available_from);
CREATE INDEX idx_properties_added_by ON properties(added_by);
CREATE INDEX idx_clients_locations ON clients USING GIN(locations);
CREATE INDEX idx_clients_looking_for ON clients USING GIN(looking_for);
CREATE INDEX idx_clients_budget ON clients(budget);
CREATE INDEX idx_clients_moving_date ON clients(moving_date);
CREATE INDEX idx_clients_added_by ON clients(added_by);

-- Enable Row Level Security
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;

-- Create policies for public access
CREATE POLICY "Enable all for properties" ON properties FOR ALL USING (true);
CREATE POLICY "Enable all for clients" ON clients FOR ALL USING (true);

-- Trigger to automatically update 'updated_at' timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_properties_updated_at BEFORE UPDATE ON properties
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample data for testing
INSERT INTO properties (reference_number, type, bedrooms, available_from, price_per_month, negotiable, location, notes, added_by) VALUES
    ('REF-001', 'Apartment', 2, CURRENT_DATE + INTERVAL '7 days', 1200, false, 'Sliema', 'Sea view, fully furnished', 'Gabriel QL'),
    ('REF-002', 'Penthouse', 3, CURRENT_DATE + INTERVAL '14 days', 2500, true, 'St. Julians', 'Rooftop terrace, negotiable price', 'Georgiana QL'),
    ('REF-003', 'Studio', 1, CURRENT_DATE, 800, false, 'Gzira', 'Perfect for single professional', 'Gabriel QL'),
    ('REF-004', 'House', 4, CURRENT_DATE + INTERVAL '30 days', 2000, true, 'Mellieha', 'Garden, pet friendly', 'Georgiana QL');

INSERT INTO clients (name, phone, looking_for, locations, moving_date, nationality, occupation, how_many_people, pets, let_type, budget, min_bedrooms, max_bedrooms, other_requirements, added_by) VALUES
    ('John Smith', '+356 9999 1111', ARRAY['Apartment', 'Penthouse'], ARRAY['Sliema', 'Gzira', 'St. Julians'], CURRENT_DATE + INTERVAL '10 days', 'British', 'Software Engineer', 2, false, 'Long Let', 1300, 2, 3, 'Need parking space', 'Gabriel QL'),
    ('Maria Rossi', '+356 9999 2222', ARRAY['House', 'Villa'], ARRAY['Mellieha', 'St. Pauls Bay'], CURRENT_DATE + INTERVAL '20 days', 'Italian', 'Teacher', 4, true, 'Long Let', 2100, 3, 4, 'Must allow pets', 'Georgiana QL'),
    ('David Chen', '+356 9999 3333', ARRAY['Studio', 'Apartment'], ARRAY['Valletta', 'Floriana'], CURRENT_DATE + INTERVAL '5 days', 'Chinese', 'Student', 1, false, 'Short Let', 850, 1, 1, 'Close to university', 'Gabriel QL');

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Database setup complete!';
    RAISE NOTICE '✅ Properties table created with notes column';
    RAISE NOTICE '✅ Clients table created with all requirements';
    RAISE NOTICE '✅ Sample data inserted';
    RAISE NOTICE '✅ Ready to use!';
END $$;
