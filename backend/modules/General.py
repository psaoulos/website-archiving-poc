""" Module containing general functionality functions. """
import os
from modules import Logger

logger = Logger.get_logger()


def is_docker():
    """ Function to determine if application is running inside a Docker container. """
    path = '/proc/self/cgroup'

    if os.path.exists('/.dockerenv'):
        return True
    with open(path, encoding='UTF-8') as path_file:
        return os.path.isfile(path) and any('docker' in line for line in path_file)
