from datetime import datetime
import os
import logging
import time

root_dir = os.getcwd()

def init_folders():
    # Create directory
    try:
        os.mkdir("./archive")
        print("Directory ", "./crawler/archive",  " Created ")
    except FileExistsError:
        print("Directory ", "./crawler/archive",  " already exists")


def get_os_friendly_name(url):
    if url.startswith('https://'):
        os_friendly_name = url.replace("https://", "")
    else:
        os_friendly_name = url.replace("http://", "")
    os_friendly_name = os_friendly_name.split("/")[0]
    return os_friendly_name


def create_page_folder(url):
    os.chdir("./archive")
    dir_name = get_os_friendly_name(url)
    try:
        # Create target Directory
        os.mkdir(dir_name)
        print("Directory ", dir_name,  " Created ")
    except FileExistsError:
        print("Directory ", dir_name,  " already exists")
    os.chdir(root_dir)


def make_day_folder(url):
    if os.getcwd().endswith(f"/archive/{get_os_friendly_name(url)}"):
        subDirName = datetime.today().strftime('%d-%m-%y')
        try:
            os.mkdir(subDirName)
        except FileExistsError:
            print(f"{subDirName} Sub-Folder exists!")
        os.chdir(subDirName)


def save_page(content, file_name, url):
    os.chdir(f"./archive/{get_os_friendly_name(url)}")
    name = datetime.today().strftime("%H:%M")
    make_day_folder(url)
    f = open(f"{name}.html", "w")
    f.write(str(content))
    f.close()
    os.chdir(root_dir)