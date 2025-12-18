-- Hospital Management Database Schema (MySQL)
-- Create tables and example triggers

DROP TABLE IF EXISTS Appointments;
DROP TABLE IF EXISTS Admissions;
DROP TABLE IF EXISTS Billing;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Patients;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Rooms;

CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    gender ENUM('M','F','O') DEFAULT 'O',
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255),
    working_hours VARCHAR(100), -- e.g. "Mon-Fri 09:00-17:00"
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(20) UNIQUE NOT NULL,
    ward VARCHAR(50),
    bed_count INT DEFAULT 1,
    occupied_beds INT DEFAULT 0,
    room_type ENUM('General','Private','ICU','OT') DEFAULT 'General',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('Scheduled','Completed','Cancelled','No-Show') DEFAULT 'Scheduled',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    INDEX idx_appointment_datetime (appointment_date)
);

CREATE TABLE Admissions (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    room_id INT,
    admitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    discharged_at DATETIME,
    status ENUM('Admitted','Discharged') DEFAULT 'Admitted',
    primary_doctor_id INT,
    notes TEXT,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    FOREIGN KEY (primary_doctor_id) REFERENCES Doctors(doctor_id)
);

CREATE TABLE Billing (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT,
    admission_id INT,
    amount DECIMAL(10,2) DEFAULT 0.00,
    paid BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id),
    FOREIGN KEY (admission_id) REFERENCES Admissions(admission_id)
);

CREATE TABLE Inventory (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 10,
    unit_price DECIMAL(10,2) DEFAULT 0.00,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Trigger: When an admission is inserted, increment occupied_beds for the room (if room_id provided)
DROP TRIGGER IF EXISTS tr_admission_insert;
DELIMITER $$
CREATE TRIGGER tr_admission_insert
AFTER INSERT ON Admissions
FOR EACH ROW
BEGIN
    IF NEW.room_id IS NOT NULL THEN
        UPDATE Rooms SET occupied_beds = occupied_beds + 1 WHERE room_id = NEW.room_id;
    END IF;
END$$
DELIMITER ;

-- Trigger: When a discharge happens (discharged_at set, status changed), decrement occupied_beds
DROP TRIGGER IF EXISTS tr_admission_update;
DELIMITER $$
CREATE TRIGGER tr_admission_update
AFTER UPDATE ON Admissions
FOR EACH ROW
BEGIN
    IF OLD.status = 'Admitted' AND NEW.status = 'Discharged' THEN
        IF OLD.room_id IS NOT NULL THEN
            UPDATE Rooms SET occupied_beds = GREATEST(0, occupied_beds - 1) WHERE room_id = OLD.room_id;
        END IF;
    END IF;
END$$
DELIMITER ;

-- Trigger: When inventory quantity falls below reorder_level, insert a notification row into a simple notifications table
DROP TABLE IF EXISTS Notifications;
CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT,
    message VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    handled BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (item_id) REFERENCES Inventory(item_id)
);

DROP TRIGGER IF EXISTS tr_inventory_update;
DELIMITER $$
CREATE TRIGGER tr_inventory_update
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    IF NEW.quantity < NEW.reorder_level THEN
        INSERT INTO Notifications (item_id, message) VALUES (NEW.item_id, CONCAT('Low stock: ', NEW.item_name, ' (', NEW.quantity, ')'));
    END IF;
END$$
DELIMITER ;

-- Trigger: When appointment is inserted for within next 24 hours, create a notification (simple demo)
DROP TRIGGER IF EXISTS tr_appointment_insert;
DELIMITER $$
CREATE TRIGGER tr_appointment_insert
AFTER INSERT ON Appointments
FOR EACH ROW
BEGIN
    -- If appointment is within next 24 hours, add a notification
    IF NEW.appointment_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 1 DAY) THEN
        INSERT INTO Notifications (message, item_id) VALUES (CONCAT('Appointment reminder for patient_id=', NEW.patient_id, ' at ', NEW.appointment_date), NULL);
    END IF;
END$$
DELIMITER ;

-- Indexes for performance
CREATE INDEX idx_inventory_item_name ON Inventory (item_name);
CREATE INDEX idx_patients_name ON Patients (last_name, first_name);

