# Database and application test matrix

Fill actual output and screenshot name after running against a local MySQL 8.0.16+ server. Never label an unrun case as passed.

| ID | Case | Expected result | Status in this workspace |
|---|---|---|---|
| DB-01 | Duplicate employee number | UNIQUE error | Not run: MySQL unavailable |
| DB-02 | Duplicate payroll for employee and period | UNIQUE error | Not run: MySQL unavailable |
| DB-03 | Present days greater than working days | CHECK error | Not run: MySQL unavailable |
| DB-04 | Negative loan balance | CHECK/trigger error | Not run: MySQL unavailable |
| DB-05 | Deductions above gross | Trigger error | Not run: MySQL unavailable |
| DB-06 | Net pay differs from gross minus deductions | Trigger error | Not run: MySQL unavailable |
| DB-07 | Boundary: zero days present and zero overtime | Accepted if working days positive | Not run: MySQL unavailable |
| DB-08 | Department report after seed | Expected department sums | Not run: MySQL unavailable |
| APP-01 | Parse Python files | No syntax error | To be checked locally |

Recommended evidence: `01_schema_loaded.png`, `02_seed_rows.png`, `03_report_output.png`, `04_duplicate_rejected.png`, `05_rollback.png`. Capture real screenshots on your machine and add captions.
