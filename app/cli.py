"""Command-line actions for attendance, payroll, payslips and bank instructions."""
import argparse
from .db import connect
from .payroll import calculate

def main():
    p=argparse.ArgumentParser(description="Payroll student project helper")
    sub=p.add_subparsers(dest="action",required=True)
    a=sub.add_parser("attendance");a.add_argument("--employee",type=int,required=True);a.add_argument("--start",required=True);a.add_argument("--end",required=True);a.add_argument("--working-days",type=int,required=True);a.add_argument("--present",type=int,required=True);a.add_argument("--overtime",type=float,default=0)
    c=sub.add_parser("calculate");c.add_argument("--employee-no",required=True);c.add_argument("--period",type=int,required=True)
    s=sub.add_parser("payslip");s.add_argument("--payroll",type=int,required=True)
    t=sub.add_parser("transfer");t.add_argument("--payroll",type=int,required=True)
    args=p.parse_args()
    if args.action=="attendance":
        con=connect()
        try:
            cur=con.cursor();cur.execute("""INSERT INTO attendance_summaries(employee_id,period_start,period_end,working_days,days_present,overtime_hours)
                VALUES(%s,%s,%s,%s,%s,%s) ON DUPLICATE KEY UPDATE working_days=VALUES(working_days),days_present=VALUES(days_present),overtime_hours=VALUES(overtime_hours)""",(args.employee,args.start,args.end,args.working_days,args.present,args.overtime));con.commit();print("Attendance saved")
        except Exception:con.rollback();raise
        finally:con.close()
    elif args.action=="calculate": print(f"Payroll created: {calculate(args.employee_no,args.period)}")
    elif args.action=="payslip":
        con=connect()
        try:
            cur=con.cursor();cur.execute("INSERT INTO payslips(payroll_id) VALUES(%s) ON DUPLICATE KEY UPDATE document_status='GENERATED'",(args.payroll,));con.commit();print("Payslip record generated")
        except Exception:con.rollback();raise
        finally:con.close()
    elif args.action=="transfer":
        con=connect()
        try:
            cur=con.cursor(dictionary=True);cur.execute("""SELECT p.employee_id,e.bank_name,e.bank_account_no,p.net_pay FROM payroll_details p JOIN employees e USING(employee_id) WHERE p.payroll_id=%s""",(args.payroll,));r=cur.fetchone()
            if not r:raise ValueError("Payroll not found")
            if not r["bank_name"] or not r["bank_account_no"]:raise ValueError("Employee bank details are missing")
            cur.execute("""INSERT INTO bank_transfers(payroll_id,employee_id,bank_name,bank_account_no,amount) VALUES(%s,%s,%s,%s,%s)
                ON DUPLICATE KEY UPDATE amount=VALUES(amount)""",(args.payroll,r["employee_id"],r["bank_name"],r["bank_account_no"],r["net_pay"]));con.commit();print("Bank transfer instruction created")
        except Exception:con.rollback();raise
        finally:con.close()

if __name__=="__main__":main()
