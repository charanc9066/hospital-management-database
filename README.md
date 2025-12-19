# Hospital Management Database (Demo Project)

**Tech Stack:** MySQL (SQL), Relational Design, Triggers, Python automation scripts

This demo project contains a complete hospital database schema, sample data, example triggers,
useful SQL queries, and simple Python automation scripts that demonstrate appointment reminders
and low-stock alerts. It's ready to run locally for testing and to include as a project for portfolios/resumes.

## What's included
- `schema.sql` - DDL to create tables, indexes, and triggers (MySQL-compatible)
- `insert_data.sql` - Sample data inserts for testing
- `queries.sql` - Useful SQL queries (room assignment, patient history, doctor availability)
- `triggers_notes.txt` - Explanations of triggers included in schema
- `automation/reminder_service.py` - Script that finds upcoming appointments and prints/simulates reminders
- `automation/low_stock_alert.py` - Script that checks inventory and prints low-stock alerts
- `requirements.txt` - Python dependencies
- `LICENSE` - MIT License

## How to use
1. Install MySQL server and create a database `hospital_db`.
2. Run: `mysql -u root -p hospital_db < schema.sql`
3. Run: `mysql -u root -p hospital_db < insert_data.sql`
4. Review and run queries in `queries.sql` using your MySQL client.
5. Python scripts connect using `pymysql`. Update the DB connection settings in `automation/*.py`.
6. To package project for uploading, use the included zip file.

## Notes
- Triggers are written for MySQL. Adjust syntax if using PostgreSQL.
- The automation scripts simulate sending reminders/alerts by printing messages.
- This is an educational demo — do not use in production without proper security/hardening.

