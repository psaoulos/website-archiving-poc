""" Module containing all functions responsible for File System manipulation. """
from ast import Try
import logging
import os
import difflib
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


def save_page(content, url, encoding, dif_ratio, crawler_id):
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
        Database.insert_new_archive_entry(
            address=url, file_location=file_location, encoding=encoding, crawler_id=crawler_id, dif_ratio=dif_ratio)


def calculate_file_difference(file_a_location, file_b_location, encoding_a="UTF-8", encoding_b="UTF-8"):
    """ Calculates the difference percentage between two files according their paths given. """
    try:
        with open(file_a_location, "r", encoding=encoding_a) as file_a:
            with open(file_b_location, "r", encoding=encoding_b) as file_b:
                seq_mat = difflib.SequenceMatcher()
                seq_mat.set_seqs(file_a.readlines(),
                                 file_b.readlines())
                percentage = seq_mat.ratio()
                logger.debug(f"Got the archive difference at {percentage}")
                return percentage
    except Exception as ex:
        logger.error(
            f"Exception while calculating archive difference for {file_a_location} {file_b_location}. {ex}")
        return None


def calculate_content_difference(file_a_location, content_b, encoding_a="UTF-8", encoding_b="UTF-8"):
    """ Calculates the difference percentage between the first file and the second crawled content."""
    try:
        with open("./archive/temp.html", "w", encoding=encoding_b) as file:
            file.write(content_b)
            file.close()
        with open(file_a_location, "r", encoding=encoding_a) as file_a:
            with open("./archive/temp.html", "r", encoding=encoding_b) as file_b:
                seq_mat = difflib.SequenceMatcher()
                seq_mat.set_seqs(file_a.readlines(),
                                 file_b.readlines())
                percentage = seq_mat.ratio()
                logger.debug(f"Got the archive difference at {percentage}")
                return percentage
    except Exception as ex:
        logger.error(
            f"Exception while calculating archive difference for {file_a_location} and content for second file. {ex}")
        return None


def generate_diff_html(file_a_location, file_b_location, encoding="UTF-8"):
    """ Generates the printable html diff file between two given archive files. """
    try:
        with open(file_a_location, "r", encoding=encoding) as file_a:
            with open("./archive/temp.html", "r", encoding=encoding) as file_b:
                difference = difflib.HtmlDiff(wrapcolumn=80)
                html = difference.make_file(
                    fromlines=file_a.readlines(), tolines=file_b.readlines(), context=True, numlines=3,
                    fromdesc="Original", todesc="Modified"
                )
                return html
    except Exception as ex:
        logger.error(
            f"Exception while generating diff html for {file_a_location} / {file_b_location}. {ex}")
        return None
