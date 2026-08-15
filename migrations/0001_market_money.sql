CREATE TABLE money_entries (
  id BIGSERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  entry_type TEXT NOT NULL CHECK (entry_type IN ('money_in', 'money_out')),
  amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
  note TEXT,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP NOT NULL DEFAULT now()
)