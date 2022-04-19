""" Module containing all custom exceptions used. """
from modules import Logger

logger = Logger.get_logger()

def print_exception(exception):
    """ Helper function for printing out exception. """
    logger.error(exception)

class DBConnectionException:
    """ Custon exception for DB Connection error. """
    def __init__(self, e):
        print_exception(e)

class DBGenericException:
    """ Custom Generric Exception. """
    def __init__(self, e):
        print_exception(e)
