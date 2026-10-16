-- MySQL 8.0+ schema. Run with: mysql -u root -p < database/schema.sql
CREATE DATABASE IF NOT EXISTS payroll_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE payroll_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP VIEW IF EXISTS v_payroll_summary;
DROP VIEW IF EXISTS v_loan_balances;
DROP TABLE IF EXISTS bank_transfers, payslips, payroll_deductions, payroll_earnings,
 payroll_details, loans, attendance_summaries, payroll_periods, salary_structures,
 employees, designations, departments;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE departments (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  department_code VARCHAR(20) NOT NULL UNIQUE,
  department_name VARCHAR(100) NOT NULL UNIQUE,
  active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE designations (
  designation_id INT AUTO_INCREMENT PRIMARY KEY,
  designation_name VARCHAR(100) NOT NULL UNIQUE,
  grade VARCHAR(20) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE employees (
  employee_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_no VARCHAR(20) NOT NULL UNIQUE,
  first_name VARCHAR(60) NOT NULL,
  last_name VARCHAR(60) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(30),
  national_id VARCHAR(40) UNIQUE,
  department_id INT NOT NULL,
  designation_id INT NOT NULL,
  bank_name VARCHAR(100),
  bank_account_no VARCHAR(40),
  hire_date DATE NOT NULL,
  employment_status ENUM('ACTIVE','INACTIVE','ON_LEAVE') NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_employee_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
  CONSTRAINT fk_employee_designation FOREIGN KEY (designation_id) REFERENCES designations(designation_id)
) ENGINE=InnoDB;

CREATE TABLE salary_structures (
  salary_structure_id INT AUTO_INCREMENT PRIMARY KEY,
  designation_id INT NOT NULL,
  effective_from DATE NOT NULL,
  effective_to DATE NULL,
  basic_salary DECIMAL(12,2) NOT NULL,
  housing_allowance DECIMAL(12,2) NOT NULL DEFAULT 0,
  transport_allowance DECIMAL(12,2) NOT NULL DEFAULT 0,
  UNIQUE KEY uq_salary_effective (designation_id,effective_from),
  CONSTRAINT fk_salary_designation FOREIGN KEY (designation_id) REFERENCES designations(designation_id),
  CONSTRAINT chk_basic_positive CHECK (basic_salary > 0),
  CONSTRAINT chk_allowances_nonnegative CHECK (housing_allowance >= 0 AND transport_allowance >= 0),
  CONSTRAINT chk_salary_dates CHECK (effective_to IS NULL OR effective_to >= effective_from)
) ENGINE=InnoDB;

CREATE TABLE payroll_periods (
  period_id INT AUTO_INCREMENT PRIMARY KEY,
  period_name VARCHAR(30) NOT NULL UNIQUE,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  payment_date DATE NOT NULL,
  status ENUM('OPEN','PROCESSED','PAID','CLOSED') NOT NULL DEFAULT 'OPEN',
  UNIQUE KEY uq_period_dates (period_start,period_end),
  CONSTRAINT chk_period_dates CHECK (period_end >= period_start AND payment_date >= period_end)
) ENGINE=InnoDB;

CREATE TABLE attendance_summaries (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  working_days INT NOT NULL,
  days_present INT NOT NULL,
  overtime_hours DECIMAL(8,2) NOT NULL DEFAULT 0,
  UNIQUE KEY uq_attendance_period (employee_id,period_start,period_end),
  CONSTRAINT fk_attendance_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  CONSTRAINT chk_attendance_days CHECK (working_days > 0 AND days_present BETWEEN 0 AND working_days),
  CONSTRAINT chk_attendance_dates CHECK (period_end >= period_start),
  CONSTRAINT chk_overtime_nonnegative CHECK (overtime_hours >= 0)
) ENGINE=InnoDB;

CREATE TABLE loans (
  loan_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  loan_type VARCHAR(40) NOT NULL,
  principal_amount DECIMAL(12,2) NOT NULL,
  balance DECIMAL(12,2) NOT NULL,
  monthly_installment DECIMAL(12,2) NOT NULL,
  start_date DATE NOT NULL,
  status ENUM('ACTIVE','PAID','CANCELLED') NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_loan_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  CONSTRAINT chk_loan_amounts CHECK (principal_amount > 0 AND balance BETWEEN 0 AND principal_amount AND monthly_installment > 0),
  INDEX idx_loan_employee_status (employee_id,status)
) ENGINE=InnoDB;

CREATE TABLE payroll_details (
  payroll_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  period_id INT NOT NULL,
  attendance_id INT NULL,
  basic_salary DECIMAL(12,2) NOT NULL,
  gross_pay DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_deductions DECIMAL(12,2) NOT NULL DEFAULT 0,
  net_pay DECIMAL(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_employee_period_payroll (employee_id,period_id),
  CONSTRAINT fk_payroll_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  CONSTRAINT fk_payroll_period FOREIGN KEY (period_id) REFERENCES payroll_periods(period_id),
  CONSTRAINT fk_payroll_attendance FOREIGN KEY (attendance_id) REFERENCES attendance_summaries(attendance_id),
  CONSTRAINT chk_payroll_amounts CHECK (basic_salary >= 0 AND gross_pay >= 0 AND total_deductions >= 0 AND net_pay >= 0),
  INDEX idx_payroll_period (period_id)
) ENGINE=InnoDB;

CREATE TABLE payroll_earnings (
  earning_id INT AUTO_INCREMENT PRIMARY KEY,
  payroll_id INT NOT NULL,
  earning_type VARCHAR(40) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  UNIQUE KEY uq_payroll_earning_type (payroll_id,earning_type),
  CONSTRAINT fk_earning_payroll FOREIGN KEY (payroll_id) REFERENCES payroll_details(payroll_id) ON DELETE CASCADE,
  CONSTRAINT chk_earning_amount CHECK (amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE payroll_deductions (
  deduction_id INT AUTO_INCREMENT PRIMARY KEY,
  payroll_id INT NOT NULL,
  deduction_type VARCHAR(40) NOT NULL,
  statutory BOOLEAN NOT NULL DEFAULT FALSE,
  amount DECIMAL(12,2) NOT NULL,
  UNIQUE KEY uq_payroll_deduction_type (payroll_id,deduction_type),
  CONSTRAINT fk_deduction_payroll FOREIGN KEY (payroll_id) REFERENCES payroll_details(payroll_id) ON DELETE CASCADE,
  CONSTRAINT chk_deduction_amount CHECK (amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE payslips (
  payslip_id INT AUTO_INCREMENT PRIMARY KEY,
  payroll_id INT NOT NULL UNIQUE,
  generated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  document_status ENUM('GENERATED','SENT') NOT NULL DEFAULT 'GENERATED',
  CONSTRAINT fk_payslip_payroll FOREIGN KEY (payroll_id) REFERENCES payroll_details(payroll_id)
) ENGINE=InnoDB;

CREATE TABLE bank_transfers (
  transfer_id INT AUTO_INCREMENT PRIMARY KEY,
  payroll_id INT NOT NULL UNIQUE,
  employee_id INT NOT NULL,
  bank_name VARCHAR(100) NOT NULL,
  bank_account_no VARCHAR(40) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  transfer_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  transfer_status ENUM('PENDING','COMPLETED','FAILED') NOT NULL DEFAULT 'PENDING',
  CONSTRAINT fk_transfer_payroll FOREIGN KEY (payroll_id) REFERENCES payroll_details(payroll_id),
  CONSTRAINT fk_transfer_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  CONSTRAINT chk_transfer_amount CHECK (amount > 0)
) ENGINE=InnoDB;

CREATE INDEX idx_employee_name ON employees(last_name,first_name);
CREATE INDEX idx_attendance_period ON attendance_summaries(period_start,period_end);

-- MySQL CHECK constraints cannot aggregate child rows. This trigger protects
-- deduction limits; the app also calculates totals inside a transaction.
DELIMITER $$
CREATE TRIGGER trg_deduction_limit_insert BEFORE INSERT ON payroll_deductions
FOR EACH ROW
BEGIN
  DECLARE v_gross DECIMAL(12,2);
  DECLARE v_total DECIMAL(12,2);
  SELECT gross_pay INTO v_gross FROM payroll_details WHERE payroll_id=NEW.payroll_id;
  SELECT COALESCE(SUM(amount),0) INTO v_total FROM payroll_deductions WHERE payroll_id=NEW.payroll_id;
  IF v_total + NEW.amount > v_gross THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Total deductions cannot exceed gross pay';
  END IF;
END$$
CREATE TRIGGER trg_deduction_limit_update BEFORE UPDATE ON payroll_deductions
FOR EACH ROW
BEGIN
  DECLARE v_gross DECIMAL(12,2);
  DECLARE v_total DECIMAL(12,2);
  SELECT gross_pay INTO v_gross FROM payroll_details WHERE payroll_id=NEW.payroll_id;
  SELECT COALESCE(SUM(amount),0) INTO v_total FROM payroll_deductions WHERE payroll_id=NEW.payroll_id AND deduction_id<>OLD.deduction_id;
  IF v_total + NEW.amount > v_gross THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Total deductions cannot exceed gross pay';
  END IF;
END$$
CREATE TRIGGER trg_loan_balance_update BEFORE UPDATE ON loans
FOR EACH ROW
BEGIN
  IF NEW.balance < 0 OR NEW.balance > NEW.principal_amount THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Loan balance must be between zero and principal';
  END IF;
  IF NEW.balance=0 AND NEW.status='ACTIVE' THEN SET NEW.status='PAID'; END IF;
END$$
CREATE TRIGGER trg_payroll_totals_insert BEFORE INSERT ON payroll_details
FOR EACH ROW
BEGIN
  IF NEW.total_deductions > NEW.gross_pay OR NEW.net_pay <> NEW.gross_pay - NEW.total_deductions THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Payroll totals inconsistent or deductions exceed gross pay';
  END IF;
END$$
CREATE TRIGGER trg_payroll_totals_update BEFORE UPDATE ON payroll_details
FOR EACH ROW
BEGIN
  IF NEW.total_deductions > NEW.gross_pay OR NEW.net_pay <> NEW.gross_pay - NEW.total_deductions THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Payroll totals inconsistent or deductions exceed gross pay';
  END IF;
END$$
CREATE TRIGGER trg_employee_hire_date_insert BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
  IF NEW.hire_date > CURRENT_DATE THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Hire date cannot be in the future';
  END IF;
END$$
CREATE TRIGGER trg_employee_hire_date_update BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
  IF NEW.hire_date > CURRENT_DATE THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Hire date cannot be in the future';
  END IF;
END$$
CREATE TRIGGER trg_transfer_matches_payroll_insert BEFORE INSERT ON bank_transfers
FOR EACH ROW
BEGIN
  DECLARE v_net DECIMAL(12,2);
  DECLARE v_employee INT;
  SELECT net_pay,employee_id INTO v_net,v_employee FROM payroll_details WHERE payroll_id=NEW.payroll_id;
  IF NEW.amount <> v_net OR NEW.employee_id <> v_employee THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transfer employee and amount must match payroll';
  END IF;
END$$
CREATE TRIGGER trg_transfer_matches_payroll_update BEFORE UPDATE ON bank_transfers
FOR EACH ROW
BEGIN
  DECLARE v_net DECIMAL(12,2);
  DECLARE v_employee INT;
  SELECT net_pay,employee_id INTO v_net,v_employee FROM payroll_details WHERE payroll_id=NEW.payroll_id;
  IF NEW.amount <> v_net OR NEW.employee_id <> v_employee THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transfer employee and amount must match payroll';
  END IF;
END$$
DELIMITER ;

CREATE OR REPLACE VIEW v_payroll_summary AS
SELECT p.payroll_id, pp.period_name, e.employee_no,
       CONCAT(e.first_name,' ',e.last_name) AS employee_name,
       d.department_name, p.basic_salary,p.gross_pay,p.total_deductions,p.net_pay
FROM payroll_details p
JOIN employees e ON e.employee_id=p.employee_id
JOIN departments d ON d.department_id=e.department_id
JOIN payroll_periods pp ON pp.period_id=p.period_id;

CREATE OR REPLACE VIEW v_loan_balances AS
SELECT l.loan_id,e.employee_no,CONCAT(e.first_name,' ',e.last_name) AS employee_name,
       l.loan_type,l.principal_amount,l.balance,l.monthly_installment,l.status
FROM loans l JOIN employees e ON e.employee_id=l.employee_id
WHERE l.status='ACTIVE' AND l.balance>0;
