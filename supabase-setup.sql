-- Malta Real Estate PRO - Updated Database Setup
-- Run these commands in your Supabase SQL Editor

-- 1. Properties Table (existing - updated)
CREATE TABLE IF NOT EXISTS properties (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('Apartment', 'House', 'Villa', 'Commercial')),
    location TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    bedrooms INTEGER NOT NULL,
    bathrooms INTEGER,
    size_sqm DECIMAL(10, 2),
    description TEXT,
    status TEXT DEFAULT 'available' CHECK (status IN ('available', 'sold', 'rented', 'pending')),
    owner_name TEXT,
    owner_contact TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Clients Table (existing - updated - NO EMAIL REQUIRED)
CREATE TABLE IF NOT EXISTS clients (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    looking_for TEXT NOT NULL CHECK (looking_for IN ('Apartment', 'House', 'Villa', 'Commercial')),
    preferred_location TEXT NOT NULL,
    budget DECIMAL(10, 2) NOT NULL,
    min_bedrooms INTEGER NOT NULL,
    max_bedrooms INTEGER,
    notes TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'closed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. NEW: Daily Notes Table
CREATE TABLE IF NOT EXISTS daily_notes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. NEW: Deals Table (for commission tracking)
CREATE TABLE IF NOT EXISTS deals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    property_title TEXT NOT NULL,
    client_name TEXT NOT NULL,
    sale_price DECIMAL(10, 2) NOT NULL,
    commission_percent DECIMAL(5, 2) NOT NULL DEFAULT 3.0,
    commission DECIMAL(10, 2) NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'closed')),
    closed_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Reminders Table (existing - from previous setup)
