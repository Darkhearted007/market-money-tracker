CREATE TABLE markets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  city TEXT,
  state TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE market_zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  market_id UUID NOT NULL REFERENCES markets(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE collection_points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  market_id UUID NOT NULL REFERENCES markets(id) ON DELETE CASCADE,
  zone_id UUID REFERENCES market_zones(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE truckers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id TEXT NOT NULL,
  company_name TEXT NOT NULL,
  driver_name TEXT NOT NULL,
  phone TEXT,
  vehicle_registration TEXT NOT NULL,
  truck_capacity_kg NUMERIC(12,2) NOT NULL CHECK (truck_capacity_kg > 0),
  waste_types TEXT[] NOT NULL DEFAULT ARRAY['general'],
  active BOOLEAN NOT NULL DEFAULT TRUE,
  reliability_score NUMERIC(5,2) NOT NULL DEFAULT 100,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE disposal_facilities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  facility_type TEXT NOT NULL CHECK (facility_type IN ('disposal','recycling','composting','transfer')),
  address TEXT,
  accepted_waste_types TEXT[] NOT NULL DEFAULT ARRAY['general'],
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE waste_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  market_id UUID NOT NULL REFERENCES markets(id) ON DELETE CASCADE,
  collection_point_id UUID REFERENCES collection_points(id) ON DELETE SET NULL,
  trucker_id UUID REFERENCES truckers(id) ON DELETE SET NULL,
  facility_id UUID REFERENCES disposal_facilities(id) ON DELETE SET NULL,
  waste_type TEXT NOT NULL CHECK (waste_type IN ('organic','plastic','paper','glass','metal','textile','general','special')),
  estimated_weight_kg NUMERIC(12,2) CHECK (estimated_weight_kg IS NULL OR estimated_weight_kg > 0),
  collected_weight_kg NUMERIC(12,2) CHECK (collected_weight_kg IS NULL OR collected_weight_kg > 0),
  collection_fee NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (collection_fee >= 0),
  status TEXT NOT NULL DEFAULT 'requested' CHECK (status IN ('requested','assigned','arrived','collected','in_transit','delivered','cancelled')),
  requested_by TEXT NOT NULL,
  requested_at TIMESTAMP NOT NULL DEFAULT now(),
  collected_at TIMESTAMP,
  delivered_at TIMESTAMP,
  notes TEXT
);

CREATE TABLE waste_job_events (
  id BIGSERIAL PRIMARY KEY,
  job_id UUID NOT NULL REFERENCES waste_jobs(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  actor_user_id TEXT NOT NULL,
  latitude NUMERIC(10,7),
  longitude NUMERIC(10,7),
  note TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_markets_owner ON markets(owner_user_id);
CREATE INDEX idx_zones_market ON market_zones(market_id);
CREATE INDEX idx_points_market ON collection_points(market_id);
CREATE INDEX idx_truckers_owner ON truckers(owner_user_id);
CREATE INDEX idx_facilities_owner ON disposal_facilities(owner_user_id);
CREATE INDEX idx_waste_jobs_market_status ON waste_jobs(market_id, status);
CREATE INDEX idx_waste_events_job ON waste_job_events(job_id, created_at);
