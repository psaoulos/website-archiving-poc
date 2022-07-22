""" Module containing all functions responsible for DataBase manipulation. """
from datetime import datetime
import sys
import mariadb
import pytz
from modules import Logger, Variables, CustomExceptions

logger = Logger.get_logger()
env_variables = Variables()
# Used to denote if 3 consecutive connections could not be established, in that case no further connection attempts
# will be made in order for the crawler not to hung at every connection attempt
PROBLEM_CONNECTING = False
PROBLEM_CONNECTING_COUNTER = 0


def connect_to_db():
    """ Helper function for connecting to mariaDB. """
    global PROBLEM_CONNECTING
    global PROBLEM_CONNECTING_COUNTER
    try:
        if PROBLEM_CONNECTING is False:
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
                logger.error(
                    f"{env_variables.get_env_var('MARIADB_USER')} does not have all"
                    f" permissions on {env_variables.get_env_var('MARIADB_DATABASE')},"
                    f" please check env variables as specified on readme."
                )
                dbcon.close()
                sys.exit(1)
            else:
                return dbcon
        else:
            return CustomExceptions.DBConnectionException(
                "Skipped DB Connection, please check if DB is live and credentials passed in .env"
            )
    except mariadb.Error as ex:
        PROBLEM_CONNECTING_COUNTER = PROBLEM_CONNECTING_COUNTER + 1
        if PROBLEM_CONNECTING_COUNTER == 3:
            PROBLEM_CONNECTING = True
        return CustomExceptions.DBConnectionException(ex)


def check_user_permissions(dbcon):
    """ Helper function to check if user provided has the required permissions on mariaDB. """
    try:
        dbcur = dbcon.cursor()
        dbcur.execute("SHOW GRANTS FOR CURRENT_USER")
        row = dbcur.fetchone()
        all_permissions = False
        while row is not None:
            permission = row[0]
            permission = permission.replace('`', '')
            permission = permission.replace('\\', '')
            if_statement = (
                f"GRANT ALL PRIVILEGES ON {env_variables.get_env_var('MARIADB_DATABASE').lower()}.*"
                f" TO {env_variables.get_env_var('MARIADB_USER')}@"
            )
            root_if_statement = (
                f"GRANT ALL PRIVILEGES ON *.*"
                f" TO {env_variables.get_env_var('MARIADB_USER')}@"
            )
            if if_statement in permission:
                all_permissions = True
            elif root_if_statement in permission:
                all_permissions = True
            row = dbcur.fetchone()
        dbcur.close()
        return all_permissions
    except Exception as ex:
        return CustomExceptions.DBConnectionException(ex)


def check_if_table_exists(dbcon, tablename):
    """ Helper function for checking in a table allready exists in mariaDB. """
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
    """ Helper function for initializing the naruaDB """
    dbcon = connect_to_db()
    if isinstance(dbcon, CustomExceptions.DBConnectionException):
        del dbcon
        CustomExceptions.DBGenericException(
            "Could not init DB as a connection was not established.")
        return
    dbcur = dbcon.cursor()
    try:
        if not check_if_table_exists(dbcon, "links_table"):
            logger.debug("links_table table did not exist, creating.")
            dbcur.execute("""
            CREATE TABLE links_table (root_address NVARCHAR(255), link NVARCHAR(255), 
            checked BOOLEAN, primary key(root_address,link))
            """)
        if not check_if_table_exists(dbcon, "crawler_info"):
            logger.debug("crawler_info table did not exist, creating.")
            dbcur.execute("""
            CREATE TABLE crawler_info (root_address NVARCHAR(255), iterations INT, iteration_interval INT, 
            current_iteration INT, started_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, process_id INT, 
            running BOOLEAN DEFAULT TRUE, primary key(root_address, started_timestamp))
            """)
        if not check_if_table_exists(dbcon, "archive_index"):
            logger.debug("archive_index table did not exist, creating.")
            dbcur.execute("""
            CREATE TABLE archive_index (root_address NVARCHAR(255), file_location NVARCHAR(255), var_ratio_from_last DOUBLE, 
            archive_encoding NVARCHAR(255), creation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, primary key(root_address, creation_timestamp))
            """)
    except mariadb.Error as ex:
        logger.error(f"Error creating table: {ex}")
        dbcur.close()
        dbcon.close()
        sys.exit(1)
    dbcur.close()
    dbcon.close()
    return


def clean_table(table_name):
    """ Helper function to clear a DB table after done iterating. """
    dbcon = connect_to_db()
    dbcur = dbcon.cursor()
    try:
        dbcur.execute(f"TRUNCATE TABLE {table_name}")
        dbcon.commit()
    except Exception as ex:
        logger.error(
            f"Error committing {table_name} truncate transaction: {ex}")
        dbcon.rollback()
    dbcur.close()
    dbcon.close()


