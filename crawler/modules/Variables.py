import os
import sys
import modules.Logger as Logger
import modules.FileSystem as FileSystem
import modules.General as General

logger = Logger.get_logger()
WEBPAGE_URL = None
MARIADB_IP = None
MARIADB_USER = None
MARIADB_ROOT_PASSWORD = None
MARIADB_PASSWORD = None
MARIADB_PORT = None
MARIADB_DATABASE = None
    
def init_variables_from_env():
    # declaring as global in order to change the values of same named top level variables above
    global WEBPAGE_URL
    global MARIADB_IP 
    global MARIADB_USER
    global MARIADB_ROOT_PASSWORD
    global MARIADB_PASSWORD
    global MARIADB_PORT
    global MARIADB_DATABASE

    if "WEBPAGE_URL" in os.environ:
        WEBPAGE_URL = os.getenv('WEBPAGE_URL').strip()
        if not (WEBPAGE_URL.startswith("http://") or WEBPAGE_URL.startswith("http://")):
            logger.debug("WEBPAGE_URL env var does not specify http/https, defaulting to http.")
            WEBPAGE_URL = f"http://{WEBPAGE_URL}"
    else:
        logger.debug("No WEBPAGE_URL env var found, defaulting.")
        WEBPAGE_URL = "https://www.in.gr/"

    if "MARIADB_IP" in os.environ:
        MARIADB_IP = os.getenv("MARIADB_IP").strip()
    else:
        if General.is_docker():
            logger.info(f"No MARIADB_IP env var found, since running on docker defaulting to work with provided docker-compose.")
            MARIADB_IP = "mariadb"
        else:
            logger.error(f"No MARIADB_IP env var found, please specify in on root .env or consider running the docker-compose version.")
            sys.exit(1)

    if "MARIADB_USER" in os.environ:
        MARIADB_USER = os.getenv("MARIADB_USER").strip()
    else:
        logger.info(f"No MARIADB_USER env var found, defaulting to root.")
        MARIADB_USER = "root"

    if MARIADB_USER == "root":
        if "MARIADB_ROOT_PASSWORD" in os.environ:
            MARIADB_ROOT_PASSWORD = os.getenv("MARIADB_ROOT_PASSWORD").strip()
            MARIADB_PASSWORD = os.getenv("MARIADB_ROOT_PASSWORD").strip()
        else:
            logger.error("No MARIADB_ROOT_PASSWORD env var found, please specify it on root .env.")
            sys.exit(1)
    else:
        if "MARIADB_PASSWORD" in os.environ:
            MARIADB_PASSWORD = os.getenv("MARIADB_PASSWORD").strip()
        else:
            logger.error("No MARIADB_PASSWORD env var found, please specify it on root .env.")
            sys.exit(1)

    if "MARIADB_PORT" in os.environ:
        MARIADB_PORT = int(os.getenv("MARIADB_PORT").strip())
    else:
        MARIADB_PORT = 3306

    if "MARIADB_DATABASE" in os.environ:
        MARIADB_DATABASE = os.getenv("MARIADB_DATABASE").strip()
    else:
        logger.error("No MARIADB_DATABASE env var found, please specify set it on root .env.")
        sys.exit(1)
