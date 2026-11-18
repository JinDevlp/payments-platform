-- Runs once, when the Postgres volume is first created.
-- "payments" is created by POSTGRES_DB; ledger-service gets its own database.
CREATE DATABASE ledger OWNER app;
