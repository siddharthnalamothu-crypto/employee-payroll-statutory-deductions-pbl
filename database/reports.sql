USE payroll_db;

-- 1. Join/view: employee gross, deductions and net pay by payroll period.
SELECT * FROM v_payroll_summary ORDER BY period_name,employee_name;

-- 2. Filtering and grouping: total deductions by type.
SELECT deduction_type,SUM(amount) AS total_deduction
FROM payroll_deductions GROUP BY deduction_type ORDER BY total_deduction DESC;

-- 3. Subquery: active loans whose balance exceeds the largest monthly installment.
SELECT * FROM v_loan_balances
WHERE balance > (SELECT MAX(monthly_installment) FROM loans WHERE status='ACTIVE');

-- 4. Department payroll cost using joins and aggregation.
SELECT department_name,SUM(gross_pay) AS gross_cost,SUM(net_pay) AS net_cost
FROM v_payroll_summary GROUP BY department_name ORDER BY gross_cost DESC;

-- 5. Payroll variance: variable pay and percentage above basic salary.
SELECT period_name,employee_no,gross_pay-basic_salary AS variable_pay,
       ROUND((gross_pay-basic_salary)/NULLIF(basic_salary,0)*100,2) AS variance_percent
FROM v_payroll_summary ORDER BY period_name,employee_no;

-- 6. Bank transfers: employee, destination and transfer state.
SELECT e.employee_no,CONCAT(e.first_name,' ',e.last_name) AS employee_name,
       b.bank_name,b.bank_account_no,b.amount,b.transfer_status,b.transfer_date
FROM bank_transfers b JOIN employees e ON e.employee_id=b.employee_id
ORDER BY b.transfer_status,employee_name;

-- 7. Transaction demonstration: make a temporary status change and roll it back.
START TRANSACTION;
UPDATE bank_transfers SET transfer_status='COMPLETED' WHERE transfer_id=2;
SELECT transfer_id,transfer_status FROM bank_transfers WHERE transfer_id=2;
ROLLBACK;
SELECT transfer_id,transfer_status FROM bank_transfers WHERE transfer_id=2;
