-- Malta Real Estate PRO v5.0 - COMPLETE SETUP
-- Drop all existing tables
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS communications CASCADE;
DROP TABLE IF EXISTS viewings CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS reminders CASCADE;
DROP TABLE IF EXISTS price_history CASCADE;
DROP TABLE IF EXISTS deals CASCADE;
DROP TABLE IF EXISTS daily_notes CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS properties CASCADE;

-- Updated timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 1. PROPERTIES
CREATE TABLE properties (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    reference_number TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL,
    bedrooms INTEGER NOT NULL,
    available_from DATE NOT NULL,
    price_per_month DECIMAL(10, 2) NOT NULL,
    negotiable BOOLEAN DEFAULT false,
    location TEXT NOT NULL,
    notes TEXT,
    added_by TEXT NOT NULL,
    status TEXT DEFAULT 'available',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. CLIENTS
CREATE TABLE clients (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    looking_for TEXT[] NOT NULL,
    locations TEXT[] NOT NULL,
    moving_date DATE NOT NULL,
    nationality TEXT NOT NULL,
    occupation TEXT NOT NULL,
    how_many_people INTEGER NOT NULL,
    pets BOOLEAN DEFAULT false,
    let_type TEXT NOT NULL,
    budget DECIMAL(10, 2) NOT NULL,
    min_bedrooms INTEGER NOT NULL,
    max_bedrooms INTEGER,
    other_requirements TEXT,
    notes TEXT,
    added_by TEXT NOT NULL,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TASKS (To-Do List)
CREATE TABLE tasks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    priority TEXT NOT NULL CHECK (priority IN ('high', 'medium', 'low')),
    category TEXT NOT NULL CHECK (category IN ('follow-up', 'viewing', 'contract', 'general')),
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    property_id UUID REFERENCES properties(id) ON DELETE SET NULL,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    added_by TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. VIEWINGS
CREATE TABLE viewings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled', 'rescheduled')),
    notes TEXT,
    feedback TEXT,
    added_by TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. COMMUNICATIONS
CREATE TABLE communications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    type TEXT NOT NULL CHECK (type IN ('call', 'message', 'email', 'viewing', 'meeting')),
    content TEXT NOT NULL,
    property_id UUID REFERENCES properties(id) ON DELETE SET NULL,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    added_by TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. REMINDERS
CREATE TABLE reminders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    message TEXT,
    remind_at TIMESTAMP WITH TIME ZONE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('viewing', 'task', 'follow-up', 'contract', 'custom')),
    dismissed BOOLEAN DEFAULT false,
    snoozed_until TIMESTAMP WITH TIME ZONE,
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    viewing_id UUID REFERENCES viewings(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    property_id UUID REFERENCES properties(id) ON DELETE SET NULL,
    added_by TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. DEALS
CREATE TABLE deals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    deal_value DECIMAL(10, 2) NOT NULL,
    commission_percent DECIMAL(5, 2) DEFAULT 5.00,
    commission_amount DECIMAL(10, 2),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'closed', 'cancelled')),
    closed_date DATE,
    notes TEXT,
    added_by TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. DOCUMENTS
CREATE TABLE documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('contract', 'id', 'photo', 'other')),
    file_url TEXT NOT NULL,
    file_size INTEGER,
    property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    added_by TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. DAILY NOTES
CREATE TABLE daily_notes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    content TEXT NOT NULL,
    added_by TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_completed ON tasks(completed);
CREATE INDEX idx_tasks_added_by ON tasks(added_by);
CREATE INDEX idx_viewings_scheduled ON viewings(scheduled_date);
CREATE INDEX idx_viewings_status ON viewings(status);
CREATE INDEX idx_communications_created ON communications(created_at);
CREATE INDEX idx_reminders_remind_at ON reminders(remind_at);
CREATE INDEX idx_reminders_dismissed ON reminders(dismissed);
CREATE INDEX idx_deals_status ON deals(status);
CREATE INDEX idx_deals_closed_date ON deals(closed_date);
CREATE INDEX idx_documents_type ON documents(type);

-- RLS POLICIES
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE viewings ENABLE ROW LEVEL SECURITY;
ALTER TABLE communications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable all for properties" ON properties FOR ALL USING (true);
CREATE POLICY "Enable all for clients" ON clients FOR ALL USING (true);
CREATE POLICY "Enable all for tasks" ON tasks FOR ALL USING (true);
CREATE POLICY "Enable all for viewings" ON viewings FOR ALL USING (true);
CREATE POLICY "Enable all for communications" ON communications FOR ALL USING (true);
CREATE POLICY "Enable all for reminders" ON reminders FOR ALL USING (true);
CREATE POLICY "Enable all for deals" ON deals FOR ALL USING (true);
CREATE POLICY "Enable all for documents" ON documents FOR ALL USING (true);
CREATE POLICY "Enable all for daily_notes" ON daily_notes FOR ALL USING (true);

-- TRIGGERS
CREATE TRIGGER update_properties_updated_at BEFORE UPDATE ON properties FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_viewings_updated_at BEFORE UPDATE ON viewings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_deals_updated_at BEFORE UPDATE ON deals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- AUTO-CALCULATE COMMISSION
CREATE OR REPLACE FUNCTION calculate_commission()
RETURNS TRIGGER AS $$
BEGIN
    NEW.commission_amount = NEW.deal_value * (NEW.commission_percent / 100);
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER auto_calculate_commission BEFORE INSERT OR UPDATE ON deals FOR EACH ROW EXECUTE FUNCTION calculate_commission();

-- SAMPLE DATA
INSERT INTO properties (reference_number, type, bedrooms, available_from, price_per_month, negotiable, location, notes, added_by) VALUES
('REF-001', 'Apartment', 2, CURRENT_DATE + 7, 1200, false, 'Sliema', 'Sea view, furnished', 'Gabriel QL'),
('REF-002', 'Penthouse', 3, CURRENT_DATE + 14, 2500, true, 'St. Julians', 'Rooftop terrace', 'Georgiana QL');

INSERT INTO clients (name, phone, looking_for, locations, moving_date, nationality, occupation, how_many_people, pets, let_type, budget, min_bedrooms, max_bedrooms, added_by) VALUES
('John Smith', '+356 9999 1111', ARRAY['Apartment'], ARRAY['Sliema', 'Gzira'], CURRENT_DATE + 10, 'British', 'Engineer', 2, false, 'Long Let', 1300, 2, 3, 'Gabriel QL');

INSERT INTO tasks (title, priority, category, due_date, added_by) VALUES
('Call John Smith about REF-001', 'high', 'follow-up', NOW() + INTERVAL '2 hours', 'Gabriel QL'),
('Prepare contract for REF-002', 'medium', 'contract', NOW() + INTERVAL '1 day', 'Georgiana QL');

INSERT INTO daily_notes (content, added_by) VALUES
('John Smith very interested in Sliema properties', 'Gabriel QL');

DO $$
BEGIN
    RAISE NOTICE '✅ Database v5.0 setup complete!';
END $$;
