import os
import sys
import mariadb
import modules.Logger as Logger
import modules.General as General


def connect_to_db():
    db_username = ""
    db_password = ""
    db_ip = ""
    db_port = ""
    db_database = ""

    
    if "MARIADB_USER" in os.environ:
        db_username = os.getenv("MARIADB_USER").strip()
    else:
        db_username = "root"
    if "MARIADB_PASSWORD" in os.environ:
        db_password = os.getenv("MARIADB_PASSWORD").strip()
    else:
        if "MARIADB_USER" in os.environ:
            if "MARIADB_PASSWORD"in os.environ:
                db_password = os.getenv("MARIADB_PASSWORD").strip()
            else:
                Logger.get_logger().error(f"No MARIADB_PASSWORD env var found, please specify it on root .env.")
                sys.exit(1)
        else:
            if "MARIADB_ROOT_PASSWORD" in os.environ:
                db_password = os.getenv("MARIADB_ROOT_PASSWORD").strip()
            else:
                Logger.get_logger().error(f"No MARIADB_PASSWORD / MARIADB_ROOT_PASSWORD env var found, please specify them on root .env.")
                sys.exit(1)

    if "MARIADB_PORT" in os.environ:
        db_port = int(os.getenv("MARIADB_PORT").strip())
    else:
        db_port = 3306
    
    if "MARIADB_DATABASE" in os.environ:
        db_database = os.getenv("MARIADB_DATABASE").strip()
    else:
        Logger.get_logger().error(f"No MARIADB_DATABASE env var found, please specify set it on root .env.")
        sys.exit(1)

    if General.is_docker():
        db_ip = "mariadb"
    else:
        if "MARIADB_IP" in os.environ:
            db_ip = os.getenv("MARIADB_IP").strip()
        else:
            Logger.get_logger().error(f"No MARIADB_IP env var found, please specify in on root .env or consider running the docker-compose version.")
            sys.exit(1)
    try:
        dbcon = mariadb.connect(
            user=db_username,
            password=db_password,
            host=db_ip,
            port=db_port,
            database=db_database
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