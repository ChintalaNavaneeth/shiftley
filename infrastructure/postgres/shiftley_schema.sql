-- Shiftley Master Schema
-- Module: Core Setup & Auth + Profiles

-- Enable PostGIS for Proximity/Geospatial Queries
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create shiftley schema
CREATE SCHEMA IF NOT EXISTS shiftley;

-- -----------------------------------------------------------------------------
-- STANDARD UTILITIES
-- -----------------------------------------------------------------------------

-- Function to automatically update 'updated_at' column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- -----------------------------------------------------------------------------
-- MODULE 1: USERS & AUTH
-- -----------------------------------------------------------------------------

-- Table: users
-- All characters in the system (Workers, Employers, Admins)
CREATE TABLE IF NOT EXISTS shiftley.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('WORKER', 'EMPLOYER', 'VERIFIER', 'CS_AGENT', 'ANALYST', 'ADMIN', 'SUPER_ADMIN')),
    is_verified BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE -- Soft delete support
);

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON shiftley.users
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Table: otps
-- Verification tokens for Email/WhatsApp logins
CREATE TABLE IF NOT EXISTS shiftley.otps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES shiftley.users(id) ON DELETE CASCADE,
    channel VARCHAR(10) CHECK (channel IN ('EMAIL', 'WHATSAPP')),
    code VARCHAR(10) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: kyc_sessions
-- Identity verification state (Hyperverge/Aadhaar)
CREATE TABLE IF NOT EXISTS shiftley.kyc_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES shiftley.users(id) ON DELETE CASCADE,
    provider VARCHAR(50) DEFAULT 'HYPERVERGE',
    provider_session_id VARCHAR(255),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REJECTED')),
    masked_aadhaar VARCHAR(12), -- XXXX-XXXX-1234
    face_match_score NUMERIC(3, 2) CHECK (face_match_score >= 0 AND face_match_score <= 1),
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- MODULE 2: PROFILES
-- -----------------------------------------------------------------------------