CREATE TABLE IF NOT EXISTS reminders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    due_date DATE NOT NULL,
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    completed BOOLEAN DEFAULT FALSE,
    property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    reminder_type TEXT CHECK (reminder_type IN ('viewing', 'followup', 'contract', 'move_in', 'move_out', 'payment', 'other')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Communications Table (existing - from previous setup)
CREATE TABLE IF NOT EXISTS communications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    property_id UUID REFERENCES properties(id) ON DELETE SET NULL,
    communication_type TEXT NOT NULL CHECK (communication_type IN ('call', 'email', 'meeting', 'whatsapp', 'sms')),
    subject TEXT,
    notes TEXT NOT NULL,
    outcome TEXT,
    next_action TEXT,
    next_action_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Viewings Table (existing - from previous setup)
CREATE TABLE IF NOT EXISTS viewings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled', 'no_show')),
    client_feedback TEXT,
    interested BOOLEAN,
    follow_up_required BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Documents Table (existing - from previous setup)
CREATE TABLE IF NOT EXISTS documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL CHECK (document_type IN ('contract', 'id', 'proof_income', 'deposit', 'inspection', 'photo', 'other')),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER,
    uploaded_by TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Price History Table (existing - from previous setup)
CREATE TABLE IF NOT EXISTS price_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    old_price DECIMAL(10, 2),
    new_price DECIMAL(10, 2) NOT NULL,
    change_reason TEXT,
    changed_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_properties_status ON properties(status);
CREATE INDEX IF NOT EXISTS idx_properties_location ON properties(location);
CREATE INDEX IF NOT EXISTS idx_properties_price ON properties(price);
CREATE INDEX IF NOT EXISTS idx_clients_status ON clients(status);
CREATE INDEX IF NOT EXISTS idx_clients_budget ON clients(budget);
CREATE INDEX IF NOT EXISTS idx_reminders_due_date ON reminders(due_date);
CREATE INDEX IF NOT EXISTS idx_reminders_completed ON reminders(completed);
CREATE INDEX IF NOT EXISTS idx_viewings_scheduled_date ON viewings(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_viewings_status ON viewings(status);
CREATE INDEX IF NOT EXISTS idx_communications_client ON communications(client_id);
CREATE INDEX IF NOT EXISTS idx_communications_created ON communications(created_at);
CREATE INDEX IF NOT EXISTS idx_deals_status ON deals(status);
CREATE INDEX IF NOT EXISTS idx_deals_closed_date ON deals(closed_date);
CREATE INDEX IF NOT EXISTS idx_daily_notes_created ON daily_notes(created_at);

-- Enable Row Level Security (RLS) - IMPORTANT for security
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE communications ENABLE ROW LEVEL SECURITY;
ALTER TABLE viewings ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE price_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_notes ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (adjust based on your auth needs)
-- For development: allow all operations
CREATE POLICY "Enable all for properties" ON properties FOR ALL USING (true);
CREATE POLICY "Enable all for clients" ON clients FOR ALL USING (true);
CREATE POLICY "Enable all for reminders" ON reminders FOR ALL USING (true);
CREATE POLICY "Enable all for communications" ON communications FOR ALL USING (true);
CREATE POLICY "Enable all for viewings" ON viewings FOR ALL USING (true);
CREATE POLICY "Enable all for documents" ON documents FOR ALL USING (true);
CREATE POLICY "Enable all for price_history" ON price_history FOR ALL USING (true);
CREATE POLICY "Enable all for deals" ON deals FOR ALL USING (true);
CREATE POLICY "Enable all for daily_notes" ON daily_notes FOR ALL USING (true);

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

CREATE TRIGGER update_reminders_updated_at BEFORE UPDATE ON reminders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_viewings_updated_at BEFORE UPDATE ON viewings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_deals_updated_at BEFORE UPDATE ON deals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to automatically create price history when price changes
CREATE OR REPLACE FUNCTION track_price_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.price IS DISTINCT FROM NEW.price THEN
        INSERT INTO price_history (property_id, old_price, new_price)
        VALUES (NEW.id, OLD.price, NEW.price);
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER track_property_price_changes AFTER UPDATE ON properties
    FOR EACH ROW EXECUTE FUNCTION track_price_change();

-- Insert sample data for testing (optional)
INSERT INTO properties (title, type, location, price, bedrooms, description, status, owner_contact) VALUES
    ('Modern Apartment in Sliema', 'Apartment', 'Sliema', 350000, 2, 'Beautiful modern apartment with sea views', 'available', '+356 9999 0001'),
    ('Luxury Villa in St. Julians', 'Villa', 'St. Julians', 850000, 4, 'Spacious villa with pool and garden', 'available', '+356 9999 0002'),
    ('City Center Apartment', 'Apartment', 'Valletta', 280000, 1, 'Perfect for professionals, walking distance to everything', 'available', '+356 9999 0003'),
    ('Family House in Mellieha', 'House', 'Mellieha', 450000, 3, 'Quiet neighborhood, great for families', 'available', '+356 9999 0004');

INSERT INTO clients (name, phone, looking_for, preferred_location, budget, min_bedrooms) VALUES
    ('John Smith', '+356 9999 1111', 'Apartment', 'Sliema', 380000, 2),
    ('Maria Borg', '+356 9999 2222', 'House', 'Mellieha', 420000, 3),
    ('David Jones', '+356 9999 3333', 'Apartment', 'Valletta', 300000, 1);

INSERT INTO daily_notes (content) VALUES
    ('Called John Smith - interested in Sliema apartment, scheduling viewing for Friday'),
    ('Maria Borg made offer on Mellieha house - €410k, waiting for owner response'),
    ('Need to follow up with David Jones about Valletta property');

INSERT INTO deals (property_title, client_name, sale_price, commission_percent, commission, status, closed_date, notes) VALUES
    ('Penthouse in Paceville', 'Sarah Williams', 620000, 3.0, 18600, 'closed', CURRENT_DATE - INTERVAL '15 days', 'Smooth transaction, client very happy'),
    ('Townhouse in Naxxar', 'Mark Vella', 395000, 2.5, 9875, 'pending', CURRENT_DATE + INTERVAL '10 days', 'Waiting for bank approval');

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Database setup complete!';
    RAISE NOTICE '✅ All tables created successfully';
    RAISE NOTICE '✅ Sample data inserted';
    RAISE NOTICE '✅ Ready to use!';
END $$;
