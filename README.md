# Employee Payroll and Statutory Deduction Management System

PBL project prepared for MySQL 8.0+ and Python 3.10+. It demonstrates relational design, 3NF, keys/constraints, SQL reports, transactions and database application integration.

## Student/project details

- Student: Siddharth [enter full name]
- Roll number: [enter roll number]
- Project number: [enter assigned project number if applicable]
- Mentor: Dr. Sahithi
- Semester: 3; Section: CSE Panthers
- Course: 25TU03MJM0 — Database Management Systems

## Repository layout

```text
database/       MySQL schema, fictional seed data, reports and validation script
app/            Tkinter desktop application, database helper and payroll workflow
docs/review-1/  design, ER diagram and review speaking notes
docs/review-2/  3NF, SQL prototype notes and test matrix
docs/review-3/  MVP demo, video script and presentation outline
docs/           editable final report and college template source
presentation/   generated PowerPoint presentation
```

## Setup and run

1. Install MySQL 8.0.16 or later and Python 3.10+.
2. Create tables and views: `mysql -u root -p < database/schema.sql`.
3. Load fictional records: `mysql -u root -p payroll_db < database/seed.sql`.
4. Install connector: `python -m pip install -r requirements.txt`.
5. Configure `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE` (defaults: localhost, 3306, root, blank password, payroll_db).
6. Start the GUI: `python -m app.main`.
7. Run reports from MySQL: `mysql -u root -p payroll_db < database/reports.sql`.

Payroll workflow examples:

```text
python -m app.cli attendance --employee 1 --start 2026-02-01 --end 2026-02-28 --working-days 20 --present 20 --overtime 4
python -m app.cli calculate --employee-no EMP001 --period 2
python -m app.cli payslip --payroll 4
python -m app.cli transfer --payroll 4
```

Example rates are fictional for coursework: overtime is basic/176 × hours, pension is 10% of basic, PAYE is 5% of gross. Confirm applicable statutory rates with your instructor; this is not tax advice. Bank transfers are records only, with no live bank integration.

## Testing

Run `mysql --force -u root -p < database/test_validation.sql` against a disposable project database. Invalid statements are expected to report errors; the script documents boundary checks and verifies seeded row counts. Record actual outcomes and add screenshots in `docs/review-2/evidence/`. Do not claim a test passed until you run it.

## Report and presentation

The college template is included as `docs/PBL Report Template.docx`. The generated `docs/final_report.docx` follows its requested chapter order and formatting; replace name/roll/project number, add actual results/screenshots, and have the appropriate staff complete/sign certificate pages before submission. `presentation/payroll_pbl_presentation.pptx` is an editable draft.

## Publication status

This folder is ready for upload. The workspace itself cannot access your Mac's GitHub login, so it has not created or pushed a repository. After downloading this folder to the Mac logged in as `siddharthnalamothu-crypto`, run `bash publish_to_github.sh`. The script checks the login, refuses to overwrite a repository with the chosen name, creates it as public, pushes `main`, and verifies visibility and the pushed branch. No deployment is live. This Tkinter application requires a MySQL database reachable by the machine running it.
