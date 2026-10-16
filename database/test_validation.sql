-- Run against disposable coursework data: mysql --force -u root -p < database/test_validation.sql
USE payroll_db;

-- Invalid cases are expected to print an error. Run with --force so the later
-- rollback and boundary checks continue. The deliberate cases do not persist.
START TRANSACTION;
INSERT INTO employees(employee_no,first_name,last_name,email,department_id,designation_id,hire_date)
VALUES('EMP001','Duplicate','Row','duplicate@example.test',1,1,'2024-01-01');
ROLLBACK;

START TRANSACTION;
INSERT INTO attendance_summaries(employee_id,period_start,period_end,working_days,days_present)
VALUES(1,'2026-03-01','2026-03-31',20,21);
ROLLBACK;

START TRANSACTION;
UPDATE loans SET balance=-1 WHERE loan_id=1;
ROLLBACK;

START TRANSACTION;
INSERT INTO payroll_details(employee_id,period_id,attendance_id,basic_salary,gross_pay,total_deductions,net_pay)
VALUES(1,1,1,250000,333000,340000,-7000);
ROLLBACK;

START TRANSACTION;
UPDATE payroll_details SET net_pay=1 WHERE payroll_id=1;
ROLLBACK;

START TRANSACTION;
INSERT INTO payroll_details(employee_id,period_id,attendance_id,basic_salary,gross_pay,total_deductions,net_pay)
VALUES(1,2,4,100,100,50,50);
INSERT INTO payroll_deductions(payroll_id,deduction_type,statutory,amount)
VALUES(LAST_INSERT_ID(),'Invalid excess',FALSE,101);
ROLLBACK;

START TRANSACTION;
INSERT INTO attendance_summaries(employee_id,period_start,period_end,working_days,days_present,overtime_hours)
VALUES(1,'2026-04-01','2026-04-30',20,0,0);
ROLLBACK;

-- Duplicate payroll check uses a harmless direct attempt in an explicit rollback.
START TRANSACTION;
INSERT INTO payroll_details(employee_id,period_id,attendance_id,basic_salary,gross_pay,total_deductions,net_pay)
VALUES(1,1,1,250000,333000,37500,295500);
ROLLBACK;

-- Inspect current data after validation runs; the seed data should be unchanged.
SELECT COUNT(*) AS seeded_employees FROM employees;
SELECT COUNT(*) AS seeded_payrolls FROM payroll_details;
