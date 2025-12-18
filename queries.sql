-- Useful SQL queries for the demo project

-- 1) Real-time room assignment: find first room with available bed
SELECT room_id, room_number, ward, bed_count, occupied_beds
FROM Rooms
WHERE occupied_beds < bed_count
ORDER BY room_type DESC, room_id
LIMIT 1;

-- 2) Patient history lookup (appointments + admissions + billing)
SELECT p.patient_id, p.first_name, p.last_name, a.admission_id, a.admitted_at, a.discharged_at, ap.appointment_id, ap.appointment_date, b.bill_id, b.amount, b.paid
FROM Patients p
LEFT JOIN Admissions a ON a.patient_id = p.patient_id
LEFT JOIN Appointments ap ON ap.patient_id = p.patient_id
LEFT JOIN Billing b ON b.patient_id = p.patient_id
WHERE p.patient_id = 1
ORDER BY ap.appointment_date DESC, a.admitted_at DESC;

-- 3) Doctor availability scheduling: upcoming slots (simple)
SELECT d.doctor_id, d.first_name, d.last_name, ap.appointment_date, ap.status
FROM Doctors d
LEFT JOIN Appointments ap ON ap.doctor_id = d.doctor_id AND ap.appointment_date >= NOW()
WHERE d.doctor_id = 1
ORDER BY ap.appointment_date
LIMIT 10;

-- 4) Low stock items
SELECT item_id, item_name, quantity, reorder_level FROM Inventory WHERE quantity < reorder_level;

-- 5) Total billing outstanding
SELECT SUM(amount) AS total_outstanding FROM Billing WHERE paid = FALSE;

-- 6) Full profit % (example: revenue - cost) -- requires cost tracking; here we do simple revenue
SELECT (SUM(amount) - 0) / NULLIF(SUM(amount),0) * 100 AS profit_percent_estimate FROM Billing;

