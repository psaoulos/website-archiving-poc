""" Module containing all functions responsible for File System manipulation. """
import os
from datetime import datetime
from zoneinfo import ZoneInfo
from modules import Logger, Variables, Database


logger = Logger.get_logger()
env_variables = Variables()
root_dir = os.getcwd()


def init_folders():
    """ Creates folder required for application to operate. """
    # Create directory
    try:
        os.mkdir("./archive")
        logger.debug("Directory ./backend/archive Created.")
    except FileExistsError:
        logger.debug("Directory ./backend/archive already exists.")


def get_os_friendly_name(url):
    """ Helper function to remove convert page url to suitable form in order to name achive folder. """
    if url.startswith('https://'):
        os_friendly_name = url.replace("https://", "")
    else:
        os_friendly_name = url.replace("http://", "")
    os_friendly_name = os_friendly_name.split("/")[0]
    return os_friendly_name


def create_page_folder(url):
    """ Creates folder named after page to be crawled over, which contains archived snapshots of said page. """
    os.chdir("./archive")
    dir_name = get_os_friendly_name(url)
    try:
        # Create target Directory
        os.mkdir(dir_name)
        logger.debug(f"Directory {dir_name} Created.")
    except FileExistsError:
        logger.debug(f"Directory {dir_name} already exists.")
    os.chdir(root_dir)


def make_day_folder():
    """ Creates a date specific folder to contain archived snapshots of page. """
    sub_dir_name = datetime.now(
        ZoneInfo(env_variables.get_env_var("TIME_ZONE"))).strftime('%d-%m-%y')
    try:
        os.mkdir(sub_dir_name)
    except FileExistsError:
        logger.debug(f"{sub_dir_name} Sub-Folder exists!")
    os.chdir(sub_dir_name)
    return sub_dir_name


def save_page(content, url, encoding):
    """ Saves page content as a file on corresponding archive folder. """
    os.chdir(f"./archive/{get_os_friendly_name(url)}")
    name = datetime.now(
        ZoneInfo(env_variables.get_env_var("TIME_ZONE"))).strftime("%H:%M:%S")
    folder_name = make_day_folder()
    file_location = f"./archive/{get_os_friendly_name(url)}/{folder_name}/{name}.html"
    logger.debug(
        f"Saving archive on: {file_location}")
    with open(f"{name}.html", "w", encoding=encoding) as file:
        file.write(content)
        file.close()
        os.chdir(root_dir)
        logger.debug(f"{name} snaphot saved.")
        Database.insert_new_archive_entry(address=url, file_location=file_location)
