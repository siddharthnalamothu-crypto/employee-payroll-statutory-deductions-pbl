"""Tkinter student MVP: employee CRUD/search and payroll reports."""
import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import mysql.connector
from .db import connect

class PayrollWindow(tk.Tk):
    def __init__(self):
        super().__init__(); self.title("Employee Payroll Management"); self.geometry("1050x650")
        self.selected_no=None; self.entries={}; self.build(); self.refresh()
    def build(self):
        box=ttk.LabelFrame(self,text="Employee details"); box.pack(fill="x",padx=10,pady=8)
        fields=[("Employee No","employee_no"),("First name","first_name"),("Last name","last_name"),("Email","email"),
                ("Phone","phone"),("Department ID","department_id"),("Designation ID","designation_id"),("Hire date YYYY-MM-DD","hire_date")]
        for i,(label,key) in enumerate(fields):
            r,c=divmod(i,4); ttk.Label(box,text=label).grid(row=r*2,column=c,sticky="w",padx=5)
            entry=ttk.Entry(box,width=25); entry.grid(row=r*2+1,column=c,padx=5,pady=(0,6)); self.entries[key]=entry
        actions=ttk.Frame(self); actions.pack(fill="x",padx=10)
        for label,fn in [("Add",self.add),("Update selected",self.update),("Delete selected",self.delete),("Clear",self.clear),("Refresh",self.refresh)]: ttk.Button(actions,text=label,command=fn).pack(side="left",padx=3)
        search=ttk.Frame(self); search.pack(fill="x",padx=10,pady=6); ttk.Label(search,text="Search:").pack(side="left")
        self.term=ttk.Entry(search,width=35); self.term.pack(side="left",padx=5); self.term.bind("<KeyRelease>",lambda _e:self.refresh())
        cols=("employee_no","name","email","department","designation","status")
        self.table=ttk.Treeview(self,columns=cols,show="headings",height=15)
        for col,title in zip(cols,("Employee No","Name","Email","Department","Designation","Status")): self.table.heading(col,text=title); self.table.column(col,width=160)
        self.table.pack(fill="both",expand=True,padx=10,pady=5); self.table.bind("<<TreeviewSelect>>",self.select)
        reports=ttk.Frame(self); reports.pack(fill="x",padx=10,pady=5)
        for kind in ("summary","department cost","loan balances","bank transfers"): ttk.Button(reports,text=kind.title(),command=lambda k=kind:self.report(k)).pack(side="left",padx=3)
        ttk.Button(reports,text="Salary structures",command=self.salary_window).pack(side="left",padx=3)
    def refresh(self):
        if not hasattr(self,"table"): return
        term=f"%{self.term.get().strip()}%" if hasattr(self,"term") else "%"
        try:
            con=connect(); cur=con.cursor(); cur.execute("""SELECT e.employee_no,CONCAT(e.first_name,' ',e.last_name),e.email,d.department_name,g.designation_name,e.employment_status FROM employees e JOIN departments d USING(department_id) JOIN designations g USING(designation_id) WHERE e.employee_no LIKE %s OR e.first_name LIKE %s OR e.last_name LIKE %s ORDER BY e.employee_no""",(term,term,term)); rows=cur.fetchall(); con.close()
            self.table.delete(*self.table.get_children())
            for row in rows:self.table.insert("","end",values=row)
        except mysql.connector.Error as exc: messagebox.showerror("Database error",str(exc))
    def select(self,_event=None):
        chosen=self.table.selection()
        if not chosen:return
        self.selected_no=self.table.item(chosen[0],"values")[0]
        con=connect(); cur=con.cursor(); cur.execute("SELECT employee_no,first_name,last_name,email,phone,department_id,designation_id,hire_date FROM employees WHERE employee_no=%s",(self.selected_no,)); row=cur.fetchone(); con.close()
        for key,value in zip(self.entries,row): self.entries[key].delete(0,"end"); self.entries[key].insert(0,"" if value is None else str(value))
    def form(self):
        v={k:e.get().strip() for k,e in self.entries.items()}
        for required in ("employee_no","first_name","last_name","email","department_id","designation_id","hire_date"):
            if not v[required]: raise ValueError(f"{required.replace('_',' ').title()} is required")
        v["department_id"]=int(v["department_id"]);v["designation_id"]=int(v["designation_id"]);return v
    def add(self):
        try:
            v=self.form(); con=connect(); cur=con.cursor(); cur.execute("INSERT INTO employees(employee_no,first_name,last_name,email,phone,department_id,designation_id,hire_date) VALUES(%(employee_no)s,%(first_name)s,%(last_name)s,%(email)s,%(phone)s,%(department_id)s,%(designation_id)s,%(hire_date)s",v);con.commit();con.close();self.refresh()
        except (ValueError,mysql.connector.Error) as exc: messagebox.showerror("Cannot add employee",str(exc))
    def update(self):
        if not self.selected_no:return messagebox.showwarning("Select employee","Choose a row first")
        try:
            v=self.form()
            if v["employee_no"] != self.selected_no:raise ValueError("Employee number is the stable key and cannot be edited here")
            con=connect();cur=con.cursor();cur.execute("UPDATE employees SET first_name=%(first_name)s,last_name=%(last_name)s,email=%(email)s,phone=%(phone)s,department_id=%(department_id)s,designation_id=%(designation_id)s,hire_date=%(hire_date)s WHERE employee_no=%s",(*[v[k] for k in ("first_name","last_name","email","phone","department_id","designation_id","hire_date")],self.selected_no));con.commit();con.close();self.refresh()
        except (ValueError,mysql.connector.Error) as exc: messagebox.showerror("Cannot update employee",str(exc))
    def delete(self):
        if not self.selected_no:return messagebox.showwarning("Select employee","Choose a row first")
        if not messagebox.askyesno("Confirm","Delete selected employee? Related payroll/loan records restrict deletion."):return
        try:
            con=connect();cur=con.cursor();cur.execute("DELETE FROM employees WHERE employee_no=%s",(self.selected_no,));con.commit();con.close();self.clear();self.refresh()
        except mysql.connector.Error as exc: messagebox.showerror("Cannot delete employee",str(exc))
    def clear(self):
        self.selected_no=None
        for e in self.entries.values():e.delete(0,"end")
    def report(self,kind):
        queries={"summary":"SELECT * FROM v_payroll_summary ORDER BY period_name,employee_name","department cost":"SELECT department_name,SUM(gross_pay),SUM(net_pay) FROM v_payroll_summary GROUP BY department_name","loan balances":"SELECT * FROM v_loan_balances","bank transfers":"SELECT employee_no,bank_name,amount,transfer_status FROM bank_transfers JOIN employees USING(employee_id)"}
        try:
            con=connect();cur=con.cursor();cur.execute(queries[kind]);rows=cur.fetchall();headers=[c[0] for c in cur.description];con.close()
            w=tk.Toplevel(self);w.title(kind.title());t=tk.Text(w,width=110,height=25);t.pack(fill="both",expand=True);t.insert("end"," | ".join(headers)+"\n")
            for row in rows:t.insert("end"," | ".join(map(str,row))+"\n")
            t.configure(state="disabled")
        except mysql.connector.Error as exc:messagebox.showerror("Report error",str(exc))

    def salary_window(self):
        w=tk.Toplevel(self);w.title("Salary structure maintenance");w.geometry("850x420")
        cols=("id","designation","effective_from","effective_to","basic","housing","transport")
        grid=ttk.Treeview(w,columns=cols,show="headings",height=13)
        for c,label in zip(cols,("ID","Designation","From","To","Basic","Housing","Transport")):grid.heading(c,text=label);grid.column(c,width=115)
        grid.pack(fill="both",expand=True,padx=8,pady=8)
        def load():
            grid.delete(*grid.get_children());con=connect();cur=con.cursor();cur.execute("SELECT s.salary_structure_id,d.designation_name,s.effective_from,s.effective_to,s.basic_salary,s.housing_allowance,s.transport_allowance FROM salary_structures s JOIN designations d USING(designation_id) ORDER BY d.designation_name,s.effective_from");rows=cur.fetchall();con.close()
            for row in rows:grid.insert("","end",values=row)
        def values(old=None):
            des=simpledialog.askinteger("Salary structure","Designation ID",initialvalue=None if old is None else old[0],parent=w)
            if des is None:return None
            start=simpledialog.askstring("Salary structure","Effective from (YYYY-MM-DD)",initialvalue=None if old is None else str(old[1]),parent=w)
            if not start:return None
            end=simpledialog.askstring("Salary structure","Effective to (blank for current)",initialvalue="" if old is None or old[2] is None else str(old[2]),parent=w)
            basic=simpledialog.askfloat("Salary structure","Basic salary (> 0)",initialvalue=None if old is None else float(old[3]),parent=w)
            housing=simpledialog.askfloat("Salary structure","Housing allowance",initialvalue=0 if old is None else float(old[4]),parent=w)
            transport=simpledialog.askfloat("Salary structure","Transport allowance",initialvalue=0 if old is None else float(old[5]),parent=w)
            if basic is None or housing is None or transport is None:return None
            if basic<=0 or housing<0 or transport<0:raise ValueError("Basic must be positive and allowances non-negative")
            return (des,start,end or None,basic,housing,transport)
        def add():
            try:
                v=values()
                if v:
                    con=connect();cur=con.cursor();cur.execute("INSERT INTO salary_structures(designation_id,effective_from,effective_to,basic_salary,housing_allowance,transport_allowance) VALUES(%s,%s,%s,%s,%s,%s)",v);con.commit();con.close();load()
            except (ValueError,mysql.connector.Error) as exc:messagebox.showerror("Salary validation",str(exc),parent=w)
        def update():
            sel=grid.selection()
            if not sel:return messagebox.showwarning("Select row","Choose a salary structure",parent=w)
            row=grid.item(sel[0],"values")
            try:
                v=values((row[0],row[2],row[3] or None,float(row[4]),float(row[5]),float(row[6])))
                if v:
                    con=connect();cur=con.cursor();cur.execute("UPDATE salary_structures SET designation_id=%s,effective_from=%s,effective_to=%s,basic_salary=%s,housing_allowance=%s,transport_allowance=%s WHERE salary_structure_id=%s",(*v,row[0]));con.commit();con.close();load()
            except (ValueError,mysql.connector.Error) as exc:messagebox.showerror("Salary validation",str(exc),parent=w)
        def delete():
            sel=grid.selection()
            if not sel:return messagebox.showwarning("Select row","Choose a salary structure",parent=w)
            if not messagebox.askyesno("Confirm","Delete selected salary structure?",parent=w):return
            try:
                con=connect();cur=con.cursor();cur.execute("DELETE FROM salary_structures WHERE salary_structure_id=%s",(grid.item(sel[0],"values")[0],));con.commit();con.close();load()
            except mysql.connector.Error as exc:messagebox.showerror("Delete failed",str(exc),parent=w)
        controls=ttk.Frame(w);controls.pack(fill="x",padx=8,pady=4)
        for label,fn in (("Add",add),("Update selected",update),("Delete selected",delete),("Refresh",load)):ttk.Button(controls,text=label,command=fn).pack(side="left",padx=3)
        load()

if __name__=="__main__": PayrollWindow().mainloop()
