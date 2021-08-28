import os
import sys
import re
import mariadb
import modules.Logger as Logger
import modules.Variables as Variables
import modules.General as General

def connect_to_db():
    try:
        dbcon = mariadb.connect(
            user=Variables.MARIADB_USER,
            password=Variables.MARIADB_PASSWORD,
            host=Variables.MARIADB_IP,
            port=Variables.MARIADB_PORT,
            database=Variables.MARIADB_DATABASE
        )
            return dbcon
    except mariadb.Error as e:
        Logger.get_logger().error(f"Error connecting to MariaDB Platform: {e}")
        sys.exit(1)



def check_if_table_exists(dbcon, tablename):
    dbcur = dbcon.cursor()
    dbcur.execute("""
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_name = '{0}'
        """.format(tablename.replace('\'', '\'\'')))
    if dbcur.fetchone()[0] == 1:
        dbcur.close()
        return True
    dbcur.close()
    return False


def init_database():
    dbcon = connect_to_db()
    dbcur = dbcon.cursor()

    try:
        if not check_if_table_exists(dbcon,"links_table"):
            Logger.get_logger().debug(f"links_table table did not exist, creating.")
            dbcur.execute("CREATE TABLE links_table (link NVARCHAR(255), checked BOOLEAN, checkedOn TIMESTAMP)")
    except mariadb.Error as e:
        Logger.get_logger().error(f"Error creating table: {e}")
        dbcur.close()
        dbcon.close()
        sys.exit(1)
    dbcur.close()
    dbcon.close()