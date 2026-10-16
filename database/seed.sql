USE payroll_db;

INSERT INTO departments(department_code,department_name) VALUES
('HR','Human Resources'),('FIN','Finance'),('IT','Information Technology');
INSERT INTO designations(designation_name,grade) VALUES
('Payroll Officer','G6'),('Software Engineer','G7'),('HR Manager','G8');
INSERT INTO employees(employee_no,first_name,last_name,email,phone,national_id,department_id,designation_id,bank_name,bank_account_no,hire_date) VALUES
('EMP001','Amina','Okafor','amina@example.test','9000000001','TEST-NID-001',1,1,'Unity Bank','TEST-001','2022-03-01'),
('EMP002','Daniel','Mensah','daniel@example.test','9000000002','TEST-NID-002',3,2,'City Bank','TEST-002','2021-07-15'),
('EMP003','Grace','Adeyemi','grace@example.test','9000000003','TEST-NID-003',1,3,'Unity Bank','TEST-003','2020-01-10');
INSERT INTO salary_structures(designation_id,effective_from,basic_salary,housing_allowance,transport_allowance) VALUES
(1,'2025-01-01',250000,50000,25000),(2,'2025-01-01',420000,80000,40000),(3,'2025-01-01',600000,120000,60000);
INSERT INTO payroll_periods(period_name,period_start,period_end,payment_date,status) VALUES
('January 2026','2026-01-01','2026-01-31','2026-02-02','PROCESSED'),
('February 2026','2026-02-01','2026-02-28','2026-03-02','OPEN');
INSERT INTO attendance_summaries(employee_id,period_start,period_end,working_days,days_present,overtime_hours) VALUES
(1,'2026-01-01','2026-01-31',22,22,8),(2,'2026-01-01','2026-01-31',22,21,12),(3,'2026-01-01','2026-01-31',22,20,0),
(1,'2026-02-01','2026-02-28',20,20,4),(2,'2026-02-01','2026-02-28',20,20,0),(3,'2026-02-01','2026-02-28',20,19,0);
INSERT INTO loans(employee_id,loan_type,principal_amount,balance,monthly_installment,start_date) VALUES
(2,'Staff Loan',300000,150000,30000,'2025-08-01'),(1,'Emergency Loan',60000,0,20000,'2025-11-01');
UPDATE loans SET status='PAID' WHERE employee_id=1 AND loan_type='Emergency Loan';

-- January payroll examples. All values are fictional, for coursework only.
INSERT INTO payroll_details(employee_id,period_id,attendance_id,basic_salary,gross_pay,total_deductions,net_pay) VALUES
(1,1,1,250000,336363.64,56818.18,279545.46),(2,1,2,420000,568636.36,100431.82,468204.54),(3,1,3,600000,780000,99000,681000);
INSERT INTO payroll_earnings(payroll_id,earning_type,amount) VALUES
(1,'Housing Allowance',50000),(1,'Transport Allowance',25000),(1,'Overtime',11363.64),
(2,'Housing Allowance',80000),(2,'Transport Allowance',40000),(2,'Overtime',28636.36),
(3,'Housing Allowance',120000),(3,'Transport Allowance',60000);
INSERT INTO payroll_deductions(payroll_id,deduction_type,statutory,amount) VALUES
(1,'Pension',TRUE,25000),(1,'PAYE',TRUE,16818.18),(1,'Loan Repayment',FALSE,15000),
(2,'Pension',TRUE,42000),(2,'PAYE',TRUE,28431.82),(2,'Loan Repayment',FALSE,30000),
(3,'Pension',TRUE,60000),(3,'PAYE',TRUE,39000);
INSERT INTO payslips(payroll_id) VALUES(1),(2),(3);
INSERT INTO bank_transfers(payroll_id,employee_id,bank_name,bank_account_no,amount,transfer_status) VALUES
(1,1,'Unity Bank','TEST-001',279545.46,'COMPLETED'),(2,2,'City Bank','TEST-002',468204.54,'PENDING'),(3,3,'Unity Bank','TEST-003',681000,'PENDING');
