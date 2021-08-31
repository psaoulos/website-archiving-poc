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
            provide_var_template_and_exit()

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
            provide_var_template_and_exit()
    else:
        if "MARIADB_PASSWORD" in os.environ:
            MARIADB_PASSWORD = os.getenv("MARIADB_PASSWORD").strip()
        else:
            logger.error("No MARIADB_PASSWORD env var found, please specify it on root .env.")
            provide_var_template_and_exit()

    if "MARIADB_PORT" in os.environ:
        MARIADB_PORT = int(os.getenv("MARIADB_PORT").strip())
    else:
        MARIADB_PORT = 3306

    if "MARIADB_DATABASE" in os.environ:
        MARIADB_DATABASE = os.getenv("MARIADB_DATABASE").strip()
    else:
        logger.error("No MARIADB_DATABASE env var found, please specify set it on root .env.")
        provide_var_template_and_exit()

def provide_var_template_and_exit():
    if not os.path.isfile("env"):
        f = open("env", "a")
        content = (
            '# Please fill the following as instructed on the README.md file of project\n'
            f'WEBPAGE_URL = "{"" if WEBPAGE_URL is None else str(WEBPAGE_URL)}"\n'
            f'MARIADB_IP = "{"" if MARIADB_IP is None else str(MARIADB_IP)}"\n'
            f'MARIADB_USER = "{"" if MARIADB_USER is None else str(MARIADB_USER)}"\n'
            f'MARIADB_ROOT_PASSWORD = "{"" if MARIADB_ROOT_PASSWORD is None else str(MARIADB_ROOT_PASSWORD)}"\n'
            f'MARIADB_PASSWORD = "{"" if MARIADB_PASSWORD is None else str(MARIADB_PASSWORD)}"\n'
            f'MARIADB_PORT = "{"" if MARIADB_PORT is None else str(MARIADB_PORT)}"\n'
            f'MARIADB_DATABASE = "{"" if MARIADB_DATABASE is None else str(MARIADB_DATABASE)}"\n'
        )
        f.write(content)
        f.close()
        logger.error("Dummy env file Created, Please fill it and copy it to project root folder as .env") 
    else:
        logger.error("Please fill env file and copy it to project root folder as .env")
    sys.exit(1)