-- Table: worker_profiles
-- Extended data for workers
CREATE TABLE IF NOT EXISTS shiftley.worker_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES shiftley.users(id) ON DELETE CASCADE,
    base_location GEOGRAPHY(POINT, 4326), -- PostGIS Point
    search_radius_km SMALLINT DEFAULT 10 CHECK (search_radius_km > 0),
    reliability_score SMALLINT DEFAULT 100 CHECK (reliability_score >= 0 AND reliability_score <= 100),
    bank_account_verified BOOLEAN DEFAULT FALSE,
    upi_id VARCHAR(100),
    profile_photo_url VARCHAR(255),
    reliability_badge VARCHAR(10) DEFAULT 'GREEN' CHECK (reliability_badge IN ('GREEN', 'YELLOW', 'RED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TRIGGER update_worker_profiles_updated_at
BEFORE UPDATE ON shiftley.worker_profiles
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Table: employer_profiles
-- Extended data for employers
CREATE TABLE IF NOT EXISTS shiftley.employer_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES shiftley.users(id) ON DELETE CASCADE,
    business_name VARCHAR(255) NOT NULL,
    gst_number VARCHAR(15),
    business_address TEXT NOT NULL,
    location GEOGRAPHY(POINT, 4326),
    verification_status VARCHAR(20) DEFAULT 'PENDING' CHECK (verification_status IN ('PENDING', 'IN_PROGRESS', 'APPROVED', 'REJECTED')),
    subscription_status VARCHAR(20) DEFAULT 'INACTIVE' CHECK (subscription_status IN ('INACTIVE', 'ACTIVE', 'EXPIRED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TRIGGER update_employer_profiles_updated_at
BEFORE UPDATE ON shiftley.employer_profiles
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Table: internal_staff
-- Permissions and metadata for internal employees
CREATE TABLE IF NOT EXISTS shiftley.internal_staff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES shiftley.users(id) ON DELETE CASCADE,
    staff_id VARCHAR(20) UNIQUE NOT NULL, -- SHFT-XXXX
    current_status VARCHAR(20) DEFAULT 'AVAILABLE',
    capabilities JSONB, -- list of assigned regions or features
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_internal_staff_updated_at
BEFORE UPDATE ON shiftley.internal_staff
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_workers_location ON shiftley.worker_profiles USING GIST (base_location);
CREATE INDEX IF NOT EXISTS idx_employers_location ON shiftley.employer_profiles USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_users_role ON shiftley.users(role);
CREATE INDEX IF NOT EXISTS idx_users_phone ON shiftley.users(phone_number);

-- -----------------------------------------------------------------------------
-- MODULE 3: SKILL TAXONOMY
-- -----------------------------------------------------------------------------

-- Table: business_types
-- Categories for businesses (F&B, Retail, etc.)
CREATE TABLE IF NOT EXISTS shiftley.business_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: skill_categories
-- Groups of skills (e.g., Kitchen Staff, Warehouse Logistics)
CREATE TABLE IF NOT EXISTS shiftley.skill_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_type_id UUID REFERENCES shiftley.business_types(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: skills
-- Individual skills (Waiter, Dishwasher, Loader)
CREATE TABLE IF NOT EXISTS shiftley.skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES shiftley.skill_categories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: worker_skills
-- Mapping between workers and the skills they possess
CREATE TABLE IF NOT EXISTS shiftley.worker_skills (
    worker_id UUID REFERENCES shiftley.worker_profiles(id) ON DELETE CASCADE,
    skill_id UUID REFERENCES shiftley.skills(id) ON DELETE CASCADE,
    verified BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (worker_id, skill_id)
);

-- -----------------------------------------------------------------------------
-- MODULE 4: EMPLOYER VERIFICATION
-- -----------------------------------------------------------------------------

-- Table: employer_verifications
-- Cycle of physical site verification
CREATE TABLE IF NOT EXISTS shiftley.employer_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employer_id UUID NOT NULL REFERENCES shiftley.employer_profiles(id) ON DELETE CASCADE,
    verifier_id UUID NOT NULL REFERENCES shiftley.internal_staff(id),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ASSIGNED', 'VISITED', 'APPROVED', 'REJECTED')),
    assigned_at TIMESTAMP WITH TIME ZONE,
    visited_at TIMESTAMP WITH TIME ZONE,
    sla_due_at TIMESTAMP WITH TIME ZONE, -- 48 hours from assignment
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_employer_verifications_updated_at
BEFORE UPDATE ON shiftley.employer_verifications
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Table: verifier_visits
-- Records of physical visit evidence
CREATE TABLE IF NOT EXISTS shiftley.verifier_visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    verification_id UUID NOT NULL REFERENCES shiftley.employer_verifications(id) ON DELETE CASCADE,
    note TEXT,
    outcome VARCHAR(20) NOT NULL CHECK (outcome IN ('APPROVED', 'REJECTED')),
    rejection_reason_code VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: verification_evidence
-- Photos/Documents taken on-site
CREATE TABLE IF NOT EXISTS shiftley.verification_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visit_id UUID NOT NULL REFERENCES shiftley.verifier_visits(id) ON DELETE CASCADE,
    photo_url VARCHAR(255) NOT NULL,
    tag VARCHAR(50), -- e.g., 'OUTSIDE_BUILDING', 'OWNER_SELFIE'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- MODULE 5: SUBSCRIPTIONS
-- -----------------------------------------------------------------------------

-- Table: subscription_plans
-- Hardcoded tiers (₹123, ₹456, ₹789 in Paise)
CREATE TABLE IF NOT EXISTS shiftley.subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL, -- e.g., '1_DAY', '1_WEEK', '1_MONTH'
    price_paise BIGINT NOT NULL CHECK (price_paise >= 0),
    duration_days SMALLINT NOT NULL CHECK (duration_days > 0),
    features JSONB, -- list of features like 'multi_day_gigs'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: employer_subscriptions
-- Active subscription tracking
CREATE TABLE IF NOT EXISTS shiftley.employer_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employer_id UUID NOT NULL REFERENCES shiftley.employer_profiles(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES shiftley.subscription_plans(id),
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'EXPIRED', 'CANCELLED')),
    starts_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_employer_subscriptions_updated_at
BEFORE UPDATE ON shiftley.employer_subscriptions
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- -----------------------------------------------------------------------------
-- MODULE 6: GIGS
-- -----------------------------------------------------------------------------

-- Table: gigs
-- The core gig advertisement
CREATE TABLE IF NOT EXISTS shiftley.gigs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employer_id UUID NOT NULL REFERENCES shiftley.employer_profiles(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    skill_id UUID NOT NULL REFERENCES shiftley.skills(id),
    slot_count SMALLINT DEFAULT 1 CHECK (slot_count > 0),
    pay_paise BIGINT NOT NULL CHECK (pay_paise > 0), -- per hour or per day
    pay_structure VARCHAR(20) DEFAULT 'PER_DAY' CHECK (pay_structure IN ('PER_HOUR', 'PER_DAY')),
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    address_text TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'LIVE', 'FILLED', 'CANCELLED', 'COMPLETED', 'EXPIRED')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL, -- can be same as start_date for single day
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TRIGGER update_gigs_updated_at
BEFORE UPDATE ON shiftley.gigs
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Table: gig_days
-- Granular attendance/tracking records for each day of a gig
CREATE TABLE IF NOT EXISTS shiftley.gig_days (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gig_id UUID NOT NULL REFERENCES shiftley.gigs(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: gig_photos
-- Visuals for the workplace
CREATE TABLE IF NOT EXISTS shiftley.gig_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gig_id UUID NOT NULL REFERENCES shiftley.gigs(id) ON DELETE CASCADE,
    photo_url VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indices for performance
CREATE INDEX IF NOT EXISTS idx_gigs_employer ON shiftley.gigs(employer_id);
CREATE INDEX IF NOT EXISTS idx_gigs_location ON shiftley.gigs USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_gigs_status ON shiftley.gigs(status);
CREATE INDEX IF NOT EXISTS idx_gigs_dates ON shiftley.gigs(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_gig_days_date ON shiftley.gig_days(date);

-- Composite Index for Gig Feed (Optimized Search)
CREATE INDEX IF NOT EXISTS idx_gigs_feed ON shiftley.gigs (status, skill_id, location);

-- -----------------------------------------------------------------------------
-- MODULE 7: APPLICATIONS & BOOKINGS
-- -----------------------------------------------------------------------------

-- Table: applications
-- Worker application to a gig
CREATE TABLE IF NOT EXISTS shiftley.applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gig_id UUID NOT NULL REFERENCES shiftley.gigs(id) ON DELETE CASCADE,
    worker_id UUID NOT NULL REFERENCES shiftley.worker_profiles(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'WITHDRAWN')),
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(gig_id, worker_id) -- one application per gig per worker
);

-- Table: bookings
-- Finalized worker for a gig
CREATE TABLE IF NOT EXISTS shiftley.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL UNIQUE REFERENCES shiftley.applications(id) ON DELETE CASCADE,
    worker_id UUID NOT NULL REFERENCES shiftley.worker_profiles(id) ON DELETE CASCADE,
    gig_id UUID NOT NULL REFERENCES shiftley.gigs(id) ON DELETE CASCADE,
    total_pay_paise BIGINT NOT NULL CHECK (total_pay_paise >= 0),
    status VARCHAR(20) DEFAULT 'UPCOMING' CHECK (status IN ('UPCOMING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'DISPUTED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TRIGGER update_bookings_updated_at
BEFORE UPDATE ON shiftley.bookings
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Table: booking_daily_records
-- Daily attendance heartbeat (QR scan timestamps)
CREATE TABLE IF NOT EXISTS shiftley.booking_daily_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES shiftley.bookings(id) ON DELETE CASCADE,
    gig_day_id UUID NOT NULL REFERENCES shiftley.gig_days(id) ON DELETE CASCADE,
    check_in_at TIMESTAMP WITH TIME ZONE,
    check_out_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'COMPLETED', 'NO_SHOW', 'CANCELLED')),
    hours_worked NUMERIC(4, 2) CHECK (hours_worked >= 0 AND hours_worked <= 24),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(booking_id, gig_day_id)
);

CREATE TRIGGER update_booking_daily_records_updated_at
BEFORE UPDATE ON shiftley.booking_daily_records
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- -----------------------------------------------------------------------------
-- MODULE 8: PAYMENTS & ESCROW
-- -----------------------------------------------------------------------------

-- Table: payment_transactions
-- Unified ledger of all money movement
CREATE TABLE IF NOT EXISTS shiftley.payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES shiftley.users(id),
    amount_paise BIGINT NOT NULL CHECK (amount_paise >= 0),
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('ESCROW_LOCK', 'PAYOUT', 'REFUND', 'FINE_CHARGE', 'FINE_CREDIT', 'SUBSCRIPTION_PAYMENT')),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'REVERSED')),
    provider_transaction_id VARCHAR(255), -- Razorpay payment ID
    reference_id UUID, -- links to booking_id, gig_id, or worker_fine_id
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: escrow_holds
-- Tracks locked funds waiting for gig completion
CREATE TABLE IF NOT EXISTS shiftley.escrow_holds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL UNIQUE REFERENCES shiftley.bookings(id) ON DELETE CASCADE,
    amount_paise BIGINT NOT NULL CHECK (amount_paise >= 0),
    status VARCHAR(20) DEFAULT 'LOCKED' CHECK (status IN ('LOCKED', 'RELEASED', 'REFUNDED', 'PARTIALLY_RELEASED')),
    released_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_escrow_holds_updated_at
BEFORE UPDATE ON shiftley.escrow_holds
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Table: cancellation_fines
-- Penalties for late cancel (>6h, <6h, etc.)
CREATE TABLE IF NOT EXISTS shiftley.cancellation_fines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES shiftley.bookings(id) ON DELETE CASCADE,
    employer_id UUID NOT NULL REFERENCES shiftley.employer_profiles(id),
    amount_paise BIGINT NOT NULL CHECK (amount_paise >= 0),
    fine_percentage SMALLINT CHECK (fine_percentage >= 0 AND fine_percentage <= 100),
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: worker_fines
-- ₹50 fine for multiple no-shows
CREATE TABLE IF NOT EXISTS shiftley.worker_fines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_id UUID NOT NULL REFERENCES shiftley.worker_profiles(id) ON DELETE CASCADE,
    amount_paise BIGINT DEFAULT 5000 CHECK (amount_paise >= 0),
    is_paid BOOLEAN DEFAULT FALSE,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indices
CREATE INDEX IF NOT EXISTS idx_apps_worker ON shiftley.applications(worker_id);
CREATE INDEX IF NOT EXISTS idx_bookings_worker ON shiftley.bookings(worker_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON shiftley.bookings(status);
CREATE INDEX IF NOT EXISTS idx_tx_user ON shiftley.payment_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_tx_provider ON shiftley.payment_transactions(provider_transaction_id);

-- -----------------------------------------------------------------------------
-- MODULE 9: NO-SHOWS & EMERGENCY REPLACEMENT
-- -----------------------------------------------------------------------------

-- Table: no_show_events
-- Tracking reliability incidents
CREATE TABLE IF NOT EXISTS shiftley.no_show_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES shiftley.bookings(id) ON DELETE CASCADE,
    gig_day_id UUID NOT NULL REFERENCES shiftley.gig_days(id) ON DELETE CASCADE,
    worker_id UUID NOT NULL REFERENCES shiftley.worker_profiles(id) ON DELETE CASCADE,
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: emergency_replacements
-- Cycle of finding a new worker
CREATE TABLE IF NOT EXISTS shiftley.emergency_replacements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gig_day_id UUID NOT NULL REFERENCES shiftley.gig_days(id) ON DELETE CASCADE,
    original_booking_id UUID REFERENCES shiftley.bookings(id),
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'RESOLVED', 'FAILED')),
    deadline_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: emergency_offers
