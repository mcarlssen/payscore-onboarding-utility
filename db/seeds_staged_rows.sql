-- Staged rows seed data (import_sessions + staged_rows).
-- Run after migrations: load via SQL or db:seed_staged_rows.
-- Resets sequences so future inserts get correct IDs.

-- Import sessions (4)
INSERT INTO import_sessions (id, status, file_name, created_at, updated_at) VALUES
(2, 'rolled_back', 'test_import_20pct_overlap.csv', '2026-02-11 05:17:57.618753', '2026-02-11 05:48:03.984396'),
(7, 'committed', 'Payscore Property CSV Import Example - Properties.csv', '2026-02-12 04:47:44.108779', '2026-02-13 00:39:47.667231'),
(13, 'draft', 'Sample_Import.csv', '2026-02-13 02:00:10.039910', '2026-02-13 02:00:10.039910')
;

-- Staged rows (89)
INSERT INTO staged_rows (id, import_session_id, row_number, building_name, street_address, unit_number, city, state, zip_code, validation_errors, created_at, updated_at, skip_unit, skip_property) VALUES
(1, 2, 2, 'Avenue Apartments', '123 Test St', '108', 'Seattle', 'Washington', '98122', NULL, '2026-02-11 05:17:57.831263', '2026-02-11 05:37:27.064748', FALSE, FALSE),
(2, 2, 3, 'Avenue Apartments', '123 Test St', '109', 'Seattle', 'Washington', '98122', NULL, '2026-02-11 05:17:57.843143', '2026-02-11 05:17:57.843143', FALSE, FALSE),
(3, 2, 4, 'Avenue Apartments', '123 Test St', '110', 'Seattle', 'Washington', '98122', NULL, '2026-02-11 05:17:57.854236', '2026-02-11 05:17:57.854236', FALSE, FALSE),
(4, 2, 5, '4230 Main St.', '4230 Main St.', '', 'Seattle', 'Washington', '98105', NULL, '2026-02-11 05:17:57.867212', '2026-02-11 05:30:09.695422', FALSE, FALSE),
(5, 2, 6, '569 Pine Dr.', '569 Pine Dr', '', 'Seattle', 'Washington', '19345', NULL, '2026-02-11 05:17:57.884509', '2026-02-11 05:41:19.113384', FALSE, FALSE),
(6, 2, 7, 'Riverside Tower', '400 First Avenue', '201', 'Seattle', 'Washington', '98101', NULL, '2026-02-11 05:17:57.918567', '2026-02-11 05:41:26.955846', FALSE, FALSE),
(7, 2, 8, 'Riverside Tower', '400 First Avenue', '202', 'Seattle', 'Washington', '98101', NULL, '2026-02-11 05:17:57.949630', '2026-02-11 05:42:48.461643', FALSE, FALSE),
(8, 2, 9, 'Riverside Tower', '400 First Ave', '203', 'Seattle', 'Washington', '98101', NULL, '2026-02-11 05:17:57.980074', '2026-02-11 05:17:57.980074', FALSE, FALSE),
(9, 2, 10, 'Riverside Tower', '400 First Ave', '204', 'Seattle', 'Washington', '98101', NULL, '2026-02-11 05:17:57.999522', '2026-02-11 05:17:57.999522', FALSE, FALSE),
(10, 2, 11, 'Cascade Commons', '2500 Eastlake Ave', '1A', 'Seattle', 'Washington', '98102', NULL, '2026-02-11 05:17:58.016405', '2026-02-11 05:34:17.299977', FALSE, FALSE),
(11, 2, 12, 'Cascade Commons', '2500 Eastlake Ave', '1A', 'Seattle', 'Washington', '98102', NULL, '2026-02-11 05:17:58.056383', '2026-02-11 05:30:09.855378', FALSE, FALSE),
(12, 2, 13, 'Cascade Commons', '2500 Eastlake Ave', '2A', 'Seattle', 'Washington', '98102', NULL, '2026-02-11 05:17:58.070471', '2026-02-11 05:17:58.070471', FALSE, FALSE),
(13, 2, 14, 'Cascade Commons', '2500 Eastlake Ave', '2B', 'Seattle', 'Washington', '98102', NULL, '2026-02-11 05:17:58.095902', '2026-02-11 05:17:58.095902', FALSE, FALSE),
(14, 2, 15, 'Cascade Commons', '2500 Eastlake Ave', '3A', 'Seattle', 'Washington', '98102', NULL, '2026-02-11 05:17:58.114724', '2026-02-11 05:36:57.865952', FALSE, FALSE),
(15, 2, 16, 'Summit Place', '8900 Lake City Way NE', '', 'Seattle', 'Washington', '98115', NULL, '2026-02-11 05:17:58.137335', '2026-02-11 05:30:09.899714', FALSE, FALSE),
(16, 2, 17, 'Greenwood Arms', '8500 Greenwood Ave N', '101', 'Seattle', 'Washington', '98103', NULL, '2026-02-11 05:17:58.170721', '2026-02-11 05:17:58.170721', FALSE, FALSE),
(17, 2, 18, 'Greenwood Arms', '8500 Greenwood Ave N', '102', 'Seattle', 'Washington', '98103', NULL, '2026-02-11 05:17:58.187279', '2026-02-11 05:17:58.187279', FALSE, FALSE),
(18, 2, 19, 'Greenwood Arms', '8500 Greenwood Ave N', '103', 'Seattle', 'Washington', '98103', NULL, '2026-02-11 05:17:58.217971', '2026-02-11 05:17:58.217971', FALSE, FALSE),
(19, 2, 20, 'Pioneer Square Lofts', '318 1st Ave S', '100', 'Seattle', 'Washington', '98104', NULL, '2026-02-11 05:17:58.234494', '2026-02-11 05:17:58.234494', FALSE, FALSE),
(20, 2, 21, 'Pioneer Square Lofts', '318 1st Ave S', '200', 'Seattle', 'Washington', '98104', NULL, '2026-02-11 05:17:58.267206', '2026-02-11 05:17:58.267206', FALSE, FALSE),
(21, 2, 22, 'Pioneer Square Lofts', '318 1st Ave S', '300', 'Seattle', 'Washington', '98104', NULL, '2026-02-11 05:17:58.281692', '2026-02-11 05:17:58.281692', FALSE, FALSE),
(22, 2, 23, 'Pioneer Square Lofts', '318 1st Ave S', '400', 'Seattle', 'Washington', '98104', NULL, '2026-02-11 05:17:58.301880', '2026-02-11 05:17:58.301880', FALSE, FALSE),
(23, 2, 24, 'Pioneer Square Lofts', '318 1st Ave S', '500', 'Seattle', 'Washington', '98104', NULL, '2026-02-11 05:17:58.328792', '2026-02-11 05:17:58.328792', FALSE, FALSE),
(107, 7, 2, 'Avenue Apartments', '123 Test St', '101', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.180933', '2026-02-12 04:47:44.180933', TRUE, FALSE),
(108, 7, 3, 'Avenue Apartments', '123 Test St', '102', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.204472', '2026-02-12 04:47:44.204472', TRUE, FALSE),
(109, 7, 4, 'Avenue Apartments', '123 Test St', '103', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.216636', '2026-02-12 04:47:44.216636', FALSE, FALSE),
(110, 7, 5, 'Avenue Apartments', '123 Test St', '104', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.226453', '2026-02-12 04:47:44.226453', FALSE, FALSE),
(111, 7, 6, 'Avenue Apartments', '123 Test St', '105', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.237467', '2026-02-12 04:47:44.237467', FALSE, FALSE),
(112, 7, 7, 'Avenue Apartments', '123 Test St', '106', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.251197', '2026-02-12 04:47:44.251197', FALSE, FALSE),
(113, 7, 8, 'Avenue Apartments', '123 Test St', '107', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.261632', '2026-02-12 04:47:44.261632', FALSE, FALSE),
(114, 7, 9, 'Avenue Apartments', '12 North Ave', '101', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.272195', '2026-02-12 04:47:44.272195', TRUE, FALSE),
(115, 7, 10, 'Avenue Apartments', '12 North Ave', '102', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.284657', '2026-02-12 04:47:44.284657', FALSE, FALSE),
(116, 7, 11, 'Avenue Apartments', '12 North Ave', '103', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.295347', '2026-02-12 04:47:44.295347', FALSE, FALSE),
(117, 7, 12, '4230 Main St.', '4230 Main St.', NULL, 'Seattle', 'Washington', '98105', NULL, '2026-02-12 04:47:44.305793', '2026-02-12 04:47:44.305793', FALSE, FALSE),
(118, 7, 13, 'Avenue Apartments', '123 Test St', '101', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.317333', '2026-02-12 04:47:44.317333', TRUE, FALSE),
(119, 7, 14, 'Avenue Apartments', '12 North Ave', '101', 'Spokane', 'Washington', '98765', NULL, '2026-02-12 04:47:44.327113', '2026-02-12 04:47:44.327113', FALSE, FALSE),
(120, 7, 15, 'Avenue Apartments', '12 North Ave', '101', 'Seattle', 'Washington', '98105', NULL, '2026-02-12 04:47:44.338303', '2026-02-12 04:47:44.338303', FALSE, FALSE),
(121, 7, 16, 'Avenue Apartments', '12 North Ave.', '101', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.349096', '2026-02-12 04:47:44.349096', TRUE, FALSE),
(122, 7, 17, 'Boulevard Lofts', '123 Test St', '101', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.359890', '2026-02-12 04:47:44.359890', TRUE, FALSE),
(123, 7, 18, 'Boulevard Lofts', '123 Test ST', '102', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.371869', '2026-02-12 04:47:44.371869', FALSE, FALSE),
(124, 7, 19, 'BOULEVARD LOFTS', '123 TEST ST', '101', 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.383135', '2026-02-12 04:47:44.383135', TRUE, FALSE),
(125, 7, 20, 'Grand Boulevarde', '123 test streeteste', '1010', 'seattleest', 'WA', '98120', NULL, '2026-02-12 04:47:44.392416', '2026-02-12 04:47:44.392416', FALSE, FALSE),
(126, 7, 21, 'Boulevard Lofts', '123 Test St', NULL, 'Seattle', 'Washington', '98122', NULL, '2026-02-12 04:47:44.404687', '2026-02-12 04:47:44.404687', FALSE, FALSE),
(127, 7, 22, '569 Pine Dr.', '569 Pine Dr.', NULL, 'Seattle', 'Washington', '19345', NULL, '2026-02-12 04:47:44.418183', '2026-02-12 04:47:44.418183', FALSE, FALSE),
(128, 13, 2, '', '123 Test St', '108', 'Seattle', 'WA', '98122', '["Building Name required"]', '2026-02-13 02:00:12.389785', '2026-02-13 02:00:12.389785', FALSE, FALSE),
(129, 13, 3, 'Avenue Apartments', '123 Test St', '109', '', 'WA', '98122', '["City required"]', '2026-02-13 02:00:12.472079', '2026-02-13 02:00:12.472079', FALSE, FALSE),
(130, 13, 4, 'Avenue Apartments', '123 Test St', '110', 'Seattle', '', '98122', '["State required"]', '2026-02-13 02:00:12.488952', '2026-02-13 02:00:12.488952', FALSE, FALSE),
(131, 13, 5, '4230 Main St.', '4230 Main St.', NULL, 'Seattle', 'WA', '98105', NULL, '2026-02-13 02:00:12.510615', '2026-02-13 02:00:12.510615', FALSE, FALSE),
(132, 13, 6, '569 Pine Dr.', '569 Pine Dr.', NULL, 'Seattle', 'WA', '19345', NULL, '2026-02-13 02:00:12.533625', '2026-02-13 02:00:12.533625', FALSE, FALSE),
(133, 13, 7, 'Riverside Tower', '400 First Ave', '201', 'Seattle', 'WA', '98101', NULL, '2026-02-13 02:00:12.555869', '2026-02-13 02:00:12.555869', FALSE, FALSE),
(134, 13, 8, 'Riverside Tower', '400 First Ave', '202', 'Seattle', 'WA', '98101', NULL, '2026-02-13 02:00:12.572939', '2026-02-13 02:00:12.572939', FALSE, FALSE),
(135, 13, 9, 'Riverside Tower', '', '212', 'Seattle', 'WA', '', '["Street Address required","Zip Code required"]', '2026-02-13 02:00:12.646903', '2026-02-13 02:00:12.646903', FALSE, FALSE),
(136, 13, 10, 'Riverside Tower', '400 First Ave', '201', 'Seattle', 'WA', '98101', NULL, '2026-02-13 02:00:12.669273', '2026-02-13 02:00:12.669273', FALSE, FALSE),
(137, 13, 11, 'Cascade Commons', '2500 Eastlake Ave', '1A', 'Seattle', 'WA', '98102', NULL, '2026-02-13 02:00:12.688837', '2026-02-13 02:00:12.688837', FALSE, FALSE),
(138, 13, 12, 'Cascade Commons', '2500 Eastlake Ave', '1B', 'Seattle', 'WA', '98102', NULL, '2026-02-13 02:00:12.706562', '2026-02-13 02:00:12.706562', FALSE, FALSE),
(139, 13, 13, 'Cascade Square', '2500 Eastlake Ave', '1A', 'Seattle', 'WA', '98102', NULL, '2026-02-13 02:00:12.724796', '2026-02-13 02:00:12.724796', FALSE, FALSE),
(140, 13, 14, 'Cascade Square', '2500 Eastlake Ave', '1B', 'Seattle', 'WA', '98102', NULL, '2026-02-13 02:00:12.754695', '2026-02-13 02:00:12.754695', FALSE, FALSE),
(141, 13, 15, 'Summit Place', '8900 Lake City Way NE', NULL, 'Seattle', 'WA', '98115', NULL, '2026-02-13 02:00:12.779018', '2026-02-13 02:00:12.779018', FALSE, FALSE),
(142, 13, 16, 'Greenwood Arms', '8500 Greenwood Ave N', '101', 'Seattle', 'WA', '98103', NULL, '2026-02-13 02:00:12.813337', '2026-02-13 02:00:12.813337', FALSE, FALSE),
(143, 13, 17, 'Greenwood Arms', '8500 Greenwood Ave N', '102', 'Seattle', 'WA', '98103', NULL, '2026-02-13 02:00:12.836952', '2026-02-13 02:00:12.836952', FALSE, FALSE),
(144, 13, 18, 'Greenwood Arms', '8500 Greenwood Ave N', '103', 'Seattle', 'WA', '98103', NULL, '2026-02-13 02:00:12.851933', '2026-02-13 02:00:12.851933', FALSE, FALSE),
(145, 13, 19, 'Boulevard Lofts', '123 Test St', '100', 'Seattle', 'Washington', '98122', NULL, '2026-02-13 02:00:12.870147', '2026-02-13 02:00:12.870147', FALSE, FALSE),
(146, 13, 20, 'Boulevard Lofts', '123 Test St', '102', 'Seattle', 'Washington', '98122', NULL, '2026-02-13 02:00:12.895955', '2026-02-13 02:00:12.895955', FALSE, FALSE),
(147, 13, 21, 'Boulevard Lofts', '123 Test St', '103', 'Seattle', 'Washington', '98122', NULL, '2026-02-13 02:00:12.921177', '2026-02-13 02:00:12.921177', FALSE, FALSE),
(148, 13, 22, 'Boulevard Lofts', '123 Test St', '104', 'Seattle', 'Washington', '98122', NULL, '2026-02-13 02:00:12.941063', '2026-02-13 02:00:12.941063', FALSE, FALSE),
(149, 13, 23, 'Boulevard Lofts', '123 Test St', '105', 'Seattle', 'Washington', '98122', NULL, '2026-02-13 02:00:12.960389', '2026-02-13 02:00:12.960389', FALSE, FALSE)
;

-- Reset sequences for PostgreSQL
SELECT setval(pg_get_serial_sequence('import_sessions', 'id'), (SELECT COALESCE(MAX(id), 1) FROM import_sessions));
SELECT setval(pg_get_serial_sequence('staged_rows', 'id'), (SELECT COALESCE(MAX(id), 1) FROM staged_rows));
