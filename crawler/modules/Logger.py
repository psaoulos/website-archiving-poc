import os
import logging


def get_logger_lever(value):
    return {
        'NOTSET': logging.NOTSET,
        'DEBUG': logging.DEBUG,
        'INFO': logging.INFO,
        'WARNING': logging.WARNING,
        'ERROR': logging.ERROR,
        'CRITICAL': logging.CRITICAL
    }.get(value, logging.INFO)


def init_logger():
    print("Going to create a logger now...")
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
    # Format for our loglines
    formatter = logging.Formatter(
        "%(asctime)s - %(levelname)s - %(message)s")
    # Setup console logging
    ch = logging.StreamHandler()
    ch.setLevel(ch_level)
    ch.setFormatter(formatter)
    logger.addHandler(ch)
    # Setup file logging as well
    if not os.path.exists('./logs'):
        os.makedirs('./logs')
        logger.debug(f"Logs Folder did not exist, creating!")
    fh = logging.FileHandler("./logs/app.log", mode='w')
    fh.setLevel(fh_level)
    fh.setFormatter(formatter)
    logger.addHandler(fh)

    if "CH_LEVEL" not in os.environ and "FH_LEVEL" not in os.environ:
        logger.info("CH_LEVEL and FH_LEVEL env vars not set, defaulting to INFO level logs.")

def get_logger():
    return logging.getLogger("crawler_logger")