import os
import mariadb
import modules.Logger as Logger
import modules.General as General


def connect_to_db():
    db_username = ""
    db_password = ""
    db_ip = ""

    if "MARIADB_USER" in os.environ:
        db_username = os.getenv("MARIADB_USER").strip()
    else:
        db_username = "root"
    if "MARIADB_PASSWORD" in os.environ:
        db_password = os.getenv("MARIADB_PASSWORD").strip()
    else:
        if "MARIADB_ROOT_PASSWORD" in os.environ:
            db_password = os.getenv("MARIADB_ROOT_PASSWORD").strip()
        else:
            Logger.get_logger().error(f"No MARIADB_PASSWORD / MARIADB_ROOT_PASSWORD env var found, please specify them on root .env.")
            return None
    
    if General.is_docker():
        db_ip = "mariadb"
    else:
        if "MARIADB_IP" in os.environ:
            db_ip = os.getenv("MARIADB_IP").strip()
        else:
            Logger.get_logger().error(f"No MARIADB_IP env var found, please specify in on root .env or consider running the docker-compose version.")
            return None
    try:
        conn = mariadb.connect(
            user=db_username,
            password=db_password,
            host=db_ip,
            port=3306,
            database="test"
        )
        return conn
    except mariadb.Error as e:
        Logger.get_logger().error(f"Error connecting to MariaDB Platform: {e}")
        return None
