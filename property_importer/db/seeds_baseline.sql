-- Baseline data for Property & Unit importer testing.
-- Run after migrations: bin/rails db:seed_baseline
-- Resets sequences so future inserts get correct IDs.

-- Properties (3): Avenue Apartments, 4230 Main St., 569 Pine Dr.
INSERT INTO properties (id, building_name, street_address, city, state, zip_code, created_at, updated_at) VALUES
(1, 'Avenue Apartments', '123 Test St', 'Seattle', 'Washington', '98122', NOW(), NOW()),
(2, '4230 Main St.', '4230 Main St.', 'Seattle', 'Washington', '98105', NOW(), NOW()),
(3, '569 Pine Dr.', '569 Pine Dr.', 'Seattle', 'Washington', '19345', NOW(), NOW());

-- Units for Avenue Apartments only (101–107). 4230 Main St. and 569 Pine Dr. are property-only.
INSERT INTO units (property_id, unit_number, created_at, updated_at) VALUES
(1, '101', NOW(), NOW()),
(1, '102', NOW(), NOW()),
(1, '103', NOW(), NOW()),
(1, '104', NOW(), NOW()),
(1, '105', NOW(), NOW()),
(1, '106', NOW(), NOW()),
(1, '107', NOW(), NOW());

-- Reset sequences for PostgreSQL
SELECT setval(pg_get_serial_sequence('properties', 'id'), (SELECT COALESCE(MAX(id), 1) FROM properties));
SELECT setval(pg_get_serial_sequence('units', 'id'), (SELECT COALESCE(MAX(id), 1) FROM units));
