-- Drop all remaining tables in public schema
-- Clean up any remaining custom tables

DROP TABLE IF EXISTS "Users" CASCADE;
DROP TABLE IF EXISTS "Applications" CASCADE;
DROP TABLE IF EXISTS "Roles" CASCADE;
DROP TABLE IF EXISTS "ApiKeys" CASCADE;
DROP TABLE IF EXISTS "EmailTokens" CASCADE;
DROP TABLE IF EXISTS "SessionLogs" CASCADE;
DROP TABLE IF EXISTS "UserExternalLogins" CASCADE;
DROP TABLE IF EXISTS "UserRoles" CASCADE;

-- Show remaining tables (should be empty)
SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'public';