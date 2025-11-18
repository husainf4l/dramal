-- Drop all tables script for dramal database
-- This will clean the database before applying fresh migrations

-- Drop ASP.NET Identity tables in correct order (respecting foreign keys)
DROP TABLE IF EXISTS "AspNetUserTokens" CASCADE;
DROP TABLE IF EXISTS "AspNetUserRoles" CASCADE;
DROP TABLE IF EXISTS "AspNetUserLogins" CASCADE;
DROP TABLE IF EXISTS "AspNetUserClaims" CASCADE;
DROP TABLE IF EXISTS "AspNetRoleClaims" CASCADE;
DROP TABLE IF EXISTS "RefreshTokens" CASCADE;
DROP TABLE IF EXISTS "AspNetUsers" CASCADE;
DROP TABLE IF EXISTS "AspNetRoles" CASCADE;

-- Drop EF Migrations history table
DROP TABLE IF EXISTS "__EFMigrationsHistory" CASCADE;

-- Show remaining tables (should be empty)
SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'public';