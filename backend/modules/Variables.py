""" Module containting class responsible for loading and handling env variables. """
import os
import sys
from modules import Logger, General


logger = Logger.get_logger()

# Default Value,, Required to be set by user on .env file where "-" is used
env_variables = {
    "WEBPAGE_URL": "https://www.in.gr/",
    "MARIADB_IP": "-",
    "MARIADB_USER": "root",
    "MARIADB_ROOT_PASSWORD": "-",
    "MARIADB_PASSWORD": "-",
    "MARIADB_PORT": "3306",
    "MARIADB_DATABASE": "-",
    "TIME_ZONE": "Europe/Athens",
}


class Variables():
    """ Class used for env variables handling. """
    def init_variables_from_env(self):
        """ Load and check env variables. """

        if "WEBPAGE_URL" in os.environ:
            env_variables["WEBPAGE_URL"] = os.getenv('WEBPAGE_URL').strip()
            if not (env_variables["WEBPAGE_URL"].startswith("http://") or
                    env_variables["WEBPAGE_URL"].startswith("https://")):
                logger.debug(
                    "WEBPAGE_URL env var does not specify http/https, defaulting to http.")
                env_variables["WEBPAGE_URL"] = f"http://{env_variables['WEBPAGE_URL']}"
        else:
            logger.debug("No WEBPAGE_URL env var found, defaulting.")

        if "MARIADB_IP" in os.environ:
            env_variables["MARIADB_IP"] = os.getenv("MARIADB_IP").strip()
        else:
            if General.is_docker():
                logger.debug("No MARIADB_IP env var found, "
                            "since running on docker defaulting to work with provided docker-compose.")
                env_variables["MARIADB_IP"] = "mariadb"
            else:
                logger.error("No MARIADB_IP env var found, "
                             "please specify in on root .env or consider running the docker-compose version.")
                self.provide_var_template_and_exit()

        if "MARIADB_USER" in os.environ:
            env_variables["MARIADB_USER"] = os.getenv("MARIADB_USER").strip()
        else:
            logger.debug("No MARIADB_USER env var found, defaulting to root.")

        if env_variables["MARIADB_USER"] == "root":
            if "MARIADB_ROOT_PASSWORD" in os.environ:
                env_variables["MARIADB_ROOT_PASSWORD"] = os.getenv(
                    "MARIADB_ROOT_PASSWORD").strip()
                env_variables["MARIADB_PASSWORD"] = os.getenv(
                    "MARIADB_ROOT_PASSWORD").strip()
            else:
                logger.error(
                    "No MARIADB_ROOT_PASSWORD env var found, please specify it on root .env.")
                self.provide_var_template_and_exit()
        else:
            if "MARIADB_PASSWORD" in os.environ:
                env_variables["MARIADB_PASSWORD"] = os.getenv(
                    "MARIADB_PASSWORD").strip()
            else:
                logger.error(
                    "No MARIADB_PASSWORD env var found, please specify it on root .env.")
                self.provide_var_template_and_exit()

        if "MARIADB_PORT" in os.environ:
            env_variables["MARIADB_PORT"] = int(
                os.getenv("MARIADB_PORT").strip())
        else:
            logger.debug("No MARIADB_PORT env var found, defaulting to 3306.")

        if "MARIADB_DATABASE" in os.environ:
            env_variables["MARIADB_DATABASE"] = os.getenv(
                "MARIADB_DATABASE").strip()
        else:
            logger.error(
                "No MARIADB_DATABASE env var found, please specify it on root .env.")
            self.provide_var_template_and_exit()

        if "TIME_ZONE" in os.environ:
            env_variables["TIME_ZONE"] = os.getenv("TIME_ZONE").strip()
        else:
            logger.debug(
                "No TIME_ZONE env var found, defaulting to Europe/Athens.")

    @staticmethod
    def provide_var_template_and_exit():
        """ Populate env file with a template of variables needed for the application to work. """
        if not os.path.isfile("env"):
            with open("env", "a", encoding='UTF-8') as env_file:
                content = (
                    '# Please fill the following as instructed on the README.md file of project\n'
                    f'WEBPAGE_URL="{env_variables["WEBPAGE_URL"]}"\n'
                    f'MARIADB_IP="{env_variables["MARIADB_IP"]}"\n'
                    f'MARIADB_USER="{env_variables["MARIADB_USER"]}"\n'
                    f'MARIADB_ROOT_PASSWORD="{env_variables["MARIADB_ROOT_PASSWORD"]}"\n'
                    f'MARIADB_PASSWORD="{env_variables["MARIADB_PASSWORD"]}"\n'
                    f'MARIADB_PORT="{env_variables["MARIADB_PORT"]}"\n'
                    f'MARIADB_DATABASE="{env_variables["MARIADB_DATABASE"]}"\n'
                    f'TIME_ZONE="{env_variables["TIME_ZONE"]}"\n'
                )
                env_file.write(content)
                env_file.close()
                logger.error(
                    "Dummy env file Created, Please fill it and copy it to project root folder as .env")
        else:
            logger.error(
                "Please fill env file and copy it to project root folder as .env")
        sys.exit(1)

    @staticmethod
    def get_env_var(var_name):
        """ Getter function for env variable values. """
        return env_variables.get(var_name, "404")
