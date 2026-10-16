"""MySQL connection helper. Configure with MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE."""
import os
import mysql.connector

def connect():
    return mysql.connector.connect(
        host=os.getenv("MYSQL_HOST", "localhost"),
        port=int(os.getenv("MYSQL_PORT", "3306")),
        user=os.getenv("MYSQL_USER", "root"),
        password=os.getenv("MYSQL_PASSWORD", ""),
        database=os.getenv("MYSQL_DATABASE", "payroll_db"),
    )