-- Broadcasted offers to nearby workers
CREATE TABLE IF NOT EXISTS shiftley.emergency_offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    replacement_id UUID NOT NULL REFERENCES shiftley.emergency_replacements(id) ON DELETE CASCADE,
    worker_id UUID NOT NULL REFERENCES shiftley.worker_profiles(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ACCEPTED', 'DECLINED', 'EXPIRED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- MODULE 10: RATINGS
-- -----------------------------------------------------------------------------

-- Table: ratings
-- Mutual feedback post-gig
CREATE TABLE IF NOT EXISTS shiftley.ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES shiftley.bookings(id) ON DELETE CASCADE,
    from_user_id UUID NOT NULL REFERENCES shiftley.users(id),
    to_user_id UUID NOT NULL REFERENCES shiftley.users(id),
    score SMALLINT NOT NULL CHECK (score >= 1 AND score <= 5),
    comment TEXT,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- MODULE 11: AUDIT & NOTIFICATIONS
-- -----------------------------------------------------------------------------

-- Table: notification_log
-- Audit trail for WhatsApp/Email communication
CREATE TABLE IF NOT EXISTS shiftley.notification_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_user_id UUID NOT NULL REFERENCES shiftley.users(id),
    channel VARCHAR(20) NOT NULL,
    template_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'SENT',
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: cs_actions_log
-- Audit log for search-scoped lookup and fine waivers
CREATE TABLE IF NOT EXISTS shiftley.cs_actions_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID NOT NULL REFERENCES shiftley.internal_staff(id),
    target_user_id UUID REFERENCES shiftley.users(id),
    action_type VARCHAR(100) NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: account_notes
-- Internal notes on workers/employers
CREATE TABLE IF NOT EXISTS shiftley.account_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES shiftley.users(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES shiftley.internal_staff(id),
    note TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: audit_logs
-- System-wide sensitive event tracking
CREATE TABLE IF NOT EXISTS shiftley.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES shiftley.users(id),
    action VARCHAR(255) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    old_value JSONB,
    new_value JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Final Indices
CREATE INDEX IF NOT EXISTS idx_ratings_to_user ON shiftley.ratings(to_user_id);
CREATE INDEX IF NOT EXISTS idx_notif_user ON shiftley.notification_log(recipient_user_id);
CREATE INDEX IF NOT EXISTS idx_audit_resource ON shiftley.audit_logs(resource_type, resource_id);

-- -----------------------------------------------------------------------------
-- INITIAL SEED DATA
-- -----------------------------------------------------------------------------

-- Seed: business_types
INSERT INTO shiftley.business_types (name, description) VALUES
('RESTAURANT', 'Food and Beverage establishments, cafes, and bars'),
('RETAIL', 'Malls, supermarkets, and boutique stores'),
('WAREHOUSE', 'Logistics, sorting centers, and storage hubs'),
('CONSTRUCTION', 'Civil works, site labor, and technical trade')
ON CONFLICT (name) DO NOTHING;

-- Seed: subscription_plans
INSERT INTO shiftley.subscription_plans (name, price_paise, duration_days, features) VALUES
('1_DAY', 12300, 1, '{"multi_day_gigs": false, "priority_listing": false}'),
('1_WEEK', 45600, 7, '{"multi_day_gigs": true, "priority_listing": false}'),
('1_MONTH', 78900, 30, '{"multi_day_gigs": true, "priority_listing": true}')
ON CONFLICT (name) DO NOTHING;