def insert_new_crawl_task(pid, address, iterations, interval):
    """ Helper function for inserting new crawl tasks info on crawler_info table. """
    dbcon = connect_to_db()
    dbcur = dbcon.cursor()
    try:
        timestamp = datetime.now(pytz.timezone(
            Variables.get_env_var('TIME_ZONE')))
        query = (f"""
            INSERT INTO {env_variables.get_env_var('MARIADB_DATABASE')}.
            crawler_info(root_address, iterations, iteration_interval, current_iteration, started_timestamp, process_id) VALUES (?, ?, ?, ?, ?, ?)
        """)
        dbcur.execute(query, (address, int(iterations),
                      int(interval), 1, timestamp, int(pid)))
        dbcon.commit()
    except Exception as ex:
        logger.error(f"Error committing crawler_info transaction: {ex}")
        dbcon.rollback()
    dbcur.close()
    dbcon.close()


def increment_crawler_step(process_id, address):
    """ Helper function for incrementing crawler current_iteration. """
    dbcon = connect_to_db()
    dbcur = dbcon.cursor()
    try:
        query = (f"""
            UPDATE crawler_info SET current_iteration = current_iteration + 1 
            WHERE root_address = '{address}' AND process_id = '{process_id}' AND running = 1
        """)
        dbcur.execute(query)
        dbcon.commit()
    except Exception as ex:
        logger.error(
            f"Error updating crawler_info {process_id} transaction: {ex}")
        dbcon.rollback()
    dbcur.close()
    dbcon.close()


def update_finished_crawler(process_id, address):
    """ Helper function for incrementing crawler current_iteration. """
    dbcon = connect_to_db()
    dbcur = dbcon.cursor()
    try:
        query = (f"""
            UPDATE crawler_info SET running = 0
            WHERE root_address = '{address}' AND process_id = '{process_id}' AND running = 1
        """)
        dbcur.execute(query)
        dbcon.commit()
    except Exception as ex:
        logger.error(
            f"Error updating crawler_info for finished {process_id} transaction: {ex}")
        dbcon.rollback()
    dbcur.close()
    dbcon.close()


def insert_links_found(address, links):
    """ Helper function for inserting links on links_table, while ignoring duplicate entries. """
    list_to_add = []
    for link in links:
        list_to_add.append((address, link, False))
    dbcon = connect_to_db()
    dbcur = dbcon.cursor()
    try:
        # Using IGNORE to bypass duplicate links
        query = (f"""
            INSERT IGNORE INTO {env_variables.get_env_var('MARIADB_DATABASE')}.
            links_table(root_address, link, checked) VALUES (?, ?, ?)
        """)
        dbcur.executemany(query, (list_to_add))
        rowcount = dbcur.rowcount
        logger.debug(f"Inserted {rowcount} links to DB.")
        dbcon.commit()
    except Exception as ex:
        logger.error(f"Error committing insert_links_found transaction: {ex}")
        dbcon.rollback()
    dbcur.close()
    dbcon.close()


def insert_new_archive_entry(address, file_location, encoding, dif_ratio=None):
    """ Helper function for inserting entry for new archive kept for specific address. """
    dbcon = connect_to_db()
    dbcur = dbcon.cursor()
    try:
        timestamp = datetime.now(pytz.timezone(
            Variables.get_env_var('TIME_ZONE')))
        if dif_ratio is None:
            query = (f"""
                INSERT INTO {env_variables.get_env_var('MARIADB_DATABASE')}.
                archive_index(root_address, file_location, archive_encoding, creation_timestamp) VALUES (?, ?, ?, ?)
            """)
            dbcur.execute(query, (address, file_location, encoding, timestamp))
        else:
            query = (f"""
                INSERT INTO {env_variables.get_env_var('MARIADB_DATABASE')}.
                archive_index(root_address, file_location, var_ratio_from_last, archive_encoding, creation_timestamp) VALUES (?, ?, ?, ?, ?)
            """)
            dbcur.execute(query, (address, file_location, dif_ratio, encoding, timestamp))
        dbcon.commit()
    except Exception as ex:
        logger.error(f"Error committing archive_index transaction: {ex}")
        dbcon.rollback()
    dbcur.close()
    dbcon.close()

def get_last_archive_entry(address):
    """ Helper function for getting the last entry from the archive_index table. """
    dbcon = connect_to_db()
    dbcur = dbcon.cursor()
    result = ()
    try:
        query = (f"""
            SELECT file_location, var_ratio_from_last, archive_encoding
            FROM archive_index ai
            WHERE root_address = '{address}'
            ORDER BY creation_timestamp DESC LIMIT 1
        """)
        dbcur.execute(query)
        result = dbcur.fetchone()
    except Exception as ex:
        logger.error(f"Error selecting from archive_index transaction: {ex}")
        dbcon.rollback()
    dbcur.close()
    dbcon.close()
    return result
