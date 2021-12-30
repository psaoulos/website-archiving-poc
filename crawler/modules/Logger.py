""" Module containing application's core Logging functionality. """
import os
import logging

def get_logger_lever(value):
    """ Helper function for getting loggin level from string value. """
    return {
        'NOTSET': logging.NOTSET,
        'DEBUG': logging.DEBUG,
        'INFO': logging.INFO,
        'WARNING': logging.WARNING,
        'ERROR': logging.ERROR,
        'CRITICAL': logging.CRITICAL
    }.get(value, logging.INFO)


def init_logger():
    """ Initializer for Logger. """
    if "CH_LEVEL" in os.environ:
        ch_level = get_logger_lever(os.getenv('CH_LEVEL'))
    else:
        ch_level = logging.DEBUG
    if "FH_LEVEL" in os.environ:
        fh_level = get_logger_lever(os.getenv('FH_LEVEL'))
    else:
        fh_level = logging.DEBUG
    logger = logging.getLogger("crawler_logger")
    logger.setLevel(ch_level)
    # Format for loglines, adding padding up to 8 for CRITICAL level
    formatter = logging.Formatter(
        "[%(asctime)s] [%(levelname)8s] --- %(message)s (%(funcName)s:%(filename)s:%(lineno)s)", "%Y-%m-%d %H:%M:%S"
    )

    # Setup console logging
    console_handler = logging.StreamHandler()
    console_handler.setLevel(ch_level)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    # Setup file logging as well
    if not os.path.exists('./logs'):
        os.makedirs('./logs')
        logger.debug("Logs Folder did not exist, creating!")
    file_handler = logging.FileHandler("./logs/app.log", mode='w')
    file_handler.setLevel(fh_level)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)

    if "CH_LEVEL" not in os.environ and "FH_LEVEL" not in os.environ:
        logger.info("CH_LEVEL and FH_LEVEL env vars not set, defaulting to INFO level logs.")


def get_logger(logger_name="crawler_logger"):
    """ Getter function for application's core Logger. """
    return logging.getLogger(logger_name)
