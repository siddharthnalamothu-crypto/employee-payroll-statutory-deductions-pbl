# Review 3 — Working MVP

## Python application

`app/main.py` is a Tkinter desktop client with employee add, select, search, update, delete, salary-structure maintenance and report windows. `app/payroll.py` calculates payroll in a MySQL transaction and updates the matching loan installments. `app/cli.py` supports attendance, payroll, payslip and bank-transfer operations. Database credentials come from environment variables in `app/db.py`.

## Run and complete workflow

See root `README.md` for MySQL setup, dependency installation, GUI launch and commands. Suggested workflow: maintain employee and salary data; record attendance; calculate payroll; inspect gross/deduction/net; generate payslip record; create transfer instruction; view reports.

## Demo talk track

1. “This screen reads employee rows from MySQL and supports search.”
2. Add/select an employee; edit email or department; show validation and duplicate-key error.
3. Record February attendance with the CLI, then calculate payroll for that employee and period.
4. Show the payroll row and itemized earning/deduction rows in MySQL.
5. Generate payslip and bank-transfer instruction; show department and transfer reports.
6. Try deleting an employee with payroll history; explain the foreign-key restriction.
7. “The payroll and loan balance update are committed together, or rolled back together if an error occurs.”

## Calculation assumptions

For demonstration only: overtime = basic salary / 176 hours × overtime hours; pension = 10% of basic salary; PAYE = 5% of gross. These are fictional classroom rules and are not statutory advice. There is no live bank API. Bank transfer is a stored instruction/status record.

## College-template report

`docs/final_report.docx` is intended to follow the uploaded Woxsen University template. The required student name and roll number remain placeholders. Add real screenshots and actual test outputs after running MySQL. A college-specific declaration/certificate needs authorized signature; the system does not fabricate one.

## Publication and hosting

The requested public GitHub repository has not been created because the workspace cannot access the login on Siddharth's Mac. Run `bash publish_to_github.sh` from the downloaded project folder while `gh` is logged in as `siddharthnalamothu-crypto`; the script checks the account before creating or pushing. This is a desktop Tkinter app, so it runs locally. A hosted deployment would require a hosted MySQL database and a web interface; a local MySQL server cannot serve a public app.
