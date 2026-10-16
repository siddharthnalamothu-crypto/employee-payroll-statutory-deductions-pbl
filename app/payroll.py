"""Basic transactional payroll calculation for the educational prototype."""
from decimal import Decimal, ROUND_HALF_UP
from .db import connect

CENT = Decimal("0.01")
def calculate(employee_no: str, period_id: int) -> int:
    conn = connect()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute("""SELECT e.employee_id,pp.period_id,pp.period_start,pp.period_end,
                 ss.basic_salary,ss.housing_allowance,ss.transport_allowance,
                 a.attendance_id,a.overtime_hours
          FROM employees e JOIN payroll_periods pp ON pp.period_id=%s
          JOIN salary_structures ss ON ss.designation_id=e.designation_id
             AND ss.effective_from<=pp.period_end AND (ss.effective_to IS NULL OR ss.effective_to>=pp.period_start)
          JOIN attendance_summaries a ON a.employee_id=e.employee_id AND a.period_start=pp.period_start AND a.period_end=pp.period_end
          WHERE e.employee_no=%s AND e.employment_status='ACTIVE'
          ORDER BY ss.effective_from DESC LIMIT 1""", (period_id,employee_no))
        row=cur.fetchone()
        if not row: raise ValueError("Employee, effective salary or matching attendance was not found")
        employee_id=row["employee_id"]
        cur.execute("SELECT payroll_id FROM payroll_details WHERE employee_id=%s AND period_id=%s",(employee_id,period_id))
        if cur.fetchone(): raise ValueError("Payroll already exists for this employee and period")

        basic=Decimal(row["basic_salary"])
        earnings=[("Housing Allowance",Decimal(row["housing_allowance"])),("Transport Allowance",Decimal(row["transport_allowance"]))]
        overtime=(basic/Decimal(176)*Decimal(row["overtime_hours"])).quantize(CENT,rounding=ROUND_HALF_UP)
        if overtime: earnings.append(("Overtime",overtime))
        gross=basic+sum((amount for _,amount in earnings),Decimal(0))

        cur.execute("SELECT loan_id,balance,monthly_installment FROM loans WHERE employee_id=%s AND status='ACTIVE' AND balance>0 FOR UPDATE",(employee_id,))
        loans=cur.fetchall()
        repayments=[]
        for loan in loans:
            amount=min(Decimal(loan["balance"]),Decimal(loan["monthly_installment"]))
            repayments.append((loan["loan_id"],amount))
        loan_total=sum((amount for _,amount in repayments),Decimal(0))
        deductions=[("Pension",True,(basic*Decimal("0.10")).quantize(CENT)),
                    ("PAYE",True,(gross*Decimal("0.05")).quantize(CENT))]
        if loan_total: deductions.append(("Loan Repayment",False,loan_total))
        total_deductions=sum((amount for _,_,amount in deductions),Decimal(0))
        if total_deductions>gross: raise ValueError("Deductions exceed gross pay")
        net=gross-total_deductions
        cur.execute("""INSERT INTO payroll_details(employee_id,period_id,attendance_id,basic_salary,gross_pay,total_deductions,net_pay)
                       VALUES(%s,%s,%s,%s,%s,%s,%s)""",(employee_id,period_id,row["attendance_id"],basic,gross,total_deductions,net))
        payroll_id=cur.lastrowid
        cur.executemany("INSERT INTO payroll_earnings(payroll_id,earning_type,amount) VALUES(%s,%s,%s)",[(payroll_id,k,v) for k,v in earnings])
        cur.executemany("INSERT INTO payroll_deductions(payroll_id,deduction_type,statutory,amount) VALUES(%s,%s,%s,%s)",[(payroll_id,k,s,v) for k,s,v in deductions])
        for loan_id,amount in repayments:
            cur.execute("UPDATE loans SET balance=balance-%s WHERE loan_id=%s",(amount,loan_id))
        conn.commit()
        return payroll_id
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()
