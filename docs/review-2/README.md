# Review 2 — Database Prototype

## Design and 3NF

The MySQL implementation is in `database/schema.sql`. Attributes are atomic (1NF); repeating earning/deduction values are separate rows. Single-column primary keys avoid partial dependencies (2NF), while department, designation and period descriptions are stored only with their own key, avoiding transitive dependencies (3NF).

Functional dependencies:

| Table | Functional dependency |
|---|---|
| departments | `department_id → department_code, department_name, active` |
| designations | `designation_id → designation_name, grade, active` |
| employees | `employee_id → employee_no, names, email, department_id, designation_id, hire_date, status` |
| salary_structures | `salary_structure_id → designation_id, effective dates, salary components` |
| payroll_periods | `period_id → period_name, dates, payment_date, status` |
| payroll_details | `payroll_id → employee_id, period_id, attendance_id, totals`; `(employee_id,period_id) → payroll_id` |
| payroll_earnings | `earning_id → payroll_id, earning_type, amount` |
| payroll_deductions | `deduction_id → payroll_id, deduction_type, statutory, amount` |
| loans | `loan_id → employee_id, loan_type, principal, balance, installment, status` |

Payroll totals are stored as an audit snapshot and checked by MySQL triggers for `net = gross - deductions` and `deductions <= gross`. A deduction trigger prevents aggregate deductions exceeding gross pay. Loan balance has a range check and update trigger.

## Files and SQL concepts

- `database/schema.sql`: InnoDB tables, PK/FK, UNIQUE, CHECK, DEFAULT, indexes, triggers and views.
- `database/seed.sql`: fictional sample records; all account identifiers are test labels.
- `database/reports.sql`: joins, filters, GROUP BY, aggregate, nested query, view and rollback transaction.
- `database/test_validation.sql`: invalid and boundary case scripts.

## Report examples

The reports cover gross/net by employee and period, total deductions by type, loan balance, department gross/net payroll cost, variable-pay percentage and bank transfer status. The application uses parameterized SQL and a transaction for payroll plus loan changes.

## Validation evidence

See [test matrix](test_matrix.md). Capture terminal screenshots while running each test against MySQL. The current workspace does not have a MySQL server/client, so database results are marked “not run” rather than fabricated. Python source parsing is checked separately.

## Review demonstration

Show the schema and identify a primary key, foreign key, unique employee-period key and amount/date checks. Load the seed data and run report queries. Attempt duplicate and invalid values, then show rollback behavior.

Say: “The keys protect identity and relationships, while checks validate one-row ranges. Payroll and line totals are cross-row rules, so MySQL triggers and the transactional application protect them. I also demonstrated rollback so an incomplete change does not remain in the database.”
