-- Tables
CREATE TABLE users (    id SERIAL PRIMARY KEY,    username VARCHAR(50) UNIQUE NOT NULL,    email VARCHAR(100) UNIQUE NOT NULL,    created_at TIMESTAMP DEFAULT NOW());

CREATE TABLE retreats (    id SERIAL PRIMARY KEY,    name VARCHAR(255) NOT NULL,    location VARCHAR(255) NOT NULL,    date DATE NOT NULL,    created_by INT REFERENCES users(id),    created_at TIMESTAMP DEFAULT NOW());

CREATE TABLE bookings (    id SERIAL PRIMARY KEY,    user_id INT REFERENCES users(id),    retreat_id INT REFERENCES retreats(id),    booking_date TIMESTAMP DEFAULT NOW(),    status VARCHAR(50) DEFAULT 'confirmed' -- e.g., confirmed, canceled
);

-- Indexes
CREATE INDEX idx_retreats_location ON retreats(location);
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_retreat_id ON bookings(retreat_id);

-- Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all users to view their own data"    ON users    FOR SELECT USING (auth.uid() = id);

ALTER TABLE retreats ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow users to view retreats"    ON retreats    FOR SELECT USING (true); -- or define specific access logic

ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow users to manage their own bookings"    ON bookings    FOR SELECT USING (auth.uid() = user_id);

-- Triggers
CREATE OR REPLACE FUNCTION notify_booking_created() 
RETURNS TRIGGER AS $$
BEGIN
    -- Notify logic, e.g., sending an email or logging
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER booking_created_trigger
AFTER INSERT ON bookings
FOR EACH ROW
EXECUTE FUNCTION notify_booking_created();