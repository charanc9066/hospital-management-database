-- Sample data for Hospital Management Database

INSERT INTO Patients (first_name, last_name, date_of_birth, gender, phone, email, address)
VALUES
('Asha', 'Kumar', '1990-05-12', 'F', '9876543210', 'asha.k@example.com', 'Hyderabad'),
('Ravi', 'Sharma', '1985-02-20', 'M', '9123456780', 'ravi.s@example.com', 'Bengaluru'),
('Mini', 'Thomas', '2000-11-03', 'F', '9012345678', 'mini.t@example.com', 'Chennai');

INSERT INTO Doctors (first_name, last_name, specialty, phone, email, working_hours)
VALUES
('Suresh', 'Reddy', 'Cardiology', '9000000001', 'suresh.reddy@hospital.com', 'Mon-Fri 09:00-15:00'),
('Anita', 'Das', 'Orthopedics', '9000000002', 'anita.das@hospital.com', 'Tue-Sat 10:00-18:00');

INSERT INTO Rooms (room_number, ward, bed_count, occupied_beds, room_type)
VALUES
('101A', 'Ward A', 2, 0, 'General'),
('102B', 'Ward A', 1, 0, 'Private'),
('ICU-1', 'ICU', 1, 0, 'ICU');

INSERT INTO Inventory (item_name, description, quantity, reorder_level, unit_price)
VALUES
('Paracetamol 500mg', 'Pain reliever', 200, 50, 0.50),
('Surgical Gloves (Box)', 'Latex gloves, 100pcs', 8, 10, 5.00),
('Saline 500ml', 'IV fluid', 30, 20, 2.50);

-- Appointments: one within next 24 hours, one later
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, notes)
VALUES
(1, 1, DATE_ADD(NOW(), INTERVAL 10 HOUR), 'Scheduled', 'Follow-up'),
(2, 2, DATE_ADD(NOW(), INTERVAL 3 DAY), 'Scheduled', 'Knee pain');

-- Admission: admit patient 3 to room 101A
INSERT INTO Admissions (patient_id, room_id, admitted_at, status, primary_doctor_id, notes)
VALUES (3, 1, NOW(), 'Admitted', 2, 'Observation');

-- Basic billing entries
INSERT INTO Billing (patient_id, appointment_id, admission_id, amount, paid)
VALUES (1, 1, NULL, 1500.00, FALSE), (3, NULL, 1, 5000.00, FALSE);

