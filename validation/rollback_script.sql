-- Rollback strategy: truncate if validation fails
TRUNCATE TABLE bcs_schema.billing_transactions;
DELETE FROM bcs_schema.billing_audit_log;
