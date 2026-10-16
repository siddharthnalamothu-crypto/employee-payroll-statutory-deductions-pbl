# Review 1 — Design

## Project identity

- Project: Design and Implementation of a Database Management System for Employee Payroll and Statutory Deduction Management System
- Student: Siddharth [enter full name]
- Roll number: [ENTER ROLL NUMBER]
- Mentor: Dr. Sahithi
- Semester: 3
- Section: CSE Panthers
- Course: 25TU03MJM0 — Database Management Systems
- Stack: MySQL 8.0+ and Python

The payroll topic is the project statement already provided in this conversation. The uploaded DOCX is the college report template; its phishing project title is placeholder content and is not used as this project's topic.

## Problem and objectives

Organizations maintain employees, departments, designations, salaries, attendance, earnings, statutory deductions, loans, payslips and payment instructions. Spreadsheet formulas can be copied incorrectly, duplicate records are hard to spot, and the source of a net-pay amount may be difficult to audit. This project stores those facts in related tables, validates important values and calculates a period payroll from stored inputs.

Objectives:

1. Maintain employee, organization and effective-dated salary records.
2. Store monthly attendance summaries and overtime.
3. Calculate gross pay, deductions and net pay with traceable line items.
4. Track employee loan balances and installment deductions.
5. Prevent duplicate employee-period payroll and invalid amounts.
6. Generate payslip and bank-transfer records and management reports.
7. Demonstrate keys, relationships, normalization, SQL, transactions and Python-MySQL integration.

## Users and modules

HR staff: employee and organization data. Payroll staff: salary, attendance, payroll, payslips. Finance staff: deductions, loans, transfers and payroll reports. Managers: departmental cost and variance reports. Administrator: database setup and backup.

Modules: employee maintenance; salary setup; attendance; payroll calculation; loan repayment; payslip/transfer register; reporting.

## Entities and keys

See [ER diagram](er_diagram.md). Core entities are departments, designations, employees, salary structures, attendance summaries, payroll periods, payroll details, earnings, deductions, loans, payslips and bank transfers. Each has a primary key. Foreign keys connect employees to departments/designations, salary structures to designations, attendance and loans to employees, payroll to employee/period/attendance, and line items/documents to payroll.

## Cardinalities

| Relationship | Cardinality | Reason |
|---|---|---|
| Department–Employee | 1:N | A department has employees; each employee has one current department. |
| Designation–Employee | 1:N | One designation may be assigned to many employees. |
| Designation–Salary Structure | 1:N | Salary rates can change over effective dates. |
| Employee–Attendance Summary | 1:N | One summary per employee per payroll period. |
| Employee–Loan | 1:N | An employee may have multiple loans. |
| Employee–Payroll Period | M:N | Resolved by Payroll Details; unique employee and period. |
| Payroll–Earning/Deduction | 1:N | Each payroll has component lines. |
| Payroll–Payslip/Transfer | 1:0..1 | A payroll may have at most one record of each. |

## Normalization preview

Employee names and department labels are not repeated as multi-value columns. Departments and designations are separate relations. Repeating earnings/deduction components are stored as rows, not columns such as `deduction1`, `deduction2`. Payroll detail uses an employee-period unique key. Review 2 contains functional dependencies and 1NF–3NF reasoning.

## Project roadmap

| Review | Work |
|---|---|
| 1 | Problem, scope, requirements, entities, ER diagram and normalized design |
| 2 | MySQL DDL, sample data, SQL reports, constraints and test matrix |
| 3 | Python interface, complete workflow, demo, presentation and final report |

## What to demonstrate/say

Show the ER model and explain how Payroll Details resolves the employee-period many-to-many relationship. Say: “The design separates employee, organization and payroll facts to reduce duplication. The unique employee-period key prevents duplicate payroll. In Review 2 I will demonstrate these relationships and data integrity with SQL.”
