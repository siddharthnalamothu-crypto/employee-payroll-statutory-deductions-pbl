# Payroll ER diagram

```mermaid
erDiagram
 DEPARTMENTS ||--o{ EMPLOYEES : groups
 DESIGNATIONS ||--o{ EMPLOYEES : assigns
 DESIGNATIONS ||--o{ SALARY_STRUCTURES : prices
 EMPLOYEES ||--o{ ATTENDANCE_SUMMARIES : records
 EMPLOYEES ||--o{ LOANS : borrows
 EMPLOYEES ||--o{ PAYROLL_DETAILS : receives
 PAYROLL_PERIODS ||--o{ PAYROLL_DETAILS : includes
 ATTENDANCE_SUMMARIES o|--o{ PAYROLL_DETAILS : supports
 PAYROLL_DETAILS ||--o{ PAYROLL_EARNINGS : contains
 PAYROLL_DETAILS ||--o{ PAYROLL_DEDUCTIONS : contains
 PAYROLL_DETAILS ||--o| PAYSLIPS : generates
 PAYROLL_DETAILS ||--o| BANK_TRANSFERS : instructs
 DEPARTMENTS { int department_id PK string department_code UK string department_name UK }
 DESIGNATIONS { int designation_id PK string designation_name UK string grade }
 EMPLOYEES { int employee_id PK string employee_no UK string email UK int department_id FK int designation_id FK }
 SALARY_STRUCTURES { int salary_structure_id PK int designation_id FK date effective_from decimal basic_salary }
 ATTENDANCE_SUMMARIES { int attendance_id PK int employee_id FK date period_start date period_end int days_present }
 LOANS { int loan_id PK int employee_id FK decimal principal_amount decimal balance decimal monthly_installment }
 PAYROLL_PERIODS { int period_id PK string period_name UK date period_start date period_end }
 PAYROLL_DETAILS { int payroll_id PK int employee_id FK int period_id FK decimal gross_pay decimal total_deductions decimal net_pay }
 PAYROLL_EARNINGS { int earning_id PK int payroll_id FK string earning_type decimal amount }
 PAYROLL_DEDUCTIONS { int deduction_id PK int payroll_id FK string deduction_type boolean statutory decimal amount }
 PAYSLIPS { int payslip_id PK int payroll_id FK UK }
 BANK_TRANSFERS { int transfer_id PK int payroll_id FK UK int employee_id FK decimal amount }
```

Additional candidate key: `payroll_details(employee_id, period_id)` is UNIQUE.
