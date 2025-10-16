-- Delete all CSV-loaded vendors (M001-M150) and their services
DELETE FROM services WHERE vendor_id IN (SELECT id FROM vendors WHERE vendor_code LIKE 'M%');
DELETE FROM vendors WHERE vendor_code LIKE 'M%';

-- Verify remaining data
SELECT COUNT(*) as total_vendors FROM vendors;
SELECT COUNT(*) as total_services FROM services;

-- Show remaining vendor
SELECT vendor_code, business_name, primary_category FROM vendors ORDER BY vendor_code;
