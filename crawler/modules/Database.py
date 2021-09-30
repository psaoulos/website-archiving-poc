import sys
import mariadb
from modules import Logger, Variables, CustomExceptions

logger = Logger.get_logger()
env_variables = Variables()
# Used to denote if 3 consecutive connections could not be established, in that case no further connection attempts 
# will be made in order for the crawler not to hung at every connection attempt
problem_connecting = False
problem_connecting_counter = 0

def connect_to_db():
    global problem_connecting
    try:
        if problem_connecting is False:
            dbcon = mariadb.connect(
                user=env_variables.get_env_var("MARIADB_USER"),
                password=env_variables.get_env_var("MARIADB_PASSWORD"),
                host=env_variables.get_env_var("MARIADB_IP"),
                port=env_variables.get_env_var("MARIADB_PORT"),
                database=env_variables.get_env_var("MARIADB_DATABASE"),
                autocommit=False,
                connect_timeout=2
            )
            if not check_user_permissions(dbcon):
                logger.error(f"{env_variables.get_env_var('MARIADB_USER')} does not have all permissions on {env_variables.get_env_var('MARIADB_DATABASE')}, please check env variables as specified on readme.")
                dbcon.close()
                sys.exit(1)
            else:
                return dbcon
        else:
            return CustomExceptions.DBConnectionException("Skipped DB Connection, please check if DB is live and credentials passed in .env")
    except mariadb.Error as e:
        global problem_connecting_counter
        problem_connecting_counter = problem_connecting_counter + 1
        if problem_connecting_counter == 3:
            problem_connecting = True
        return CustomExceptions.DBConnectionException(e)

def check_user_permissions(dbcon):
    dbcur = dbcon.cursor()
    dbcur.execute("SHOW GRANTS FOR CURRENT_USER")
    row = dbcur.fetchone()
    all_permissions = False
    while row is not None:
        permission = row[0]
        permission = permission.replace('`', '')
        permission = permission.replace('\\', '')
        if f"GRANT ALL PRIVILEGES ON {env_variables.get_env_var('MARIADB_DATABASE')}.* TO {env_variables.get_env_var('MARIADB_USER')}@" in permission:
            all_permissions = True
        row = dbcur.fetchone()
    dbcur.close()
    return all_permissions


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
    if type(dbcon) is CustomExceptions.DBConnectionException:
        del dbcon
        return CustomExceptions.DBGenericException("Could not init DB as a connection was not established.")
    dbcur = dbcon.cursor()
    try:
        if not check_if_table_exists(dbcon,"links_table"):
            logger.debug(f"links_table table did not exist, creating.")
            dbcur.execute("CREATE TABLE links_table (link NVARCHAR(255), checked BOOLEAN, primary key(link))")
    except mariadb.Error as e:
        logger.error(f"Error creating table: {e}")
        dbcur.close()
        dbcon.close()
        sys.exit(1)
    dbcur.close()
    dbcon.close()

def insert_links_found(links):
    dbcon = connect_to_db()
    dbcur = dbcon.cursor()
    try:
        # Using IGNORE to pass duplicate links
        dbcur.executemany(f"INSERT IGNORE INTO {env_variables.get_env_var('MARIADB_DATABASE')}.links_table(link, checked) VALUES (?, ?)",
            (links))
        rowcount = dbcur.rowcount
        logger.debug(f"Inserted {rowcount} links to DB.")
        dbcon.commit()
    except Exception as e:
        logger.error(f"Error committing insert_links_found transaction: {e}")
        dbcon.rollback()
    dbcur.close()
    dbcon.close()