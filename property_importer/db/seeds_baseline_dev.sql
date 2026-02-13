-- Baseline data for Property & Unit importer testing.
-- Run after migrations: bin/rails db:seed_baseline
-- Resets sequences so future inserts get correct IDs.

-- Properties (8)
INSERT INTO properties (id, building_name, street_address, city, state, zip_code, created_at, updated_at) VALUES
(1, 'Avenue Apartments', '123 Test St', 'Seattle', 'Washington', '98122', '2026-02-11 04:34:08.748915', '2026-02-11 04:34:08.748915'),
(3, '569 Pine Dr.', '569 Pine Dr.', 'Seattle', 'Washington', '19345', '2026-02-11 04:34:08.748915', '2026-02-11 04:34:08.748915'),
(11, 'Avenue Apartments', '12 North Ave', 'Seattle', 'Washington', '98122', '2026-02-13 00:39:47.164649', '2026-02-13 00:39:47.164649'),
(12, '4230 Main St.', '4230 Main St.', 'Seattle', 'Washington', '98105', '2026-02-13 00:39:47.298276', '2026-02-13 00:39:47.298276'),
(13, 'Avenue Apartments', '12 North Ave', 'Spokane', 'Washington', '98765', '2026-02-13 00:39:47.324818', '2026-02-13 00:39:47.324818'),
(14, 'Avenue Apartments', '12 North Ave', 'Seattle', 'Washington', '98105', '2026-02-13 00:39:47.457077', '2026-02-13 00:39:47.457077'),
(15, 'Boulevard Lofts', '123 Test St', 'Seattle', 'Washington', '98122', '2026-02-13 00:39:47.529315', '2026-02-13 00:39:47.529315'),
(16, 'Grand Boulevarde', '123 test streeteste', 'seattleest', 'WA', '98120', '2026-02-13 00:39:47.611144', '2026-02-13 00:39:47.611144')
;

-- Units (13)
INSERT INTO units (property_id, unit_number, created_at, updated_at) VALUES
(1, '101', '2026-02-11 04:34:08.748915', '2026-02-11 04:34:08.748915'),
(1, '102', '2026-02-11 04:34:08.748915', '2026-02-11 04:34:08.748915'),
(1, '103', '2026-02-13 00:39:46.840672', '2026-02-13 00:39:46.840672'),
(1, '104', '2026-02-13 00:39:46.929564', '2026-02-13 00:39:46.929564'),
(1, '105', '2026-02-13 00:39:47.009410', '2026-02-13 00:39:47.009410'),
(1, '106', '2026-02-13 00:39:47.077731', '2026-02-13 00:39:47.077731'),
(1, '107', '2026-02-13 00:39:47.139937', '2026-02-13 00:39:47.139937'),
(11, '102', '2026-02-13 00:39:47.227583', '2026-02-13 00:39:47.227583'),
(11, '103', '2026-02-13 00:39:47.271646', '2026-02-13 00:39:47.271646'),
(13, '101', '2026-02-13 00:39:47.417053', '2026-02-13 00:39:47.417053'),
(14, '101', '2026-02-13 00:39:47.503498', '2026-02-13 00:39:47.503498'),
(15, '102', '2026-02-13 00:39:47.576111', '2026-02-13 00:39:47.576111'),
(16, '1010', '2026-02-13 00:39:47.651660', '2026-02-13 00:39:47.651660')
;

-- Reset sequences for PostgreSQL
SELECT setval(pg_get_serial_sequence('properties', 'id'), (SELECT COALESCE(MAX(id), 1) FROM properties));
SELECT setval(pg_get_serial_sequence('units', 'id'), (SELECT COALESCE(MAX(id), 1) FROM units));
