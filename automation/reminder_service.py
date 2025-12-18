"""Reminder service (demo)
This script connects to the MySQL DB, finds appointments in the next 24 hours, and prints simulated reminders.
Update DB connection settings below or use environment variables.
"""

import pymysql
import os
from datetime import datetime, timedelta

# Simple DB config - replace with your values or use environment variables
DB_CONFIG = {
    'host': os.getenv('DB_HOST','localhost'),
    'user': os.getenv('DB_USER','root'),
    'password': os.getenv('DB_PASS',''),
    'database': os.getenv('DB_NAME','hospital_db'),
    'cursorclass': pymysql.cursors.DictCursor
}

def get_upcoming_appointments():
    conn = pymysql.connect(**DB_CONFIG)
    try:
        with conn.cursor() as cur:
            cur.execute("""SELECT a.appointment_id, a.appointment_date, a.patient_id, p.first_name, p.last_name, p.phone, p.email, d.first_name AS doc_first, d.last_name AS doc_last
                           FROM Appointments a
                           JOIN Patients p ON p.patient_id = a.patient_id
                           JOIN Doctors d ON d.doctor_id = a.doctor_id
                           WHERE a.appointment_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 1 DAY)
                           AND a.status = 'Scheduled'""")
            return cur.fetchall()
    finally:
        conn.close()

def send_reminder(appt):
    # Demo: print a message. Replace with email/SMS integration.
    when = appt['appointment_date'].strftime('%Y-%m-%d %H:%M')
    print(f"Reminder -> Appointment #{appt['appointment_id']} for {appt['first_name']} {appt['last_name']} with Dr. {appt['doc_first']} {appt['doc_last']} at {when}. Contact: {appt['phone']}, {appt['email']}")

if __name__ == '__main__':
    appts = get_upcoming_appointments()
    if not appts:
        print('No upcoming appointments in next 24 hours.')
    for a in appts:
        send_reminder(a)
