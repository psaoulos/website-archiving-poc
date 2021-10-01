""" Module containing all custom exceptions used. """
from modules import Logger

logger = Logger.get_logger()

def print_exception(e):
    logger.error(e)

class DBConnectionException:
    def __init__(self, e):
        print_exception(e)

    pass

class DBGenericException:
    def __init__(self, e):
        print_exception(e)

    pass
