-- Oracle to PostgreSQL Migration – Billing Transactions & Supporting Objects
-- Migrated as part of enterprise transition from Oracle 12c to PostgreSQL (v14+)
-- Author: Manochitra Loganathan | Role: Cloud DBA & Data Platform Lead

-- Drop if table already exists (useful during dev or retries)
DROP TABLE IF EXISTS bcs_schema.billing_transactions CASCADE;

-- Recreate billing transactions table in PostgreSQL
CREATE TABLE bcs_schema.billing_transactions (
    txn_id SERIAL PRIMARY KEY,
    policy_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    billing_cycle VARCHAR(10),
    is_recurring BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'PENDING',
    billing_date DATE NOT NULL,
    notes TEXT,
    created_by VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enforce referential integrity
ALTER TABLE bcs_schema.billing_transactions
ADD CONSTRAINT fk_policy FOREIGN KEY (policy_id)
REFERENCES bcs_schema.policies(policy_id);

-- Basic indexes for performance tuning (based on access patterns)
CREATE INDEX idx_billing_customer ON bcs_schema.billing_transactions(customer_id);
CREATE INDEX idx_billing_status ON bcs_schema.billing_transactions(status);

-- Add constraint to restrict valid status values
ALTER TABLE bcs_schema.billing_transactions
ADD CONSTRAINT chk_status_valid
CHECK (status IN ('PENDING', 'PAID', 'FAILED', 'OVERDUE'));

-- Notes about schema design
COMMENT ON COLUMN bcs_schema.billing_transactions.notes IS 'Migrated from Oracle CLOB';
COMMENT ON COLUMN bcs_schema.billing_transactions.is_recurring IS 'Boolean flag from CHAR(1) Y/N';

-- Create audit log table used by triggers
DROP TABLE IF EXISTS bcs_schema.billing_audit_log CASCADE;
CREATE TABLE bcs_schema.billing_audit_log (
    audit_id SERIAL PRIMARY KEY,
    txn_id INTEGER,
    action VARCHAR(50),
    changed_by VARCHAR(100),
    change_note TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger function to log new transaction inserts
CREATE OR REPLACE FUNCTION bcs_schema.audit_billing_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO bcs_schema.billing_audit_log (
        txn_id, action, changed_by, change_note, changed_at
    ) VALUES (
        NEW.txn_id, 'INSERT', current_user, 'New transaction added', CURRENT_TIMESTAMP
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to capture inserts into billing_transactions
CREATE TRIGGER trg_audit_insert
AFTER INSERT ON bcs_schema.billing_transactions
FOR EACH ROW EXECUTE FUNCTION bcs_schema.audit_billing_insert();

-- Materialized view for monthly summary reporting
CREATE MATERIALIZED VIEW bcs_schema.monthly_billing_summary AS
SELECT
    date_trunc('month', billing_date) AS billing_month,
    COUNT(*) AS total_txns,
    SUM(amount) AS total_billed
FROM bcs_schema.billing_transactions
GROUP BY billing_month
ORDER BY billing_month;

-- Function to return total due amount for a customer
CREATE OR REPLACE FUNCTION bcs_schema.get_total_due(p_customer_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    total_due NUMERIC := 0;
BEGIN
    SELECT SUM(amount) INTO total_due
    FROM bcs_schema.billing_transactions
    WHERE customer_id = p_customer_id AND status = 'PENDING';
    RETURN COALESCE(total_due, 0);
END;
$$ LANGUAGE plpgsql;

-- Grant minimum permissions to reporting users
GRANT SELECT ON bcs_schema.billing_transactions TO reporting_user;
GRANT SELECT ON bcs_schema.monthly_billing_summary TO reporting_user;
GRANT EXECUTE ON FUNCTION bcs_schema.get_total_due(integer) TO reporting_user;
