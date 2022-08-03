""" Module containing application's core Logging functionality. """
from datetime import datetime
import os
import logging
from logging.handlers import RotatingFileHandler
import pytz


class CustomLogRecord(logging.LogRecord):
    """ Custom LogRecord used to set max characters for function and file name """

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.origin = f"{self.funcName}:{self.filename}"


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


class Formatter(logging.Formatter):
    """Override logging.Formatter to use an aware datetime object."""

    def converter(self, timestamp):
        """Converts default UTC time to TZ provided."""
        from modules import Variables
        # Import needed inside function to avoid circular imports
        date_time = datetime.fromtimestamp(timestamp, tz=pytz.UTC)
        return date_time.astimezone(pytz.timezone(Variables.get_env_var('TIME_ZONE')))

    def formatTime(self, record, datefmt=None):
        """Format time accordingly."""
        date_time = self.converter(record.created)
        if datefmt:
            formatted = date_time.strftime(datefmt)
        else:
            try:
                formatted = date_time.isoformat(timespec='milliseconds')
            except TypeError:
                formatted = date_time.isoformat()
        return formatted


def init_logger():
    """ Initializer for application Logger. """
    logging.setLogRecordFactory(CustomLogRecord)
    if "CH_LEVEL" in os.environ:
        ch_level = get_logger_lever(os.getenv('CH_LEVEL'))
    else:
        ch_level = logging.DEBUG
    if "FH_LEVEL" in os.environ:
        fh_level = get_logger_lever(os.getenv('FH_LEVEL'))
    else:
        fh_level = logging.DEBUG
    logger = logging.getLogger("crawler_backend")
    logger.setLevel(ch_level)
    # Format for loglines, adding padding up to 8 for CRITICAL level and up to 3 for linenumber
    formatter = Formatter(
        "[%(asctime)s][%(levelname)8s][%(origin)47s:%(lineno)3s] -- %(message)s", "%Y-%m-%d %H:%M:%S"
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
    file_handler = RotatingFileHandler("./logs/crawler_backend.log", mode='a', maxBytes=5*1024*1024,
                                       backupCount=2, encoding='utf-8', delay=0)
    file_handler.setLevel(fh_level)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)


def get_logger(logger_name="crawler_backend"):
    """ Getter function for application's core Logger. """
    return logging.getLogger(logger_name)


def conditonal_logging(should_log, message, level="DEBUG", logger_name="crawler_backend"):
    """ Helper function used to conditionaly print logs to avoid spamming the log output. """
    if not should_log:
        return
    logger = get_logger(logger_name)
    if level == "DEBUG":
        logger.debug(message)
    elif level == "INFO":
        logger.info(message)
    elif level == "WARNING":
        logger.warning(message)
    elif level == "ERROR":
        logger.error(message)
    elif level == "CRITICAL":
        logger.critical(message)
